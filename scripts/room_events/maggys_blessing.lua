local function postNewRoom()
    if Resouled:RoomEventPresent(Resouled.RoomEvents.MAGGYS_BLESSING) then
        ---@param player EntityPlayer
        Resouled.Iterators:IterateOverPlayers(function(player)
            player:AddCollectible(CollectibleType.COLLECTIBLE_BREAKFAST)
            player:RemoveCollectible(CollectibleType.COLLECTIBLE_BREAKFAST)
        end)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, postNewRoom)