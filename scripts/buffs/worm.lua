Resouled:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function()
    if not Resouled:ActiveBuffPresent(Resouled.Buffs.WORM) then return end

    Resouled:GiveAllPlayersRandomWormTrinkets()
end)

---@param rng RNG
---@return TrinketType
local function getRandomWormTrinket(rng)
    return Resouled.Stats.WormTrinkets.Sorted[rng:RandomInt(#Resouled.Stats.WormTrinkets.Sorted) + 1]
end

local morphChance = 0.3

---@param pic EntityPickup
Resouled:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, function(_, pic)
    local rng = RNG(pic.InitSeed)
    if not Resouled:ActiveBuffPresent(Resouled.Buffs.WORM) or pic.Variant ~= PickupVariant.PICKUP_TRINKET or rng:PhantomFloat() >= morphChance then return end

    pic:Morph(pic.Type, pic.Variant, getRandomWormTrinket(rng))
end)

---@param pic EntityPickup
---@param collider Entity
Resouled:AddPriorityCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, CallbackPriority.LATE, function(_, pic, collider)
    local player = collider:ToPlayer()
    if not Resouled:ActiveBuffPresent(Resouled.Buffs.WORM) or not player or pic.Variant ~= PickupVariant.PICKUP_TRINKET or not Resouled.Stats.WormTrinkets.ID_Key[pic.SubType] then return end

    for i = 0, player:GetMaxTrinkets() - 1 do
        local trinket = player:GetTrinket(i)
        if trinket ~= TrinketType.TRINKET_NULL and Resouled.Stats.WormTrinkets.ID_Key[trinket] then
            player:AddSmeltedTrinket(trinket, false)
            player:TryRemoveTrinket(trinket)
        end
    end
end)

Resouled:AddBuffToRemoveOnRunEnd(Resouled.Buffs.WORM, true)