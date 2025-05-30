local function postNewRoom()
    if Resouled:RoomEventPresent(Resouled.RoomEvents.ISAACS_BLESSING) then
        ---@param entity Entity
        Resouled.Iterators:IterateOverRoomEntities(function(entity)
            local pickup = entity:ToPickup()
            if pickup then
                if pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE then
                    pickup:AddCollectibleCycle(Resouled:ChooseItemFromPool(RNG(pickup.InitSeed)))
                end
            end
        end)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, postNewRoom)