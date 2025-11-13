local CONFIG = {
    ChargeIndicator = {
        Scale = 1,
        Offset = Vector(16, 16),
        Color = KColor(1, 1, 1, 1),
        Font = "font/pftempestasevencondensed.fnt",
    },
    MaxCharges = 6,
    ---@param playerDamage number
    ---@return number
    OnHitDamageFormula = function(playerDamage)
        return 0.7 * playerDamage
    end,
    ---@param playerDamage number
    ---@return number
    KnockbackImpactDamageFormula = function(playerDamage)
        return 1.2 * playerDamage
    end,
    ---@param playerDamage number
    ---@param enemyHealth number
    ---@return number
    KnockbackExplosionDamageFormula = function(playerDamage, enemyHealth)
        return 0.3 * playerDamage + 0.5 * enemyHealth
    end
}

---@param range number
local function getSizeFromRange(range)
    return (range / 40) / 6.50 --base range
end

---@param pickup EntityPickup
local function onItemSpawn(_, pickup)
    -- this runs every time an item is dropped
    -- this is why the least significant bit will be used as a flag
    -- 1 = item was picked up before
    -- 0 = item was jus spawned, initialize it to the proper use count it should have
    -- we can easily achieve that by just shifting the use range from 0-X to 1-(X+1)
    -- X = max uses specified in CONFIG

    if pickup.SubType ~= Resouled.Enums.Items.CLUB then return end
    if pickup:GetVarData() == 0 then -- first spawn
        pickup:SetVarData(CONFIG.MaxCharges + 1)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, onItemSpawn, PickupVariant.PICKUP_COLLECTIBLE)

---@param itemId CollectibleType
---@param charge integer
---@param firstTime boolean
---@param slot ActiveSlot
---@param varData integer
---@param player EntityPlayer
local function postItemGet(_, itemId, charge, firstTime, slot, varData, player)
    -- the same initializer as onItemSpawn but in case someone gets this
    -- item directly without it spawning - e.g. reroll or give command
    if itemId ~= Resouled.Enums.Items.CLUB then return end
    if varData == 0 then
        player:SetActiveVarData(CONFIG.MaxCharges + 1, slot)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, postItemGet)

---@param itemId CollectibleType
---@param rng RNG
---@param player EntityPlayer
---@param useFlags UseFlag
---@param slot ActiveSlot
local function onActiveUse(_, itemId, rng, player, useFlags, slot)
    local desc = player:GetActiveItemDesc(slot)
    if desc.VarData == 1 then return end

    local data = player:GetData()
    if not data.Resouled__ClubActive then
        data.Resouled__ClubActive = true
    else
        data.Resouled__ClubActive = nil
    end

    player:SetActiveVarData(desc.VarData - 1, slot)
end
Resouled:AddCallback(ModCallbacks.MC_USE_ITEM, onActiveUse, Resouled.Enums.Items.CLUB)

---@param player EntityPlayer
local function onPlayerUpdate(_, player)
    local data = player:GetData()
    if not data.Resouled__ClubActive then return end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, onPlayerUpdate)

local font = Font()
font:Load(CONFIG.ChargeIndicator.Font)

---@param player EntityPlayer
---@param slot ActiveSlot
---@param offset Vector
---@param alpha number
---@param scale number
---@param chargebarOffset Vector
local function activeChargeRender(_, player, slot, offset, alpha, scale, chargebarOffset)
    if player:GetActiveItem(slot) ~= Resouled.Enums.Items.CLUB then return end

    offset = offset + CONFIG.ChargeIndicator.Offset * scale
    scale = scale * CONFIG.ChargeIndicator.Scale
    local color = CONFIG.ChargeIndicator.Color
    color.Alpha = alpha

    font:DrawStringScaled(
        "x" .. tostring(player:GetActiveItemDesc(slot).VarData - 1),
        offset.X, offset.Y,
        scale, scale,
        color
    )
end
Resouled:AddCallback(ModCallbacks.MC_POST_PLAYERHUD_RENDER_ACTIVE_ITEM, activeChargeRender)

---@param npc EntityNPC
local function onEnemyDeath(_, npc)
    if npc:IsEnemy() then
        Resouled.Iterators:IterateOverPlayers(function(player)
            for slot = 0, ActiveSlot.SLOT_POCKET2 do
                local itemDesc = player:GetActiveItemDesc(slot)
                if itemDesc.Item == Resouled.Enums.Items.CLUB then
                    player:SetActiveVarData(math.min(itemDesc.VarData, CONFIG.MaxCharges) + 1, slot)
                end
            end
        end)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, onEnemyDeath)
