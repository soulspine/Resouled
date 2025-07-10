local PINK_PROGLOTTID = Isaac.GetItemIdByName("Pink Proglottid")
local PROGLOTTID_VARIANT = Isaac.GetEntityVariantByName("Pink Proglottid")
local PROGLOTTID_SUBTYPE = Isaac.GetEntitySubTypeByName("Pink Proglottid")

---@param player EntityPlayer
---@param cacheFlag CacheFlag
local function onCacheEval(_, player, cacheFlag)
    player:CheckFamiliar(PROGLOTTID_VARIANT, player:GetCollectibleNum(PINK_PROGLOTTID) + player:GetEffects():GetCollectibleEffectNum(PINK_PROGLOTTID), player:GetCollectibleRNG(PINK_PROGLOTTID), Isaac.GetItemConfig():GetCollectible(PINK_PROGLOTTID), PROGLOTTID_SUBTYPE)
end
Resouled:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, onCacheEval, CacheFlag.CACHE_FAMILIARS)

---@param familiar EntityFamiliar
local function onFamiliarInit(_, familiar)
    if familiar.SubType == PROGLOTTID_SUBTYPE then
        familiar:GetSprite():ReplaceSpritesheet(0, "gfx/familiar/pink_proglottid.png", true)
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