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
}

Resouled:RegisterRoomEvent(Resouled.RoomEvents.ALL_HALLOWS_EVE, "All Hallow's Eve", {filters.ENEMIES_PRESENT, filters.ROOM_NOT_CLEAR})
Resouled:RegisterRoomEvent(Resouled.RoomEvents.ANGELIC_INTERVENTION, "Angelic Intervention", {})