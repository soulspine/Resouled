local TRINKET = Isaac.GetTrinketIdByName("Mugger Bean")

local CONFIG = {
    ItemReplaceChance = 0.15,
    ItemPool = Isaac.GetPoolIdByName("muggerBeanPool"),
    FartEffects = {
        [EffectVariant.FART] = true,
        [EffectVariant.FARTWAVE] = true,
        [EffectVariant.SMOKE_CLOUD] = true,
    },
    BuffStatusEffect = Resouled.Enums.StatusEffects.MUGGER_BEAN,
    BuffDuration = 90,
    BuffRadius = 78,
    BuffFormula = function(amount)
        return 1.5 * amount + 6
    end,
    EidDescriptionPreFormat =
    "Enemies that get farted on take more damage for %s seconds#Bean items are added to all item pools"
}

Resouled.EID:AddTrinket(TRINKET,
    string.format(
        CONFIG.EidDescriptionPreFormat,
        Resouled.EID:FormatFloat(Resouled.EID:FormatFloat(CONFIG.BuffDuration / 30))
    )
)
Resouled.EID:AddTrinketConditional(TRINKET, "Resouled__MuggerBean_Golden",
    Resouled.EID.CommonConditions.HigherTrinketMult,
    function(desc)
        local mult = Resouled.EID.GetTrinketMultFromDesc(desc)
        local newDuration = CONFIG.BuffDuration * mult / 30

        desc.Description = string.format(
            CONFIG.EidDescriptionPreFormat,
            "{{ColorGold}}" .. Resouled.EID:FormatFloat(newDuration) .. "{{ColorText}}"
        )
        return desc
    end
)

local statusEffectId = 0

Resouled:RunAfterImports(function()
    for name, flag in pairs(StatusEffectLibrary.StatusFlag) do
        if name == CONFIG.BuffStatusEffect then
            statusEffectId = flag
            break
        end
    end
end)

---@param itempool ItemPoolType
---@param decrease boolean
---@param seed integer
local function onItemGet(_, itempool, decrease, seed)
    if itempool == CONFIG.ItemPool then return end -- to prevent stack overflow
    local defaultItem = 143                        -- just to know when pool is depleted, if this item is returned, its not a bean anymore
    if not PlayerManager.AnyoneHasTrinket(TRINKET) then return end

    local rng = RNG(seed, 43)
    if rng:RandomFloat() > CONFIG.ItemReplaceChance then return end

    local chosenItem = Game():GetItemPool():GetCollectible(CONFIG.ItemPool, true, rng:GetSeed(), defaultItem)
    if chosenItem ~= defaultItem then
        return chosenItem
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_GET_COLLECTIBLE, onItemGet)

---@param entity Entity
---@param amount number
---@param flags DamageFlag
---@param source EntityRef
---@param countdown integer
local function onEntityDamage(_, entity, amount, flags, source, countdown)
    local effectData = StatusEffectLibrary:GetStatusEffectData(entity, statusEffectId)
    if not effectData then return end

    local data = entity:GetData()

    if data.Resouled__MuggerBeanDamageTick then
        data.Resouled__MuggerBeanDamageTick = nil
        return
    end

    data.Resouled__MuggerBeanDamageTick = true
    entity:TakeDamage(CONFIG.BuffFormula(amount), flags, source, countdown)
    return false
end
Resouled:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, onEntityDamage)

---@param effect EntityEffect
local function onFartEffectUpdate(_, effect)
    if not CONFIG.FartEffects[effect.Variant] or not PlayerManager.AnyoneHasTrinket(TRINKET) then return end

    --- Jupiter is the only fart effect that actually has player as spawner,
    --- thats why I'm checking for highest multiplier and just applying duration based on that
    local highestMult = Resouled.AccurateStats:GetHighestTrinketMultiplier(TRINKET)

    for _, entity in ipairs(Isaac.FindInRadius(effect.Position, CONFIG.BuffRadius * math.max(effect.SpriteScale.X, effect.SpriteScale.Y), EntityPartition.ENEMY)) do
        local npc = entity:ToNPC()
        if not npc or not npc:IsVulnerableEnemy() then goto continue end
        StatusEffectLibrary:AddStatusEffect(
            npc,
            statusEffectId,
            CONFIG.BuffDuration * highestMult,
            EntityRef(Isaac.GetPlayer())
        )
        ::continue::
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, onFartEffectUpdate)
Resouled:AddCallback(ModCallbacks.MC_PRE_EFFECT_UPDATE, onFartEffectUpdate)
