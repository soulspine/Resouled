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
        local tLostPresent = PlayerManager.AnyoneIsPlayerType(PlayerType.PLAYER_THELOST_B)
        return tLostPresent
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
}

Resouled:RegisterRoomEvent(Resouled.RoomEvents.ALL_HALLOWS_EVE, "All Hallow's Eve", {filters.ENEMIES_PRESENT})
Resouled:RegisterRoomEvent(Resouled.RoomEvents.ANGELIC_INTERVENTION, "Angelic Intervention", {filters.NO_TAINTED_LOST})
Resouled:RegisterRoomEvent(Resouled.RoomEvents.BLACK_CHAMPIONS, "Black Champions", {filters.ENEMIES_PRESENT})
Resouled:RegisterRoomEvent(Resouled.RoomEvents.BLESSING_OF_GLUTTONY, "Blessing of Gluttony", {filters.ROOM_NOT_CLEAR, filters.NO_BOSS_ROOM})
Resouled:RegisterRoomEvent(Resouled.RoomEvents.BLESSING_OF_GREED, "Blessing of Greed", {filters.ENEMIES_PRESENT})
Resouled:RegisterRoomEvent(Resouled.RoomEvents.BLESSING_OF_THE_SACK, "Blessing of The Sack", {filters.PICKUPS_PRESENT})
Resouled:RegisterRoomEvent(Resouled.RoomEvents.BLOOD_LUST, "Blood Lust", {filters.ENEMIES_PRESENT, filters.ROOM_NOT_CLEAR})
Resouled:RegisterRoomEvent(Resouled.RoomEvents.BUTTER_FINGERS, "Butter Fingers", {}, true)
Resouled:RegisterRoomEvent(Resouled.RoomEvents.RED_CHAMPIONS, "Red Champions", {filters.ENEMIES_PRESENT})
Resouled:RegisterRoomEvent(Resouled.RoomEvents.SHADOW_OF_WAR, "Shadow of War", {}, true)
Resouled:RegisterRoomEvent(Resouled.RoomEvents.STATIC_SHOCK, "Static Shock", {}, true)
Resouled:RegisterRoomEvent(Resouled.RoomEvents.SPOILS_OF_WAR, "Spoils of War", {filters.BOSS_ROOM_ONLY})
Resouled:RegisterRoomEvent(Resouled.RoomEvents.MAGGYS_BLESSING, "Maggy's Blessing", {})
Resouled:RegisterRoomEvent(Resouled.RoomEvents.SAMSONS_BLESSING, "Samson's Blessing", {filters.ENEMIES_PRESENT})
Resouled:RegisterRoomEvent(Resouled.RoomEvents.RED_VISE, "Red Vise", {filters.PICKUPS_PRESENT})
Resouled:RegisterRoomEvent(Resouled.RoomEvents.SPLASH_DAMAGE, "Splash Damage", {filters.ENEMIES_PRESENT})
Resouled:RegisterRoomEvent(Resouled.RoomEvents.EDENS_BLESSING, "Eden's Blessing", {filters.ITEM_PRESENT})
Resouled:RegisterRoomEvent(Resouled.RoomEvents.GREED_LOOMS, "Greed Looms", {filters.SHOP_ONLY}, true)
Resouled:RegisterRoomEvent(Resouled.RoomEvents.TAX_FOR_THE_MIGHTY, "Tax for The Mighty", {filters.SHOP_ONLY}, true)
Resouled:RegisterRoomEvent(Resouled.RoomEvents.SHADOW_OF_FAMINE, "Shadow of Famine", {}, true)
Resouled:RegisterRoomEvent(Resouled.RoomEvents.BLESSING_OF_STEAM, "Blessing of Steam", {filters.SHOP_ONLY}, true)
Resouled:RegisterRoomEvent(Resouled.RoomEvents.BLESSING_OF_INNER_EYE, "Blessing of Inner Eye", {})
Resouled:RegisterRoomEvent(Resouled.RoomEvents.CONJOINED_TWIN, "Conjoined Twin", {}, true)
Resouled:RegisterRoomEvent(Resouled.RoomEvents.BLOOD_MONEY, "Blood Money", {}, true)
Resouled:RegisterRoomEvent(Resouled.RoomEvents.HEAVY_IS_THE_HEAD, "Heavy is The Head", {})
Resouled:RegisterRoomEvent(Resouled.RoomEvents.BLIND_RAGE, "Blind Rage", {filters.ROOM_NOT_CLEAR})
Resouled:RegisterRoomEvent(Resouled.RoomEvents.EQUALITY, "Equality", {}, true)
Resouled:RegisterRoomEvent(Resouled.RoomEvents.ISAACS_BLESSING, "Isaac's Blessing", {filters.ITEM_PRESENT})

Resouled:Log("Loaded "..tostring(#Resouled:GetRoomEvents()).." room events.")