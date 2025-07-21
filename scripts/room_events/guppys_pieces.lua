local function postNewRoom()
    if Resouled:RoomEventPresent(Resouled.RoomEvents.GUPPYS_PIECES) then
        ---@param pickup EntityPickup
        Resouled.Iterators:IterateOverRoomPickups(function(pickup)
            if pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE then
                pickup:Morph(EntityType.ENTITY_PICKUP, pickup.Variant, Resouled.Stats.GuppyItems[RNG(pickup.InitSeed):RandomInt(#Resouled.Stats.GuppyItems) + 1], false, true)
            end
        end)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, postNewRoom)