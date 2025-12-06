local function postNewRoom()
    if Resouled:RoomEventPresent(Resouled.RoomEvents.MAGGYS_BLESSING) then
        ---@param player EntityPlayer
        Resouled.Iterators:IterateOverPlayers(function(player)
            Resouled.Player:Grant1RoomHeartContainer(player, false)
        end)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, postNewRoom)
