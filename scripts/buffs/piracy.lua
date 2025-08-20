local PIRACY_COUNTDOWN = 90
local PIRACY_DISTANCE = 30

---@param pickup EntityPickup
local function postPickupUpdate(_, pickup)
    if pickup:IsShopItem() and Game():GetRoom():GetType() == RoomType.ROOM_SHOP then
        if Resouled:ActiveBuffPresent(Resouled.Buffs.PIRACY) then
            ---@param player EntityPlayer
            Resouled.Iterators:IterateOverPlayers(function(player)
                local data = pickup:GetData()
                if player.Position:Distance(pickup.Position) < PIRACY_DISTANCE then
                    if not data.Resouled_PiracyCountdown then
                        data.Resouled_PiracyCountdown = PIRACY_COUNTDOWN
                    end

                    if data.Resouled_PiracyCountdown > 0 then
                        data.Resouled_PiracyCountdown = data.Resouled_PiracyCountdown - 1
                    end

                    
                    if data.Resouled_PiracyCountdown == 0 then
                        pickup:Morph(pickup.Type, pickup.Variant, pickup.SubType, false, true, false)
                        player:AddBrokenHearts(1)
                    end
                else
                    if data.Resouled_PiracyCountdown then
                        data.Resouled_PiracyCountdown = nil
                    end
                end
            end)
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, postPickupUpdate)

Resouled:AddCallback(ModCallbacks.MC_POST_GAME_END, function()
    if Resouled:ActiveBuffPresent(Resouled.Buffs.PIRACY) then
        Resouled:RemoveActiveBuff(Resouled.Buffs.PIRACY)
    end
end)