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
    MIGHT_FOR_THE_MEEK = 30,
    PITY_FOR_THE_POOR = 31,
    GUPPYS_PIECES = 32,
    THE_ISAAC_OF_ISAAC_ISAAC = 33,
    SPIDER_WEBS = 34,
}

---@return boolean
local filters = {
    PICKUPS_PRESENT = function()
        local pickupPresent = false
        ---@param entity Entity
        Resouled.Iterators:IterateOverRoomEntities(function(entity)
            local pickup = entity:ToPickup()
            if pickup then
                pickupPresent = true
            end
        end)
        return pickupPresent
    end,
    ENEMIES_PRESENT = function()
        local enemyPresent = false
        ---@param entity Entity
        Resouled.Iterators:IterateOverRoomEntities(function(entity)
            local npc = entity:ToNPC()
            if npc then
                if npc:IsEnemy() and npc:IsActiveEnemy() then
                    if not enemyPresent then
                        enemyPresent = true
                    end
                end
            end
        end)
        return enemyPresent
    end,
    ROOM_NOT_CLEAR = function()
        local room = Game():GetRoom()
        local clear = room:IsClear()
        if clear == true then
            return false
        else
            return true
        end
    end,
    NO_BOSS_ROOM = function()
        local room = Game():GetRoom()
        if room:GetType() == RoomType.ROOM_BOSS then
            return false
        end
        return true
    end,
    NO_TAINTED_LOST = function()
        return PlayerManager.AnyoneIsPlayerType(PlayerType.PLAYER_THELOST_B)
    end,
    BOSS_ROOM_ONLY = function()
        local room = Game():GetRoom()
        if room:GetType() == RoomType.ROOM_BOSS then
            return true
        end
        return false
    end,
    ITEM_PRESENT = function()
        local itemPresent = false
        ---@param entity Entity
        Resouled.Iterators:IterateOverRoomEntities(function(entity)
            local pickup = entity:ToPickup()
            if pickup then
                if pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE then
                    itemPresent = true
                end
            end
        end)
        return itemPresent
    end,
    SHOP_ONLY = function()
        local room = Game():GetRoom()
        if room:GetType() == RoomType.ROOM_SHOP then
            return true
        end
        return false
    end,
    TREASURE_ONLY = function()
        local room = Game():GetRoom()
        if room:GetType() == RoomType.ROOM_TREASURE then
            return true
        end
        return false
    end,
}

Resouled:RegisterRoomEvent(Resouled.RoomEvents.ALL_HALLOWS_EVE, "All Hallow's Eve", { filters.ENEMIES_PRESENT })
Resouled:RegisterRoomEvent(Resouled.RoomEvents.ANGELIC_INTERVENTION, "Angelic Intervention", { filters.NO_TAINTED_LOST })
Resouled:RegisterRoomEvent(Resouled.RoomEvents.BLACK_CHAMPIONS, "Black Champions", { filters.ENEMIES_PRESENT })
Resouled:RegisterRoomEvent(Resouled.RoomEvents.BLESSING_OF_GLUTTONY, "Blessing of Gluttony",
    { filters.ROOM_NOT_CLEAR, filters.NO_BOSS_ROOM })
Resouled:RegisterRoomEvent(Resouled.RoomEvents.BLESSING_OF_GREED, "Blessing of Greed", { filters.ENEMIES_PRESENT })
Resouled:RegisterRoomEvent(Resouled.RoomEvents.BLESSING_OF_THE_SACK, "Blessing of The Sack", { filters.PICKUPS_PRESENT })
Resouled:RegisterRoomEvent(Resouled.RoomEvents.BLOOD_LUST, "Blood Lust",
    { filters.ENEMIES_PRESENT, filters.ROOM_NOT_CLEAR })
Resouled:RegisterRoomEvent(Resouled.RoomEvents.BUTTER_FINGERS, "Butter Fingers", {}, true)
Resouled:RegisterRoomEvent(Resouled.RoomEvents.RED_CHAMPIONS, "Red Champions", { filters.ENEMIES_PRESENT })
Resouled:RegisterRoomEvent(Resouled.RoomEvents.SHADOW_OF_WAR, "Shadow of War", {}, true)
Resouled:RegisterRoomEvent(Resouled.RoomEvents.STATIC_SHOCK, "Static Shock", {}, true)
Resouled:RegisterRoomEvent(Resouled.RoomEvents.SPOILS_OF_WAR, "Spoils of War", { filters.BOSS_ROOM_ONLY })
Resouled:RegisterRoomEvent(Resouled.RoomEvents.MAGGYS_BLESSING, "Maggy's Blessing", {})
Resouled:RegisterRoomEvent(Resouled.RoomEvents.SAMSONS_BLESSING, "Samson's Blessing", { filters.ENEMIES_PRESENT })
Resouled:RegisterRoomEvent(Resouled.RoomEvents.RED_VISE, "Red Vise", { filters.PICKUPS_PRESENT })
Resouled:RegisterRoomEvent(Resouled.RoomEvents.SPLASH_DAMAGE, "Splash Damage", { filters.ENEMIES_PRESENT })
Resouled:RegisterRoomEvent(Resouled.RoomEvents.EDENS_BLESSING, "Eden's Blessing", { filters.ITEM_PRESENT })
Resouled:RegisterRoomEvent(Resouled.RoomEvents.GREED_LOOMS, "Greed Looms", { filters.SHOP_ONLY }, true)
Resouled:RegisterRoomEvent(Resouled.RoomEvents.TAX_FOR_THE_MIGHTY, "Tax for The Mighty", { filters.SHOP_ONLY }, true)
Resouled:RegisterRoomEvent(Resouled.RoomEvents.SHADOW_OF_FAMINE, "Shadow of Famine", {}, true)
Resouled:RegisterRoomEvent(Resouled.RoomEvents.BLESSING_OF_STEAM, "Blessing of Steam", { filters.SHOP_ONLY }, true)
Resouled:RegisterRoomEvent(Resouled.RoomEvents.BLESSING_OF_INNER_EYE, "Blessing of Inner Eye", {})
Resouled:RegisterRoomEvent(Resouled.RoomEvents.CONJOINED_TWIN, "Conjoined Twin", {}, true)
Resouled:RegisterRoomEvent(Resouled.RoomEvents.BLOOD_MONEY, "Blood Money", {}, true)
Resouled:RegisterRoomEvent(Resouled.RoomEvents.HEAVY_IS_THE_HEAD, "Heavy is The Head", {})
Resouled:RegisterRoomEvent(Resouled.RoomEvents.BLIND_RAGE, "Blind Rage", { filters.ROOM_NOT_CLEAR })
Resouled:RegisterRoomEvent(Resouled.RoomEvents.EQUALITY, "Equality", {}, true)
Resouled:RegisterRoomEvent(Resouled.RoomEvents.ISAACS_BLESSING, "Isaac's Blessing", { filters.ITEM_PRESENT })
Resouled:RegisterRoomEvent(Resouled.RoomEvents.BUM_BO_IS_LOOSE, "Bum-Bo is loose!", {})
Resouled:RegisterRoomEvent(Resouled.RoomEvents.MIGHT_FOR_THE_MEEK, "Might for the Meek!", { filters.ENEMIES_PRESENT })
Resouled:RegisterRoomEvent(Resouled.RoomEvents.PITY_FOR_THE_POOR, "Pity for the Poor", { filters.SHOP_ONLY }, true)
Resouled:RegisterRoomEvent(Resouled.RoomEvents.GUPPYS_PIECES, "Guppy's Pieces", { filters.TREASURE_ONLY })
Resouled:RegisterRoomEvent(Resouled.RoomEvents.THE_ISAAC_OF_ISAAC_ISAAC, "The Isaac Of Isaac: Isaac",
    { filters.ENEMIES_PRESENT, filters.NO_BOSS_ROOM })
Resouled:RegisterRoomEvent(Resouled.RoomEvents.SPIDER_WEBS, "Spider Webs", {}, true)

Resouled:Log("Loaded " .. tostring(#Resouled:GetRoomEvents()) .. " room events.")

-- IMPORTING ROOM EVENT SCRIPTS
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
include("scripts.room_events.might_for_the_meek")
include("scripts.room_events.pity_for_the_poor")
include("scripts.room_events.guppys_pieces")
include("scripts.room_events.the_isaac_of_isaac_isaac")
include("scripts.room_events.spider_webs")
