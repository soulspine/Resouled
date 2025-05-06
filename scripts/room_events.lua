---@enum ResouledRoomEvents
Resouled.RoomEvents = {
    ALL_HALLOWS_EVE = "All Hallow's Eve",
    ANGELIC_INTERVENTION = "Angelic Intervention",
    BLACK_CHAMPIONS = "Black Champions",
    BLESSING_OF_GLUTTONY = "Blessing of Gluttony",
    BLESSING_OF_GREED = "Blessing of Greed",
    BLESSING_OF_THE_SACK = "Blessing of The Sack",
    BLOOD_LUST = "Blood Lust",
    BUTTER_FINGERS = "Butter Fingers",
}

local RoomEvents = {
    [1] = Resouled.RoomEvents.ALL_HALLOWS_EVE,
    [2] = Resouled.RoomEvents.ANGELIC_INTERVENTION,
    [3] = Resouled.RoomEvents.BLACK_CHAMPIONS,
    [4] = Resouled.RoomEvents.BLESSING_OF_GLUTTONY,
    [5] = Resouled.RoomEvents.BLESSING_OF_GREED,
    [6] = Resouled.RoomEvents.BLESSING_OF_THE_SACK,
    [7] = Resouled.RoomEvents.BLOOD_LUST,
    [8] = Resouled.RoomEvents.BUTTER_FINGERS,
}

local BOSS_ROOM_BLACKLIST = {
    [4] = true,
}

--local ROOM_EVENT_CHANCE = 0.005
local ROOM_EVENT_CHANCE = 1

local function postNewRoom()
    local ROOM_SAVE = SAVE_MANAGER.GetRoomFloorSave()
    local room = Game():GetRoom()
    
    if ROOM_SAVE.RoomEvent then
        if ROOM_SAVE.RoomEvent == "Null" then
            return
        end
    end
    
    if not ROOM_SAVE.RoomEvent then
        local rng = RNG(room:GetAwardSeed())
        
        local randomFloat = rng:RandomFloat()
        
        if randomFloat < ROOM_EVENT_CHANCE then
            
            ::RollRoomEvent::

            Resouled:NewSeed()
            local randomNum = rng:RandomInt(#RoomEvents) + 1

            if room:GetType() == RoomType.ROOM_BOSS and BOSS_ROOM_BLACKLIST[randomNum] then
                goto RollRoomEvent
            end

            ROOM_SAVE.RoomEvent = RoomEvents[randomNum]
            
            Game():GetHUD():ShowFortuneText(ROOM_SAVE.RoomEvent)
        end
    else
        ROOM_SAVE.RoomEvent = "Null"
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, postNewRoom)

local function preNewRoom()
    local ROOM_SAVE = SAVE_MANAGER.GetRoomFloorSave()
    if ROOM_SAVE.RoomEvent then
        ROOM_SAVE.RoomEvent = "Null"
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_NEW_ROOM, preNewRoom)

---@param event ResouledRoomEvents
---@return boolean
function Resouled:RoomEventPresent(event)
    local ROOM_SAVE = SAVE_MANAGER.GetRoomFloorSave()
    if ROOM_SAVE.RoomEvent then
        if ROOM_SAVE.RoomEvent == event then
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