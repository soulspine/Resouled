local playerTypeToStartItem = {
    [PlayerType.PLAYER_CAIN] = {
        Type = "Active",
        Item = Resouled.Enums.Items.SLEIGHT_OF_HAND,
        ActiveSlot = ActiveSlot.SLOT_PRIMARY,
        Charge = 0,
    },

    [PlayerType.PLAYER_BLUEBABY] = {
        Type = "Familiar",
        Item = CollectibleType.COLLECTIBLE_FOREVER_ALONE,
        Familiar = FamiliarVariant.FOREVER_ALONE,
        Amount = 1
    },

    [PlayerType.PLAYER_JACOB] = {
        Type = "Passive",
        Item = Resouled.Enums.Items.SIBLING_RIVALRY
    },

    [PlayerType.PLAYER_ISAAC_B] = {
        Type = "Active",
        Item = CollectibleType.COLLECTIBLE_SPINDOWN_DICE,
        ActiveSlot = ActiveSlot.SLOT_POCKET,
        Charge = 6
    },

    [PlayerType.PLAYER_JUDAS_B] = {
        Type = "Passive",
        Item = Resouled.Enums.Items.CEREMONIAL_BLADE
    },

    [PlayerType.PLAYER_THELOST_B] = {
        Type = "Passive",
        Item = Resouled.Enums.Items.SOULBOND
    }
}

---@param player EntityPlayer
local function onPlayerInit(_, player)
    if Resouled:GetOptionValue("Accurate Eternal Items") == "False" then return end

    local type = player:GetPlayerType()
    local config = playerTypeToStartItem[type]
    if config and config.Type ~= "Familiar" then
        if config.ActiveSlot and config.ActiveSlot > ActiveSlot.SLOT_SECONDARY then
            player:SetPocketActiveItem(config.Item, config.ActiveSlot, false)
        else
            player:AddCollectible(config.Item, config.Charge, true, config.ActiveSlot, config.VarData)
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, onPlayerInit)

---@param player EntityPlayer
local function onEvaluateCache(_, player)
    if Resouled:GetOptionValue("Accurate Eternal Items") == "False" then return end

    local type = player:GetPlayerType()
    local config = playerTypeToStartItem[type]

    if config and config.Type == "Familiar" then
        local amount = player:GetCollectibleNum(config.Item) + player:GetEffects():GetCollectibleEffectNum(config.Item) + 1
        player:CheckFamiliar(config.Familiar, amount, player:GetCollectibleRNG(config.Item))
    end
end
Resouled:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, onEvaluateCache, CacheFlag.CACHE_FAMILIARS)