---@param pickup EntityPickup
---@param collider Entity
local function postPickupCollision(_, pickup, collider)
    local player = collider:ToPlayer()
    if Resouled:RoomEventPresent(Resouled.RoomEvents.EQUALITY) and player then
        local playerType = player:GetPlayerType()
        if pickup.Variant == PickupVariant.PICKUP_COIN then --COINS
            player:AddBombs(1)
            player:AddKeys(1)
            if playerType== PlayerType.PLAYER_BETHANY then
                player:AddSoulCharge(1)
            elseif playerType== PlayerType.PLAYER_BLUEBABY_B then
                player:AddPoopMana(1)
            elseif playerType== PlayerType.PLAYER_BETHANY_B then
                player:AddBloodCharge(1)
            end
        end
        if pickup.Variant == PickupVariant.PICKUP_BOMB then --BOMBS
            player:AddCoins(1)
            player:AddKeys(1)
            if playerType== PlayerType.PLAYER_BETHANY then
                player:AddSoulCharge(1)
            elseif playerType== PlayerType.PLAYER_BLUEBABY_B then
                player:AddPoopMana(1)
            elseif playerType== PlayerType.PLAYER_BETHANY_B then
                player:AddBloodCharge(1)
            end
        end
        if pickup.Variant == PickupVariant.PICKUP_KEY then --KEYS
            player:AddBombs(1)
            player:AddCoins(1)
            if playerType== PlayerType.PLAYER_BETHANY then
                player:AddSoulCharge(1)
            elseif playerType== PlayerType.PLAYER_BLUEBABY_B then
                player:AddPoopMana(1)
            elseif playerType== PlayerType.PLAYER_BETHANY_B then
                player:AddBloodCharge(1)
            end
        end
        if pickup.Variant == PickupVariant.PICKUP_POOP then --POOP
            player:AddBombs(1)
            player:AddKeys(1)
            player:AddCoins(1)
            if playerType== PlayerType.PLAYER_BETHANY then
                player:AddSoulCharge(1)
            elseif playerType== PlayerType.PLAYER_BLUEBABY_B then
                player:AddPoopMana(1)
            elseif playerType== PlayerType.PLAYER_BETHANY_B then
                player:AddBloodCharge(1)
            end
        end
        if pickup.Variant == PickupVariant.PICKUP_HEART then --HEARTS
            player:AddBombs(1)
            player:AddKeys(1)
            player:AddCoins(1)
            if playerType== PlayerType.PLAYER_BLUEBABY_B then
                player:AddPoopMana(1)
            end
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PICKUP_COLLISION, postPickupCollision)