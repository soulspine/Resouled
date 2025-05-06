local PICKUP_BLACKLIST = {
    [PickupVariant.PICKUP_BED] = true,
    [PickupVariant.PICKUP_BROKEN_SHOVEL] = true,
    [PickupVariant.PICKUP_COLLECTIBLE] = true,
    [PickupVariant.PICKUP_SHOPITEM] = true,
    [PickupVariant.PICKUP_TROPHY] = true,
    [PickupVariant.PICKUP_TRINKET] = true,
}

local function postNewRoom()
    if Resouled:RoomEventPresent(Resouled.RoomEvents.BLESSING_OF_THE_SACK) then
        ---@param entity Entity
        Resouled.Iterators:IterateOverRoomEntities(function(entity)
            local pickup = entity:ToPickup()
            if pickup then
                if PICKUP_BLACKLIST[pickup.Variant] then
                    return
                end
                pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_GRAB_BAG, 0, true, false, false)
            end
        end)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, postNewRoom)