local SPEED_LOSS_PER_ITEM = 0.01

local function postNewRoom()
    if Resouled:RoomEventPresent(Resouled.RoomEvents.HEAVY_IS_THE_HEAD) then
        ---@param player EntityPlayer
        Resouled.Iterators:IterateOverPlayers(function(player)
            local itemCount = player:GetCollectibleCount()
            player:GetData().Resouled_HITSNormalSpeed = player.MoveSpeed
            player.MoveSpeed = player.MoveSpeed - SPEED_LOSS_PER_ITEM * itemCount
            if player.MoveSpeed <= 0 then
                player.MoveSpeed = 0.01
            end
        end)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, postNewRoom)

local function preNewRoom()
    ---@param player EntityPlayer
    Resouled.Iterators:IterateOverPlayers(function(player)
        local data = player:GetData()
        if data.Resouled_HITSNormalSpeed then
            player.MoveSpeed = data.Resouled_HITSNormalSpeed
            data.Resouled_HITSNormalSpeed = nil
        end
    end)
end
Resouled:AddCallback(ModCallbacks.MC_PRE_ROOM_EXIT, preNewRoom)