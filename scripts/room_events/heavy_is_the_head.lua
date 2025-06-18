local SPEED_LOSS_PER_ITEM = 0.01

local function postNewRoom()
    if Resouled:RoomEventPresent(Resouled.RoomEvents.HEAVY_IS_THE_HEAD) then
        ---@param player EntityPlayer
        Resouled.Iterators:IterateOverPlayers(function(player)
            local itemCount = player:GetCollectibleCount()
            player.MoveSpeed = player.MoveSpeed - SPEED_LOSS_PER_ITEM * itemCount
            if player.MoveSpeed <= 0 then
                player.MoveSpeed = 0.01
            end
        end)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, postNewRoom)

local function preNewRoom()
    if Resouled:RoomEventPresent(Resouled.RoomEvents.HEAVY_IS_THE_HEAD) then
        ---@param player EntityPlayer
        Resouled.Iterators:IterateOverPlayers(function(player)
            local itemCount = player:GetCollectibleCount()
            player.MoveSpeed = player.MoveSpeed + SPEED_LOSS_PER_ITEM * itemCount
        end)
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_NEW_ROOM, preNewRoom)