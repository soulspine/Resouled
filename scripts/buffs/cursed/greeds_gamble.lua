local PRICE_INCREASE = 1.30

local function curseActive()
    return Resouled:ActiveBuffPresent(Resouled.Buffs.GREEDS_GAMBLE) or Resouled:IsSpecialSeedEffectActive(Resouled.SpecialSeedEffects.EverythingIsCursed)
end

---@param variant integer
---@param subtype integer
---@param shopItemId integer
---@param price integer
local function onGetShopItemPrice(_, variant, subtype, shopItemId, price)
    if curseActive() and price > 0 then
        return math.floor(price * PRICE_INCREASE + 0.5)
    end
end
Resouled:AddPriorityCallback(ModCallbacks.MC_GET_SHOP_ITEM_PRICE, CallbackPriority.LATE, onGetShopItemPrice)

---@param slot EntitySlot
---@param collider Entity
local function preSlotCollision(_, slot, collider)
    if not curseActive() or PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_LUCKY_FOOT) then return end
    local player = collider:ToPlayer()
    if not player then return end

    return false
end
Resouled:AddCallback(ModCallbacks.MC_PRE_SLOT_COLLISION, preSlotCollision)