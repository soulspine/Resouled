local CONFIG = {
    ShootVectorTolerance = 0.4,        -- how sensitive will the shoot action be, pretty much only affects controllers, number between 0 and 1, higher is less sensitive
    SwingHitboxOffset = Vector(0, 30), -- downward vector describing base offset of the swing's hitbox with scale 1, it will be rotated accordingly
    SwingHitboxRadius = 25,
    SpinStep = 20,
    HoldOffset = Vector(0, -6),
    KnockbackVelocity = 40,
    KnockbackDamageTimeout = 30,
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
    end,
    ---@param fireDelay number
    ---@return number
    CooldownFormula = function(fireDelay)
        return 90
    end
}

local EFFECTS = {
    Club = {
        Entity = Resouled.Enums.Effects.CLUB,
        Idle = "Idle",
        Attack = { "Swing", "Swing2" }
    },
    SwingEffect = {
        Entity = Resouled.Enums.Effects.CLUB_SWING,
        Attack = { "Swoosh", "Swoosh2" }
    }
}

---@param range number
local function getSizeFromRange(range)
    return (range / 40) / 6.50 --base range
end

---@param dir Direction
---@return number
local function getTargetRotationFromDirection(dir)
    return (90 + 90 * dir) % 360
end

---@param dir Direction
---@return Vector
local function getPositionOffsetFromDirection(dir)
    if dir == Direction.DOWN or dir == Direction.RIGHT then
        return Vector(0, 1)
    elseif dir == Direction.UP or dir == Direction.LEFT then
        return Vector(0, -1)
    end
    return Vector.Zero
end

---@param player EntityPlayer
---@return EntityRef
local function spawnClub(player)
    local club = Game():Spawn(
        EFFECTS.Club.Entity.Type,
        EFFECTS.Club.Entity.Variant,
        player.Position,
        Vector.Zero,
        player,
        EFFECTS.Club.Entity.SubType,
        Resouled:NewSeed()
    )
    club:AddEntityFlags(EntityFlag.FLAG_PERSISTENT)
    club:GetSprite():Play(EFFECTS.Club.Idle, true)
    return EntityRef(club)
end

---@param player EntityPlayer
---@param left boolean
local function spawnSwing(player, left, rotation)
    local effect = Game():Spawn(
        EFFECTS.SwingEffect.Entity.Type,
        EFFECTS.SwingEffect.Entity.Variant,
        player.Position,
        Vector.Zero,
        player,
        EFFECTS.SwingEffect.Entity.SubType,
        Resouled:NewSeed()
    )

    effect.Parent = player

    effect.SpriteRotation = rotation
    effect.SpriteScale = Vector(1, 1) * getSizeFromRange(player.TearRange)

    local sprite = effect:GetSprite()
    sprite:Play(left and EFFECTS.SwingEffect.Attack[1] or EFFECTS.SwingEffect.Attack[2], true)
end

---@param pickup EntityPickup
local function onItemSpawn(_, pickup)
    -- this runs every time an item is dropped
    -- this is why range 0-1 will be used as a flag
    -- 1 = item was picked up before so dont initialize
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
    if not data.Resouled__Club then
        data.Resouled__Club = {
            Entity = spawnClub(player),
            Cooldown = 0,
            AttackString = 0,
            Slot = slot,
        }
        player:SetCanShoot(false)
    else
        player:SetCanShoot(true)
        data.Resouled__Club = nil
    end
end
Resouled:AddCallback(ModCallbacks.MC_USE_ITEM, onActiveUse, Resouled.Enums.Items.CLUB)

---@param player EntityPlayer
local function onPlayerUpdate(_, player)
    local data = player:GetData().Resouled__Club
    if not data then return end

    local itemDesc = player:GetActiveItemDesc(data.Slot)
    if itemDesc.Item ~= Resouled.Enums.Items.CLUB or itemDesc.VarData == 1 then
        player:GetData().Resouled__Club = nil
        player:SetCanShoot(true)
        return
    end

    ---@type Entity
    local club = data.Entity.Entity
    -- updating position has to happen on player updates because effect updates are less frequent and it looks choppy
    local clubSprite = club:GetSprite()
    club.SpriteScale = player.SpriteScale
    club.PositionOffset = CONFIG.HoldOffset * player.SpriteScale
    club.Position = player.Position + getPositionOffsetFromDirection(player:GetHeadDirection())

    data.Cooldown = math.max(0, data.Cooldown - 1)

    local shootVector = player:GetShootingJoystick()
    if data.Cooldown == 0 and shootVector:Length() > CONFIG.ShootVectorTolerance then
        data.Cooldown = CONFIG.CooldownFormula(player.MaxFireDelay)
        clubSprite:Play(data.AttackString % 2 == 0 and EFFECTS.Club.Attack[1] or EFFECTS.Club.Attack[2], true)
        spawnSwing(player, data.AttackString % 2 == 0, (shootVector:GetAngleDegrees() - 90) % 360)
        data.AttackString = (data.AttackString + 1) % 2
        player:SetActiveVarData(itemDesc.VarData - 1, data.Slot)
    end
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

-- EFFECT CLUB
---@param effect EntityEffect
local function onClubEffectInit(_, effect)
    if not Resouled:MatchesEntityDesc(effect, EFFECTS.Club.Entity) then return end
    local distance = math.huge
    Resouled.Iterators:IterateOverPlayers(function(player)
        local newDistance = player.Position:Distance(effect.Position)
        if newDistance < distance then
            effect.Parent = player
            distance = newDistance
        end
    end)
end
Resouled:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, onClubEffectInit, EFFECTS.Club.Entity.Variant)

---@param effect EntityEffect
local function onClubEffectRender(_, effect)
    if not Resouled:MatchesEntityDesc(effect, EFFECTS.Club.Entity) then return end
    if not effect.Parent then
        effect:Remove()
        return
    end

    local parentData = effect.Parent:GetData()
    if not parentData.Resouled__Club then
        effect:Remove()
        return
    end

    if GetPtrHash(parentData.Resouled__Club.Entity.Entity) ~= GetPtrHash(effect) then
        effect:Remove()
        return
    end

    local sprite = effect:GetSprite()

    local targetRotation = getTargetRotationFromDirection(effect.Parent:ToPlayer():GetHeadDirection())

    sprite.Rotation = (sprite.Rotation + 360) % 360

    -- TODO MAKE THIS LOOK BETTER

    if sprite.Rotation ~= targetRotation then
        local diff = (targetRotation - sprite.Rotation + 540) % 360 - 180

        if math.abs(diff) <= CONFIG.SpinStep then
            sprite.Rotation = targetRotation
        else
            sprite.Rotation = sprite.Rotation + (diff < 0 and -1 or 1) * CONFIG.SpinStep
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_EFFECT_RENDER, onClubEffectRender, EFFECTS.Club.Entity.Variant)

-- EFFECT SWING
---@param effect EntityEffect
local function onSwingEffectUpdate(_, effect)
    if not Resouled:MatchesEntityDesc(effect, EFFECTS.SwingEffect.Entity) then return end
    effect.Position = effect.Parent.Position

    local data = effect:GetData()

    local enemies = Isaac.FindInRadius(
        effect.Position + CONFIG.SwingHitboxOffset:Rotated(effect.SpriteRotation) * effect.SpriteScale,
        CONFIG.SwingHitboxRadius * math.max(effect.SpriteScale.X, effect.SpriteScale.Y), EntityPartition.ENEMY)

    for _, enemy in ipairs(enemies) do
        if not data.Resouled__ClubEffectEnemiesHit then
            data.Resouled__ClubEffectEnemiesHit = {}
        end

        if not data.Resouled__ClubEffectEnemiesHit[GetPtrHash(enemy)] then
            ---@diagnostic disable-next-line: param-type-mismatch
            if Resouled:IsValidEnemy(enemy:ToNPC()) then
                enemy:TakeDamage(CONFIG.OnHitDamageFormula(effect.Parent:ToPlayer().Damage), 0, EntityRef(effect.Parent),
                    0)

                local removeFlag = false

                if not enemy:HasEntityFlags(EntityFlag.FLAG_SLIPPERY_PHYSICS) then
                    removeFlag = true
                    enemy:AddEntityFlags(EntityFlag.FLAG_SLIPPERY_PHYSICS)
                end

                enemy:GetData().Resouled__ClubKnockback = {
                    Timeout = CONFIG.KnockbackDamageTimeout,
                    RemoveFlag = removeFlag,
                }
            end
            data.Resouled__ClubEffectEnemiesHit[GetPtrHash(enemy)] = true
            enemy.Velocity = enemy.Velocity +
                Vector(0, CONFIG.KnockbackVelocity):Rotated(
                    (enemy.Position - effect.Parent.Position):GetAngleDegrees() - 90)
        end
    end

    local sprite = effect:GetSprite()
    if sprite:IsFinished(sprite:GetAnimation()) then
        effect:Remove()
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_EFFECT_UPDATE, onSwingEffectUpdate, EFFECTS.SwingEffect.Entity.Variant)

---@param npc EntityNPC
local function onNpcUpdate(_, npc)
    local data = npc:GetData().Resouled__ClubKnockback
    if not data then return end

    data.Timeout = math.max(data.Timeout - 1, 0)

    if data.Timeout == 0 then
        if data.RemoveFlag then
            npc:ClearEntityFlags(EntityFlag.FLAG_SLIPPERY_PHYSICS)
        end

        npc:GetData().Resouled__ClubKnockback = nil
    end
end
Resouled:AddCallback(ModCallbacks.MC_NPC_UPDATE, onNpcUpdate)
