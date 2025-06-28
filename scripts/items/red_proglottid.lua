local RED_PROGLOTTID = Isaac.GetItemIdByName("Red Proglottid")
local PROGLOTTID_VARIANT = Isaac.GetEntityVariantByName("Red Proglottid")
local PROGLOTTID_SUBTYPE = Isaac.GetEntitySubTypeByName("Red Proglottid")

---@param player EntityPlayer
local function onCacheEval(_, player)
    player:CheckFamiliar(PROGLOTTID_VARIANT, player:GetCollectibleNum(RED_PROGLOTTID), player:GetCollectibleRNG(RED_PROGLOTTID), nil, PROGLOTTID_SUBTYPE)
end
Resouled:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, onCacheEval, CacheFlag.CACHE_FAMILIARS)

---@param familiar EntityFamiliar
local function onFamiliarInit(_, familiar)
    if familiar.SubType == PROGLOTTID_SUBTYPE then
        familiar:GetSprite():ReplaceSpritesheet(0, "gfx/familiar/red_proglottid.png", true)
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