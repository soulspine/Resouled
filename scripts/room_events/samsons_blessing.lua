local function postNewRoom()
    if Resouled:RoomEventPresent(Resouled.RoomEvents.SAMSONS_BLESSING) then
        ---@param player EntityPlayer
        Resouled.Iterators:IterateOverPlayers(function(player)
            player:AddCollectibleEffect(CollectibleType.COLLECTIBLE_LUSTY_BLOOD, false)
        end)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, postNewRoom)