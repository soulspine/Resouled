local chances = Resouled.Stats.BlueKingCrownBuff.Level1Chance
local pickupMorphTable = Resouled.Stats.BlueKingCrownBuff

---@param npc EntityNPC
local function onNpcInit(_, npc)
    if Resouled:ActiveBuffPresent(Resouled.Buffs.BLUE_KING_CROWN) then
        Resouled:TryMakeChampion(npc)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_INIT, onNpcInit)

---@param pickup EntityPickup
local function onPickupInit(_, pickup)
    if Resouled:ActiveBuffPresent(Resouled.Buffs.BLUE_KING_CROWN) then
        local variant = pickup.Variant
        local subType = pickup.SubType
        local rng = RNG(pickup.InitSeed)
        local randomNum = rng:RandomFloat()
        
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

Resouled:AddBuffToRemoveOnRunEnd(Resouled.Buffs.BLUE_KING_CROWN, true)