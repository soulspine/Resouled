local chances = Resouled.Stats.BlueKingCrownBuff.Level3Chance
local pickupMorphTable = Resouled.Stats.BlueKingCrownBuff


---@param npc EntityNPC
local function onNpcInit(_, npc)
    if not npc:IsChampion() and Resouled:ActiveBuffPresent(Resouled.Buffs.ROYAL_CROWN) then
        if not npc:IsChampion() and npc:IsActiveEnemy() and npc:IsVulnerableEnemy() and npc:IsEnemy() and Resouled:CanBeChampion(npc) then
            local rng = RNG(npc.InitSeed)
            
            if rng:RandomFloat() < chances.Champion then
                npc:MakeChampion(npc.InitSeed)
            end
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_INIT, onNpcInit)

---@param pickup EntityPickup
local function onPickupInit(_, pickup)
    if Resouled:ActiveBuffPresent(Resouled.Buffs.ROYAL_CROWN) then
        local variant = pickup.Variant
        local subType = pickup.SubType
        local rng = RNG(pickup.InitSeed)
        local randomNum = rng:RandomFloat()
        
        if randomNum > 1 - chances.Keys then
            pickup:Morph(pickup.Type, pickup.Variant, rng:RandomInt(#KeySubType) + 1)
        end

        if randomNum < chances.Pickup then
            
            if variant == PickupVariant.PICKUP_COIN and subType == CoinSubType.COIN_PENNY then
                pickup:Morph(pickup.Type, pickup.Variant, pickupMorphTable[variant][pickup.SubType][rng:RandomInt(#pickupMorphTable[variant][pickup.SubType]) + 1])
            end

            if variant == PickupVariant.PICKUP_BOMB and subType == BombSubType.BOMB_NORMAL then
                pickup:Morph(pickup.Type, pickup.Variant, pickupMorphTable[variant][pickup.SubType][rng:RandomInt(#pickupMorphTable[variant][pickup.SubType]) + 1])
            end

            if variant == PickupVariant.PICKUP_KEY and subType == KeySubType.KEY_NORMAL then
                pickup:Morph(pickup.Type, pickup.Variant, pickupMorphTable[variant][pickup.SubType][rng:RandomInt(#pickupMorphTable[variant][pickup.SubType]) + 1])
            end

            if variant == PickupVariant.PICKUP_LIL_BATTERY and subType == BatterySubType.BATTERY_MICRO then
                pickup:Morph(pickup.Type, pickup.Variant, pickupMorphTable[variant][pickup.SubType][rng:RandomInt(#pickupMorphTable[variant][pickup.SubType]) + 1])
            end

            if variant == PickupVariant.PICKUP_CHEST and subType == ChestSubType.CHEST_CLOSED then
                pickup:Morph(pickup.Type, pickupMorphTable[variant][rng:RandomInt(#pickupMorphTable[variant]) + 1], pickup.SubType)
            end
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, onPickupInit)

Resouled:AddCallback(ModCallbacks.MC_POST_GAME_END, function()
    if Resouled:ActiveBuffPresent(Resouled.Buffs.ROYAL_CROWN) then
        Resouled:RemoveActiveBuff(Resouled.Buffs.ROYAL_CROWN)
    end
end)

Resouled:AddBuffDescription(Resouled.Buffs.ROYAL_CROWN, Resouled.EID:AutoIcons("Enemies have a 5% chance to turn into champions, rare pickup and chests appear 7.5% more often, keys spawn 5% more"))