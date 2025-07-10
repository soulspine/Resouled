local BLACK_PROGLOTTID = Isaac.GetItemIdByName("Black Proglottid")
local PROGLOTTID_VARIANT = Isaac.GetEntityVariantByName("Black Proglottid")
local PROGLOTTID_SUBTYPE = Isaac.GetEntitySubTypeByName("Black Proglottid")

---@param player EntityPlayer
---@param cacheFlag CacheFlag
local function onCacheEval(_, player, cacheFlag)
    player:CheckFamiliar(PROGLOTTID_VARIANT, player:GetCollectibleNum(BLACK_PROGLOTTID) + player:GetEffects():GetCollectibleEffectNum(BLACK_PROGLOTTID), player:GetCollectibleRNG(BLACK_PROGLOTTID), Isaac.GetItemConfig():GetCollectible(BLACK_PROGLOTTID), PROGLOTTID_SUBTYPE)
end
Resouled:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, onCacheEval, CacheFlag.CACHE_FAMILIARS)

---@param familiar EntityFamiliar
local function onFamiliarInit(_, familiar)
    if familiar.SubType == PROGLOTTID_SUBTYPE then
        familiar:GetSprite():ReplaceSpritesheet(0, "gfx/familiar/black_proglottid.png", true)
    end
end
Resouled:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, onFamiliarInit, PROGLOTTID_VARIANT)

---@param familiar EntityFamiliar
local function onFamiliarUpdate(_, familiar)
    if familiar.SubType == PROGLOTTID_SUBTYPE then
        familiar:AddToFollowers()
        familiar:FollowParent()
    end
end
Resouled:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, onFamiliarUpdate, PROGLOTTID_VARIANT)