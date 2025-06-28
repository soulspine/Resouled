local WHITE_PROGLOTTID = Isaac.GetItemIdByName("White Proglottid")
local PROGLOTTID_VARIANT = Isaac.GetEntityVariantByName("White Proglottid")
local PROGLOTTID_SUBTYPE = Isaac.GetEntitySubTypeByName("White Proglottid")

---@param player EntityPlayer
local function onCacheEval(_, player)
    player:CheckFamiliar(PROGLOTTID_VARIANT, player:GetCollectibleNum(WHITE_PROGLOTTID), player:GetCollectibleRNG(WHITE_PROGLOTTID), nil, PROGLOTTID_SUBTYPE)
end
Resouled:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, onCacheEval, CacheFlag.CACHE_FAMILIARS)

---@param familiar EntityFamiliar
local function onFamiliarInit(_, familiar)
    if familiar.SubType == PROGLOTTID_SUBTYPE then
        familiar:GetSprite():ReplaceSpritesheet(0, "gfx/familiar/white_proglottid.png", true)
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