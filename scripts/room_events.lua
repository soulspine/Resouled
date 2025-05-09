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
    SPLASH_DAMAGE = "Splash Damage",
    EDENS_BLESSING = "Eden's Blessing",
    GREED_LOOMS = "Greed Looms",
    TAX_FOR_THE_MIGHTY = "Tax for The Mighty",
    SHADOW_OF_FAMINE = "Shadow of Famine",
    BLESSING_OF_STEAM = "Blessing of Steam",
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
    [16] = Resouled.RoomEvents.SPLASH_DAMAGE,
    [17] = Resouled.RoomEvents.EDENS_BLESSING,
    [18] = Resouled.RoomEvents.GREED_LOOMS,
    [19] = Resouled.RoomEvents.TAX_FOR_THE_MIGHTY,
    [20] = Resouled.RoomEvents.SHADOW_OF_FAMINE,
    [21] = Resouled.RoomEvents.BLESSING_OF_STEAM,
}

local ENEMY_ONLY = {
    [1] = true,
    [3] = true,
    [5] = true,
    [7] = true,
    [9] = true,
    [16] = true,
}

local PICKUP_ONLY = {
    [6] = true,
}

local UNCLEAR_ROOM_ONLY = {
    [4] = true,
    [7] = true,
}

local BOSS_ROOM_BLACKLIST = {
    [4] = true,
}

local BOSS_ROOM_ONLY = {
    [12] = true,
}

local ITEM_IN_ROOM_ONLY = {
    [17] = true,
}

local SHOP_ONLY = {
    [18] = true,
    [19] = true,
    [21] = true,
}

local TAINTED_LOST_BLACKLIST = {
    [2] = true,
}

local ROOM_EVENTS_DESPAWN_BLACKLIST = {
    [Resouled.RoomEvents.BUTTER_FINGERS] = true,
    [Resouled.RoomEvents.SHADOW_OF_WAR] = true,
    [Resouled.RoomEvents.STATIC_SHOCK] = true,
    [Resouled.RoomEvents.GREED_LOOMS] = true,
    [Resouled.RoomEvents.TAX_FOR_THE_MIGHTY] = true,
    [Resouled.RoomEvents.BLESSING_OF_STEAM] = true,
}

local BASE_ROOM_EVENT_NUM_PER_FLOOR = 2
local ROOM_EVENTS_TO_ADD_PER_STAGE = 1

local function postNewFloor()
    if Game():GetLevel():GetStage() == 9 or Game():GetLevel():GetStage() == 1 or Game():GetLevel():GetStage() == 2 then --HUSH and no basement
        return
    end
    local RUN_SAVE = SAVE_MANAGER.GetRunSave()
    local rooms = Game():GetLevel():GetRooms()
    local roomEventsToAdd = (Game():GetLevel():GetStage()+1)//2
    if (Game():GetLevel():GetStage()+1)//2 ~= (Game():GetLevel():GetStage())//2 then
        RUN_SAVE.ResouledRoomEventsForThisChapter = BASE_ROOM_EVENT_NUM_PER_FLOOR + roomEventsToAdd * ROOM_EVENTS_TO_ADD_PER_STAGE
    end
    
    local rng = RNG()
    local correctRooms = {}
    rng:SetSeed(Game():GetLevel():GetDevilAngelRoomRNG():GetSeed())
    
    local roomEventsThisFloor
    if (Game():GetLevel():GetStage()+1)//2 ~= (Game():GetLevel():GetStage())//2 then
        roomEventsThisFloor = rng:RandomInt(RUN_SAVE.ResouledRoomEventsForThisChapter)
    else
        roomEventsThisFloor = RUN_SAVE.ResouledRoomEventsForThisChapter
    end
        
    
    for i = 0, rooms.Size-1 do
        local room = rooms:Get(i)
        table.insert(correctRooms, room.ListIndex)
    end
        
    rng:SetSeed(Game():GetLevel():GetDevilAngelRoomRNG():GetSeed())
    
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
    
    RUN_SAVE.ResouledRoomEventsForThisChapter = RUN_SAVE.ResouledRoomEventsForThisChapter - roomEventsThisFloor
end
Resouled:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, postNewFloor)
    
    local function postNewRoom()
        local ROOM_SAVE = SAVE_MANAGER.GetRoomFloorSave()
    local room = Game():GetRoom()
    
    if ROOM_SAVE.RoomEvent then
        if ROOM_SAVE.RoomEvent == "Null" then
            return
        end
    end
    
    if not ROOM_SAVE.RoomEvent and ROOM_SAVE.ResouledSpawnRoomEvent then
        local rng = RNG(room:GetAwardSeed())
        local roomType = room:GetType()
        local pickupsPresent = false
        local itemsPresent = false
        local tLostPresent = false
        local enemiesPresent = false
        local roomClear = room:IsClear()
        
        ---@param entity Entity
        Resouled.Iterators:IterateOverRoomEntities(function(entity)
            local pickup = entity:ToPickup()
            if pickup then
                pickupsPresent = true
                if pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE then
                    itemsPresent = true
                end
            end
            
            if entity:IsEnemy() and entity:IsActiveEnemy() then
                enemiesPresent = true
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
        --local randomNum = 20
        
        
        if (roomType == RoomType.ROOM_BOSS and BOSS_ROOM_BLACKLIST[randomNum]) or
        (tLostPresent and TAINTED_LOST_BLACKLIST[randomNum]) or
        (PICKUP_ONLY[randomNum] and not pickupsPresent) or
        (BOSS_ROOM_ONLY[randomNum] and roomType ~= RoomType.ROOM_BOSS) or
        (ITEM_IN_ROOM_ONLY[randomNum] and not itemsPresent) or
        (SHOP_ONLY[randomNum] and roomType ~= RoomType.ROOM_SHOP) or
        (ENEMY_ONLY[randomNum] and not enemiesPresent) or
        (UNCLEAR_ROOM_ONLY[randomNum] and roomClear)
        then
            goto RollRoomEvent
        end
        
        ROOM_SAVE.RoomEvent = RoomEvents[randomNum]
        
        Game():GetHUD():ShowFortuneText(ROOM_SAVE.RoomEvent)
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
include("scripts.room_events.splash_damage")
include("scripts.room_events.edens_blessing")
include("scripts.room_events.greed_looms")
include("scripts.room_events.tax_for_the_mighty")
include("scripts.room_events.shadow_of_famine")
include("scripts.room_events.blessing_of_steam")