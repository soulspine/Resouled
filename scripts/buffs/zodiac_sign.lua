local ZODIAC_SIGNS = {
    [1] = CollectibleType.COLLECTIBLE_SAGITTARIUS,
    [2] = CollectibleType.COLLECTIBLE_LEO,
    [3] = CollectibleType.COLLECTIBLE_TAURUS,
    [4] = CollectibleType.COLLECTIBLE_ARIES,
    [5] = CollectibleType.COLLECTIBLE_CANCER,
    [6] = CollectibleType.COLLECTIBLE_VIRGO,
    [7] = CollectibleType.COLLECTIBLE_LIBRA,
    [8] = CollectibleType.COLLECTIBLE_SCORPIO,
    [9] = CollectibleType.COLLECTIBLE_CAPRICORN,
    [10] = CollectibleType.COLLECTIBLE_AQUARIUS,
    [11] = CollectibleType.COLLECTIBLE_PISCES,
    [12] = CollectibleType.COLLECTIBLE_GEMINI,
}

---@param pickup EntityPickup
local function postPickupInit(_, pickup)
    if Resouled:BuffPresent(Resouled.Buffs.ZODIAC_SIGN) then
        local zodiacSign = false
        for i = 1, #ZODIAC_SIGNS do
            if ZODIAC_SIGNS[i] == pickup.SubType then
                zodiacSign = true
            end
        end
        if not zodiacSign then
            local randomInt = RNG(pickup.InitSeed):RandomInt(12) + 1
            pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, ZODIAC_SIGNS[randomInt], false, true, false)
            Resouled:RemoveBuffFromActiveSave(Resouled.Buffs.ZODIAC_SIGN)
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, postPickupInit, PickupVariant.PICKUP_COLLECTIBLE)