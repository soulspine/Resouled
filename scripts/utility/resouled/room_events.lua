local game = Game()

local BASE_ROOM_EVENT_NUM_PER_FLOOR = function()
    return Resouled:GetOptionValue("Base Room Event Num")
end
local ROOM_EVENTS_TO_ADD_PER_CHAPTER = function()
    return Resouled:GetOptionValue("Room Events Per Chapter")
end

local STAGES_BLACKLIST = {
    [1] = true,  -- BASEMENT
    [2] = true,  -- BASEMENT 2
    [9] = true,  -- HUSH
    [13] = true, -- HOME
}

---@class ResouledRoomEventDesc
---@field Id ResouledRoomEvent
---@field Name string
---@field Filters table
---@field NoDespawn? boolean

---@type table<string, ResouledRoomEventDesc>
local registeredRoomEvents = {}

---@param roomEvent ResouledRoomEvent
---@param name string
---@param filters table
---@param noDespawn boolean | nil
---@return boolean
function Resouled:RegisterRoomEvent(roomEvent, name, filters, noDespawn)
    local roomEventKey = tostring(roomEvent)

    if not registeredRoomEvents[roomEventKey] then
        registeredRoomEvents[roomEventKey] = {
            Id = roomEvent,
            Name = name,
            Filters = filters,
            NoDespawn = noDespawn or false
        }

        return true
    end

    Resouled:LogError("Tried to register a roomEvent that was already registered: " .. roomEvent)
    return false
end

---@param roomEventID ResouledRoomEvent
---@return ResouledRoomEventDesc | nil
function Resouled:GetRoomEvent(roomEventID)
    local roomEvent = registeredRoomEvents[tostring(roomEventID)]
    if roomEvent then
        return roomEvent
    end
    return nil
end

---@param roomEventID integer
---@return ResouledRoomEventDesc | nil
function Resouled:GetRoomEventByID(roomEventID)
    local roomEvent = registeredRoomEvents[tostring(roomEventID)]
    if roomEvent then
        return roomEvent
    end
    return nil
end

---@return ResouledRoomEventDesc[]
function Resouled:GetRoomEvents()
    local out = {}
    for _, buffDesc in pairs(registeredRoomEvents) do
        table.insert(out, buffDesc)
    end
    return out
end

---@param roomEventID ResouledRoomEvent
---@return boolean
function Resouled:RoomEventPresent(roomEventID)
    local ROOM_SAVE = Resouled.SaveManager.GetRoomFloorSave()
    if ROOM_SAVE.RoomEvent then
        if ROOM_SAVE.RoomEvent == roomEventID then
            return true
        end
    end
    return false
end

---@return boolean
function Resouled:SocialGoalsPresent()
    return Resouled.SaveManager.GetRunSave()["Social Goals"] ~= nil
end

---@param roomEventID  ResouledRoomEvent
---@return boolean
local function checkRoomEventFilters(roomEventID)
    local roomEvent = registeredRoomEvents[tostring(roomEventID)]
    if #roomEvent.Filters > 0 then
        for i = 1, #roomEvent.Filters do
            local filter = roomEvent.Filters[i]
            if filter() == false then
                return false
            end
        end
    end
    return true
end

local popupFont = Font()
popupFont:Load("font/upheaval.fnt")

local popupSprite = Sprite()
popupSprite:Load("gfx_resouled/ui/room_event_popup.anm2", true)
local MAX_POPUP_ALPHA = 0.75

local X = 0
local gain = 1
local maxDisplayTime = 150
local event = Resouled:GetRoomEvent(1)

local function isRoomEventPopupVisible()
    return X > 0
end

local function onRoomEventPopupRender()
    if RoomTransition.GetTransitionMode() == 4 or not event then return end

    if X >= 0 then
        local len = popupFont:GetStringWidth(event.Name)
        local iconAlpha = math.max(math.min(math.log(math.max(X - 21, 0), X), 1), 0)
        local scale = math.max(math.min(math.log(math.max(X - 20, 0), X/1.5), 1), 0)
        local textAlpha1 = math.log(math.max(X - 60, 0), X/1.5)
        if textAlpha1 == math.huge then
            textAlpha1 = 0
        end
        local textAlpha = math.max(math.min(textAlpha1, 1), 0)
        
        popupSprite.Color.A = iconAlpha * MAX_POPUP_ALPHA
        
        local pos = Vector(Isaac.GetScreenWidth()/2, 25) - Vector(len/2 * math.max(scale, 0.0001), 0)
        local otherPos = Vector(pos.X + (len * math.max(scale, 0.0001)), pos.Y)
        
        popupSprite:Play("Start", true)
        popupSprite:Render(pos)
        
        popupSprite:Play("Middle", true)
        popupSprite.Scale.X = (otherPos.X - pos.X)
        popupSprite:Render(pos)
        
        popupSprite.Scale.X = 1
        popupSprite:Play("End", true)
        popupSprite:Render(otherPos)
        
        popupFont:DrawString(event.Name, pos.X, pos.Y - popupFont:GetBaselineHeight()/1.5, KColor(1, 1, 1, textAlpha))
    end

    X = math.min(X + gain, maxDisplayTime)

    if X == maxDisplayTime and not Resouled:IsAnyonePressingAction(ButtonAction.ACTION_MAP) then
        gain = -gain
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_HUD_RENDER, onRoomEventPopupRender)

Resouled:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
    gain = -math.abs(gain)
end)

---@param roomEventId ResouledRoomEvent
local function showRoomEventPopup(roomEventId)
    event = Resouled:GetRoomEvent(roomEventId)
    gain = 1
    X = 0
end

---@param roomIndex integer
---@return ResouledRoomEvent
local function chooseRandomRoomEvent(roomIndex)
    local roomEvents = Resouled:GetRoomEvents()
    local seed = game:GetSeeds():GetStartSeed() + ((13 * 13 * Resouled.AccurateStats:GetCurrentChapter()) + roomIndex) * roomIndex
    if seed == 0 then seed = Resouled:NewSeed() end
    local rng = RNG(seed)
    ::RollRoomEvent::

    seed = Resouled:NewSeed()
    local randomNum = rng:RandomInt(#roomEvents) + 1

    if checkRoomEventFilters(randomNum) == false then
        goto RollRoomEvent
    end

    return randomNum
end

---@param roomEventID ResouledRoomEvent
---@param roomListIndex integer
local function forceRoomEvent(roomEventID, roomListIndex)
    local ROOM_SAVE = Resouled.SaveManager.GetRoomFloorSave(nil, false, roomListIndex)
    ROOM_SAVE.RoomEvent = roomEventID
end

local blacklistedRoomIndexes = {
    [84] = true -- startingRoom
}

local function initializeRoomEventifNotInitialized()
    local ROOM_SAVE = Resouled.SaveManager.GetRoomFloorSave()
    if ROOM_SAVE.RoomEvent and type(ROOM_SAVE.RoomEvent) ~= "number" then
        ROOM_SAVE.RoomEvent = chooseRandomRoomEvent(game:GetLevel():GetCurrentRoomDesc().SafeGridIndex)
        Resouled.SaveManager.Save()
    end
end

local SAVE_ENTRY = "Room Events Seen"

local function postNewFloor()
    local level = game:GetLevel()
    local stage = level:GetStage()

    if STAGES_BLACKLIST[stage] then -- blacklisted
        return
    end

    local RUN_SAVE = Resouled.SaveManager.GetRunSave()


    if not RUN_SAVE.RoomEvents or (RUN_SAVE.RoomEvents and RUN_SAVE.RoomEvents.CurrentChapter ~= Resouled.AccurateStats:GetCurrentChapter()) then -- we moved onto different chapter and refresh amount of room events to distribute
        RUN_SAVE.RoomEvents = {
            CurrentChapter = Resouled.AccurateStats:GetCurrentChapter(),
            EventsToDistribute = BASE_ROOM_EVENT_NUM_PER_FLOOR() +
            Resouled.AccurateStats:GetCurrentChapter() * ROOM_EVENTS_TO_ADD_PER_CHAPTER(),
            LastFloor = Resouled.AccurateStats:IsCurrentFloorLastFloorOfChapter(),
        }
    end

    local rng = RNG()
    rng:SetSeed(level:GetDevilAngelRoomRNG():GetSeed(), 7)
    
    local roomEventsThisFloor = RUN_SAVE.RoomEvents.LastFloor and RUN_SAVE.RoomEvents.EventsToDistribute or
    rng:RandomInt(RUN_SAVE.RoomEvents.EventsToDistribute)
    
    RUN_SAVE.RoomEvents.EventsToDistribute = RUN_SAVE.RoomEvents.EventsToDistribute - roomEventsThisFloor

    if rng:PhantomInt(#Resouled:GetRoomEvents()) == Resouled.RoomEvents.SOCIAL_GOALS then
    --if true then
        Resouled.SaveManager.GetRunSave()["Social Goals"] = {}
        Resouled.SaveManager.Save()

        showRoomEventPopup(Resouled.RoomEvents.SOCIAL_GOALS)

        local key = tostring(Resouled.RoomEvents.SOCIAL_GOALS)

        local statSave = Resouled.StatTracker:GetSave()
        if not statSave[SAVE_ENTRY] then statSave[SAVE_ENTRY] = {} end
        statSave = statSave[SAVE_ENTRY]
        if not statSave[key] then statSave[key] = false end
        statSave[key] = true

        return
    end
    
    local correctRooms = {}
    
    for y = 0, 13 do
        for x = 0, 13 do
            local room = level:GetRoomByIdx(13 * y + x)
            if room.Data and not blacklistedRoomIndexes[room.SafeGridIndex] then
                table.insert(correctRooms, room.SafeGridIndex)
            end
        end
    end
    
    for i = 1, roomEventsThisFloor do
        
        local seed = Resouled:NewSeed()
        
        if i > 169 then
            break
        end

        if #correctRooms <= 0 then
            break
        end

        rng:SetSeed(seed)
        seed = Resouled:NewSeed()

        local randomRoomIndex = rng:RandomInt(#correctRooms) + 1
        local roomGridIndex = correctRooms[randomRoomIndex]

        local roomListIndex = level:GetRoomByIdx(roomGridIndex).ListIndex

        local ROOM_SAVE = Resouled.SaveManager.GetRoomFloorSave(nil, false, roomListIndex)
        ROOM_SAVE.RoomEvent = true

        table.remove(correctRooms, randomRoomIndex)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, postNewFloor)

local function postNewRoom()
    initializeRoomEventifNotInitialized()

    local ROOM_SAVE = Resouled.SaveManager.GetRoomFloorSave()
    local room = game:GetRoom()

    if ROOM_SAVE.RoomEvent then
        showRoomEventPopup(ROOM_SAVE.RoomEvent)

        local key = tostring(ROOM_SAVE.RoomEvent)

        local statSave = Resouled.StatTracker:GetSave()
        if not statSave[SAVE_ENTRY] then statSave[SAVE_ENTRY] = {} end
        statSave = statSave[SAVE_ENTRY]
        if not statSave[key] then statSave[key] = false end
        statSave[key] = true

        if room:IsFirstVisit() then
            local save = Resouled.StatTracker:GetSave()
            if not save[Resouled.StatTracker.Fields.RoomEventsEncountered] then save[Resouled.StatTracker.Fields.RoomEventsEncountered] = 0 end
            save[Resouled.StatTracker.Fields.RoomEventsEncountered] = save[Resouled.StatTracker.Fields.RoomEventsEncountered] + 1
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, postNewRoom)

local function preRoomExit()
    initializeRoomEventifNotInitialized()

    local ROOM_SAVE = Resouled.SaveManager.GetRoomFloorSave()

    if ROOM_SAVE.RoomEvent then
        if not Resouled:GetRoomEventByID(ROOM_SAVE.RoomEvent).NoDespawn then
            ROOM_SAVE.RoomEvent = nil
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_ROOM_EXIT, preRoomExit)

local function postUpdate()
    if not isRoomEventPopupVisible() and Resouled:HasAnyoneTriggeredAction(ButtonAction.ACTION_MAP) then
        local ROOM_SAVE = Resouled.SaveManager.GetRoomFloorSave()
        if ROOM_SAVE.RoomEvent then
            showRoomEventPopup(ROOM_SAVE.RoomEvent)
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_UPDATE, postUpdate)

local COMMAND = {
    Name = "roomevent",
    Description =
    "Forces a room event to a specified room index or based on relative door position in the room you're currently in",
    HelpText = "Usage: "
}

Console.RegisterCommand(COMMAND.Name,
    "Forces a room event to a specified room index or based on relative  door position in the room you're currently in",
    "help text", false, AutocompleteType.CUSTOM)

local function executeRoomEventCommand(_, command, paramsRaw)
    if command == COMMAND.Name then
        local params = {}
        for word in string.gmatch(paramsRaw, "%S+") do
            table.insert(params, word)
        end
        if #params == 0 then
            Resouled:LogError("No room event specified. Use 'roomevent list' to see available room events.")
            return
        end

        local roomEvent = Resouled:GetRoomEventByID(tonumber(params[1]) or params[1])

        if not roomEvent then
            Resouled:LogError("Room event with ID: " .. tostring(params[1]) .. " hasn't been registered.")
            return
        end

        ---@type integer
        local targetRoomListIndex = params[2]

        if not targetRoomListIndex then
            local closestDoor = Resouled.Doors:GetClosestDoor(Isaac.GetPlayer().Position)
            if not closestDoor then
                Resouled:LogError("No door found to target room. Please specify a room index.")
                return
            end

            targetRoomListIndex = game:GetLevel():GetRoomByIdx(closestDoor.TargetRoomIndex).ListIndex
        end

        forceRoomEvent(roomEvent.Id, targetRoomListIndex)
    end
end
Resouled:AddCallback(ModCallbacks.MC_EXECUTE_CMD, executeRoomEventCommand)

local autocompleteTable = {}

Resouled:RunAfterImports(function()
    for _, roomEvent in ipairs(Resouled:GetRoomEvents()) do
        table.insert(autocompleteTable, { tostring(roomEvent.Id), roomEvent.Name })
    end
end)

local function roomEventCommandAutocomplete()
    return autocompleteTable
end
---@diagnostic disable-next-line: param-type-mismatch
Resouled:AddCallback(ModCallbacks.MC_CONSOLE_AUTOCOMPLETE, roomEventCommandAutocomplete, COMMAND.Name)