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
    RED_CHAMPIONS = "Red Champions",
    SHADOW_OF_WAR = "Shadow of War",
    STATIC_SHOCK = "Static Shock",
    SPOILS_OF_WAR = "Spoils of War",
    MAGGYS_BLESSING = "Maggy's Blessing",
    SAMSONS_BLESSING = "Samson's Blessing",
    RED_VISE = "Red Vise",
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
    [9] = Resouled.RoomEvents.RED_CHAMPIONS,
    [10] = Resouled.RoomEvents.SHADOW_OF_WAR,
    [11] = Resouled.RoomEvents.STATIC_SHOCK,
    [12] = Resouled.RoomEvents.SPOILS_OF_WAR,
    [13] = Resouled.RoomEvents.MAGGYS_BLESSING,
    [14] = Resouled.RoomEvents.SAMSONS_BLESSING,
    [15] = Resouled.RoomEvents.RED_VISE,
}

local BOSS_ROOM_BLACKLIST = {
    [4] = true,
}

local BOSS_ROOM_ONLY = {
    [12] = true,
}

local ROOM_EVENTS_DESPAWN_BLACKLIST = {
    [Resouled.RoomEvents.BUTTER_FINGERS] = true,
    [Resouled.RoomEvents.SHADOW_OF_WAR] = true,
    [Resouled.RoomEvents.STATIC_SHOCK] = true,
}

--local ROOM_EVENT_CHANCE = 0.005
local ROOM_EVENT_CHANCE = 1

local function postNewRoom()
    local ROOM_SAVE = SAVE_MANAGER.GetRoomFloorSave()
    local room = Game():GetRoom()
    local roomType = room:GetType()
    
    if ROOM_SAVE.RoomEvent then
        if ROOM_SAVE.RoomEvent == "Null" then
            return
        end
    end
    
    if not ROOM_SAVE.RoomEvent then
        local rng = RNG(room:GetAwardSeed())
        
        local randomFloat = rng:RandomFloat()
        
        if randomFloat < ROOM_EVENT_CHANCE then

            local pickupsPresent = false
            local tLostPresent = false

            ---@param entity Entity
            Resouled.Iterators:IterateOverRoomEntities(function(entity)
                local pickup = entity:ToPickup()
                if pickup then
                    pickupsPresent = true
                end
            end)

            ---@param player EntityPlayer
            Resouled.Iterators:IterateOverPlayers(function(player)
                if player:GetPlayerType() == PlayerType.PLAYER_THELOST_B then
                    tLostPresent = true
                end
            end)
            
            ::RollRoomEvent::

            Resouled:NewSeed()
            local randomNum = rng:RandomInt(#RoomEvents) + 1
            --local randomNum = 14



            if (roomType == RoomType.ROOM_BOSS and BOSS_ROOM_BLACKLIST[randomNum]) or
            tLostPresent or (randomNum == 6 and not pickupsPresent) or
            (BOSS_ROOM_ONLY[randomNum] and roomType ~= RoomType.ROOM_BOSS) then
                goto RollRoomEvent
            end

            ROOM_SAVE.RoomEvent = RoomEvents[randomNum]
            
            Game():GetHUD():ShowFortuneText(ROOM_SAVE.RoomEvent)
        end
    else
        if not ROOM_EVENTS_DESPAWN_BLACKLIST[ROOM_SAVE.RoomEvent] then
            ROOM_SAVE.RoomEvent = "Null"
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, postNewRoom)

local function preNewRoom()
    local ROOM_SAVE = SAVE_MANAGER.GetRoomFloorSave()
    if ROOM_SAVE.RoomEvent then
        if not ROOM_EVENTS_DESPAWN_BLACKLIST[ROOM_SAVE.RoomEvent] then
            ROOM_SAVE.RoomEvent = "Null"
        end
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
include("scripts.room_events.red_champions")
include("scripts.room_events.shadow_of_war")
include("scripts.room_events.static_shock")
include("scripts.room_events.spoils_of_war")
include("scripts.room_events.maggys_blessing")
include("scripts.room_events.samsons_blessing")
include("scripts.room_events.red_vise")