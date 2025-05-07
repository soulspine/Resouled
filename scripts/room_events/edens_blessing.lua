local function postNewRoom()
    if Resouled:RoomEventPresent(Resouled.RoomEvents.EDENS_BLESSING) then
        local player = Isaac.GetPlayer()
        player:SetPocketActiveItem(CollectibleType.COLLECTIBLE_D6, ActiveSlot.SLOT_POCKET2, true)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, postNewRoom)