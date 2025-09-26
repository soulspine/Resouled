local TRINKET = Isaac.GetTrinketIdByName("Mugger Bean")

local ITEM_REPLACE_CHANCE = 0.15
local BEAN_ITEM_POOL = Isaac.GetPoolIdByName("muggerBeanPool")

local FART_EFFECTS = {
    [EffectVariant.FART] = true,
    [EffectVariant.FARTWAVE] = true,
    [EffectVariant.SMOKE_CLOUD] = true,
}

local DAMAGE_BUFF_BASE_RADIUS = 78
local DAMAGE_BUFF_DURATION = 90 -- updates
local DAMAGE_BUFF_FORMULA = function(amount)
    return 1.5 * amount + 6
end

---@param itempool ItemPoolType
---@param decrease boolean
---@param seed integer
local function onItemGet(_, itempool, decrease, seed)
    if itempool == BEAN_ITEM_POOL then return end -- to prevent stack overflow
    local defaultItem = 143
    if not PlayerManager.AnyoneHasTrinket(TRINKET) then return end

    local rng = RNG(seed, 43)
    if rng:RandomFloat() > ITEM_REPLACE_CHANCE then return end

    local chosenItem = Game():GetItemPool():GetCollectible(BEAN_ITEM_POOL, true, rng:GetSeed(), defaultItem)
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
    local data = entity:GetData()
    if not data.Resouled__MuggerBeanDurationLeft then return end

    if data.Resouled__MuggerBeanDamageTick then
        data.Resouled__MuggerBeanDamageTick = nil
        return
    end

    data.Resouled__MuggerBeanDamageTick = true
    entity:TakeDamage(DAMAGE_BUFF_FORMULA(amount), flags, source, countdown)
    return false
end
Resouled:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, onEntityDamage)

---@param npc EntityNPC
local function onNpcUpdate(_, npc)
    local data = npc:GetData()
    if not data.Resouled__MuggerBeanDurationLeft then return end

    if data.Resouled__MuggerBeanDurationLeft > 0 then
        data.Resouled__MuggerBeanDurationLeft = data.Resouled__MuggerBeanDurationLeft - 1
    else
        data.Resouled__MuggerBeanDurationLeft = nil
    end
end
Resouled:AddCallback(ModCallbacks.MC_NPC_UPDATE, onNpcUpdate)

---@param effect EntityEffect
local function onFartEffectUpdate(_, effect)
    print(effect.Variant, effect.SubType)
    if not FART_EFFECTS[effect.Variant] or not PlayerManager.AnyoneHasTrinket(TRINKET) then return end

    for _, entity in ipairs(Isaac.FindInRadius(effect.Position, DAMAGE_BUFF_BASE_RADIUS * math.max(effect.SpriteScale.X, effect.SpriteScale.Y), EntityPartition.ENEMY)) do
        local npc = entity:ToNPC()
        if not npc or not npc:IsVulnerableEnemy() then goto continue end
        local data = npc:GetData()
        data.Resouled__MuggerBeanDurationLeft = DAMAGE_BUFF_DURATION
        ::continue::
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, onFartEffectUpdate)
Resouled:AddCallback(ModCallbacks.MC_PRE_EFFECT_UPDATE, onFartEffectUpdate)
