local game = Game()

local BASE_ROOM_EVENT_NUM_PER_FLOOR = 2
local ROOM_EVENTS_TO_ADD_PER_CHAPTER = 1

local STAGES_BLACKLIST = {
    [1] = true, -- BASEMENT
    [2] = true, -- BASEMENT 2
    [9] = true, -- HUSH
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
    local ROOM_SAVE = SAVE_MANAGER.GetRoomFloorSave()
    if ROOM_SAVE.RoomEvent then
        if ROOM_SAVE.RoomEvent == roomEventID then
            return true
        end
    end
    return false
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

---@param roomIndex? integer
---@return ResouledRoomEvent
local function chooseRandomRoomEvent(roomIndex)
    local rng = RNG(game:GetRoom():GetAwardSeed())
    ::RollRoomEvent::
        
    Resouled:NewSeed()
    local randomNum = rng:RandomInt(#Resouled:GetRoomEvents()) + 1
        
    if checkRoomEventFilters(randomNum) == false then
        goto RollRoomEvent
    end
        
    return randomNum
end

---@param roomEventID ResouledRoomEvent
---@param roomListIndex integer
local function forceRoomEvent(roomEventID, roomListIndex)
    local ROOM_SAVE = SAVE_MANAGER.GetRoomFloorSave(nil, false, roomListIndex)
    ROOM_SAVE.RoomEvent = roomEventID
end

local function postNewFloor()
    local stage = game:GetLevel():GetStage()
    if STAGES_BLACKLIST[stage] then -- blacklisted
        return
    end

    local RUN_SAVE = SAVE_MANAGER.GetRunSave()
    local rooms = game:GetLevel():GetRooms()
    

    if not RUN_SAVE.RoomEvents or (RUN_SAVE.RoomEvents and RUN_SAVE.RoomEvents.CurrentChapter ~= Resouled.AccurateStats:GetCurrentChapter()) then -- we moved onto different chapter and refresh amount of room events to distribute
        RUN_SAVE.RoomEvents = {
            CurrentChapter = Resouled.AccurateStats:GetCurrentChapter(),
            EventsToDistribute = BASE_ROOM_EVENT_NUM_PER_FLOOR + Resouled.AccurateStats:GetCurrentChapter() * ROOM_EVENTS_TO_ADD_PER_CHAPTER,
            LastFloor = Resouled.AccurateStats:IsCurrentFloorLastFloorOfChapter(),
        }
    end
    
    local rng = RNG()
    rng:SetSeed(game:GetLevel():GetDevilAngelRoomRNG():GetSeed(), 7)
    
    local roomEventsThisFloor = RUN_SAVE.RoomEvents.LastFloor and RUN_SAVE.RoomEvents.EventsToDistribute or rng:RandomInt(RUN_SAVE.RoomEvents.EventsToDistribute)
    
    RUN_SAVE.RoomEvents.EventsToDistribute = RUN_SAVE.RoomEvents.EventsToDistribute - roomEventsThisFloor

    local correctRooms = {}
    
    for i = 0, rooms.Size-1 do --GET VALID ROOMS
        local room = rooms:Get(i)
        table.insert(correctRooms, room.ListIndex)
    end

    for _ = 1, roomEventsThisFloor do
        ::RollRoom::
        Resouled:NewSeed()
        
        local randomRoomIndex = rng:RandomInt(#correctRooms)
        local roomListIndex = correctRooms[randomRoomIndex]
        
        if correctRooms[randomRoomIndex] == nil then
            goto RollRoom
        end
        
        local ROOM_SAVE = SAVE_MANAGER.GetRoomFloorSave(nil, false, roomListIndex)
        ROOM_SAVE.RoomEvent = chooseRandomRoomEvent()
        
        table.remove(correctRooms, randomRoomIndex)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, postNewFloor)
    
local function postNewRoom()
    local ROOM_SAVE = SAVE_MANAGER.GetRoomFloorSave()

    if ROOM_SAVE.RoomEvent then
        game:GetHUD():ShowFortuneText(Resouled:GetRoomEvent(ROOM_SAVE.RoomEvent).Name)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, postNewRoom)

local function preRoomExit()
    local ROOM_SAVE = SAVE_MANAGER.GetRoomFloorSave()
    if ROOM_SAVE.RoomEvent then
        if not Resouled:GetRoomEventByID(ROOM_SAVE.RoomEvent).NoDespawn then
            ROOM_SAVE.RoomEvent = nil
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_ROOM_EXIT, preRoomExit)

local COMMAND = {
    Name = "roomevent",
    Description = "Forces a room event to a specified room index or based on relative door position in the room you're currently in",
    HelpText = "Usage: "
}

Console.RegisterCommand(COMMAND.Name, "Forces a room event to a specified room index or based on relative  door position in the room you're currently in", "help text", false, AutocompleteType.CUSTOM)

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
            Resouled:LogError("Room event with ID: "..tostring(params[1]).." hasn't been registered.")
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

Resouled:RunAfterImports(function ()
    for _, roomEvent in ipairs(Resouled:GetRoomEvents()) do
        table.insert(autocompleteTable, {tostring(roomEvent.Id), roomEvent.Name})
    end
end)

local function roomEventCommandAutocomplete()
    return autocompleteTable
end
---@diagnostic disable-next-line: param-type-mismatch
Resouled:AddCallback(ModCallbacks.MC_CONSOLE_AUTOCOMPLETE, roomEventCommandAutocomplete, COMMAND.Name)