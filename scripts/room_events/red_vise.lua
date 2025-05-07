---@param pickup EntityPickup
---@param collider Entity
local function postPickupCollision(_, pickup, collider)
    if Resouled:RoomEventPresent(Resouled.RoomEvents.SHADOW_OF_WAR) then
        local player = collider:ToPlayer()
        if player then
            local data = player:GetData()
            data.ResouledPickedUpPickup = true
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PICKUP_COLLISION, postPickupCollision)

local function preRoomLeave()
    if Resouled:RoomEventPresent(Resouled.RoomEvents.RED_VISE) then
        local pickupsPresent = false
        ---@param entity Entity
        Resouled.Iterators:IterateOverRoomEntities(function(entity)
            local pickup = entity:ToPickup()
            if pickup then
                pickupsPresent = true
            end
        end)

        ---@param player EntityPlayer
        Resouled.Iterators:IterateOverPlayers(function(player)
            local data = player:GetData()
            if not data.ResouledPickedUpPickup and pickupsPresent then
                player:TakeDamage(1, DamageFlag.DAMAGE_NO_PENALTIES, EntityRef(player), 1)
            else
                data.ResouledPickedUpPickup = nil
            end
        end)
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_ROOM_EXIT, preRoomLeave)