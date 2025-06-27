---@enum ResouledRoomEvent
Resouled.RoomEvents = {
    ALL_HALLOWS_EVE = 1,
    ANGELIC_INTERVENTION = 2,
    BLACK_CHAMPIONS = 3,
    BLESSING_OF_GLUTTONY = 4,
    BLESSING_OF_GREED = 5,
    BLESSING_OF_THE_SACK = 6,
    BLOOD_LUST = 7,
    BUTTER_FINGERS = 8,
    RED_CHAMPIONS = 9,
    SHADOW_OF_WAR = 10,
    STATIC_SHOCK = 11,
    SPOILS_OF_WAR = 12,
    MAGGYS_BLESSING = 13,
    SAMSONS_BLESSING = 14,
    RED_VISE = 15,
    SPLASH_DAMAGE = 16,
    EDENS_BLESSING = 17,
    GREED_LOOMS = 18,
    TAX_FOR_THE_MIGHTY = 19,
    SHADOW_OF_FAMINE = 20,
    BLESSING_OF_STEAM = 21,
    BLESSING_OF_INNER_EYE = 22,
    CONJOINED_TWIN = 23,
    BLOOD_MONEY = 24,
    HEAVY_IS_THE_HEAD = 25,
    BLIND_RAGE = 26,
    EQUALITY = 27,
    ISAACS_BLESSING = 28,
    BUM_BO_IS_LOOSE = 29,
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

---@param roomEventID  ResouledRoomEvent
---@return boolean
function Resouled:CheckFilters(roomEventID)
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

---@return ResouledRoomEventDesc[]
function Resouled:GetRoomEvents()
    local out = {}
    for _, buffDesc in pairs(registeredRoomEvents) do
        table.insert(out, buffDesc)
    end
    return out
end

local BASE_ROOM_EVENT_NUM_PER_FLOOR = 2
local ROOM_EVENTS_TO_ADD_PER_STAGE = 1

local function postNewFloor()
    if Game():GetLevel():GetStage() == 9 or Game():GetLevel():GetStage() == 1 or Game():GetLevel():GetStage() == 2 or Game():GetLevel():GetStage() == 13 then --HUSH and no basement and no home
        return
    end
    local RUN_SAVE = SAVE_MANAGER.GetRunSave()
    local rooms = Game():GetLevel():GetRooms()
    local roomEventsToAdd = (Game():GetLevel():GetStage()+1)//2

    if not RUN_SAVE.ResouledRoomEventsForThisChapter then
        RUN_SAVE.ResouledRoomEventsForThisChapter = BASE_ROOM_EVENT_NUM_PER_FLOOR + roomEventsToAdd * ROOM_EVENTS_TO_ADD_PER_STAGE
    end

    if not RUN_SAVE.ResouledRoomEventsFloorCount then
        RUN_SAVE.ResouledRoomEventsFloorCount = 1
    end

    if RUN_SAVE.ResouledRoomEventsForThisChapter == 0 then
        RUN_SAVE.ResouledRoomEventsForThisChapter = BASE_ROOM_EVENT_NUM_PER_FLOOR + roomEventsToAdd * ROOM_EVENTS_TO_ADD_PER_STAGE
    end
    
    local rng = RNG()
    local correctRooms = {}
    rng:SetSeed(Game():GetLevel():GetDevilAngelRoomRNG():GetSeed())
    
    local roomEventsThisFloor
    if RUN_SAVE.ResouledRoomEventsFloorCount%2 == 1 then
        roomEventsThisFloor = rng:RandomInt(RUN_SAVE.ResouledRoomEventsForThisChapter)
    elseif RUN_SAVE.ResouledRoomEventsFloorCount%2 == 0 then
        roomEventsThisFloor = RUN_SAVE.ResouledRoomEventsForThisChapter
    end
        
    
    for i = 0, rooms.Size-1 do
        local room = rooms:Get(i)
        table.insert(correctRooms, room.ListIndex)
    end
        
    rng:SetSeed(Game():GetLevel():GetDevilAngelRoomRNG():GetSeed())
    
    if roomEventsThisFloor == nil then
        roomEventsThisFloor = 1
    end

    for _ = 1, roomEventsThisFloor do
        ::RollRoom::
        Resouled:NewSeed()
        
        local randomRoomIndex = rng:RandomInt(#correctRooms)
        local roomGridIndex = correctRooms[randomRoomIndex]
        
        if correctRooms[randomRoomIndex] == nil then
            goto RollRoom
        end
        
        local ROOM_SAVE = SAVE_MANAGER.GetRoomFloorSave(nil, false, roomGridIndex)
        ROOM_SAVE.ResouledSpawnRoomEvent = true
        
        table.remove(correctRooms, randomRoomIndex)
    end
    
    RUN_SAVE.ResouledRoomEventsFloorCount = RUN_SAVE.ResouledRoomEventsFloorCount + 1
    RUN_SAVE.ResouledRoomEventsForThisChapter = RUN_SAVE.ResouledRoomEventsForThisChapter - roomEventsThisFloor
end
Resouled:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, postNewFloor)
    
local function postNewRoom()
    local ROOM_SAVE = SAVE_MANAGER.GetRoomFloorSave()
    local room = Game():GetRoom()
    
    if ROOM_SAVE.RoomEvent then
        if ROOM_SAVE.RoomEvent == nil then
            return
        end
    end
    
    if not ROOM_SAVE.RoomEvent and ROOM_SAVE.ResouledSpawnRoomEvent then
        local rng = RNG(room:GetAwardSeed())
        ::RollRoomEvent::
        
        Resouled:NewSeed()
        local randomNum = rng:RandomInt(#Resouled:GetRoomEvents()) + 1
        --local randomNum = 29
        
        
        if Resouled:CheckFilters(randomNum) == false then
            goto RollRoomEvent
        end
        
        ROOM_SAVE.RoomEvent = randomNum
        
        Game():GetHUD():ShowFortuneText(Resouled:GetRoomEvent(randomNum).Name)
    elseif ROOM_SAVE.RoomEvent then
        if not Resouled:GetRoomEventByID(ROOM_SAVE.RoomEvent).NoDespawn then
            ROOM_SAVE.RoomEvent = nil
            ROOM_SAVE.ResouledSpawnRoomEvent = nil
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, postNewRoom)

local function preNewRoom()
    local ROOM_SAVE = SAVE_MANAGER.GetRoomFloorSave()
    if ROOM_SAVE.RoomEvent then
        if not Resouled:GetRoomEventByID(ROOM_SAVE.RoomEvent).NoDespawn then
            ROOM_SAVE.RoomEvent = nil
            ROOM_SAVE.ResouledSpawnRoomEvent = nil
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_NEW_ROOM, preNewRoom)

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

include("scripts.room_events.all_hallows_eve")
include("scripts.room_events.angelic_intervention")
include("scripts.room_events.black_champions")
include("scripts.room_events.blessing_of_gluttony")
include("scripts.room_events.blessing_of_greed")
include("scripts.room_events.blessing_of_the_sack")
include("scripts.room_events.blood_lust")
include("scripts.room_events.butter_fingers")
include("scripts.room_events.red_champions")
include("scripts.room_events.shadow_of_war")
include("scripts.room_events.static_shock")
include("scripts.room_events.spoils_of_war")
include("scripts.room_events.maggys_blessing")
include("scripts.room_events.samsons_blessing")
include("scripts.room_events.red_vise")
include("scripts.room_events.splash_damage")
include("scripts.room_events.edens_blessing")
include("scripts.room_events.greed_looms")
include("scripts.room_events.tax_for_the_mighty")
include("scripts.room_events.shadow_of_famine")
include("scripts.room_events.blessing_of_steam")
include("scripts.room_events.blessing_of_the_inner_eye")
include("scripts.room_events.conjoined_twin")
include("scripts.room_events.blood_money")
include("scripts.room_events.heavy_is_the_head")
include("scripts.room_events.blind_rage")
include("scripts.room_events.equality")
include("scripts.room_events.isaacs_blessing")
include("scripts.room_events.bum_bo_is_loose")