local ID = Isaac.GetEntityTypeByName("Cursed Tumor")
local VARIANT = Isaac.GetEntityVariantByName("Cursed Tumor")
local SUBTYPE = Isaac.GetEntitySubTypeByName("Cursed Tumor")

Resouled:RegisterCursedEnemyMorph(229, 0, nil, ID, VARIANT, SUBTYPE)

local SHOOT_AMOUNT = 5
local TEAR_AMOUNT = 8
local TEAR_SPEED = 5

local ATTACK_FREQUENCY = 200

local PROJECTILE_PARAMS = Resouled.Stats:GetCursedProjectileParams()
PROJECTILE_PARAMS.BulletFlags = (PROJECTILE_PARAMS.BulletFlags | ProjectileFlags.SINE_VELOCITY)
PROJECTILE_PARAMS.FallingSpeedModifier = 0.4
PROJECTILE_PARAMS.FallingAccelModifier = -0.1

---@param npc EntityNPC
local function getShootingAnimation(npc)
    if npc.Velocity.Y > 0 then
        return "ResouledShootDown"
    end
    return "ResouledShootUp"
end

---@param npc EntityNPC
local function getIdleAnimation(npc)
    if npc.Velocity.Y > 0 then
        return "FloatDown"
    end
    return "FloatUp"
end

---@param npc EntityNPC
---@param amount integer
---@param rotation number
local function fireTearsCircle(npc, amount, rotation, speed)
    local tearDirection = Vector(0, -speed):Rotated(rotation)
    for _ = 1, amount do
        npc:FireProjectiles(npc.Position, tearDirection, 0, PROJECTILE_PARAMS)
        tearDirection = tearDirection:Rotated(360/amount)
    end
end

---@param npc EntityNPC
local function onNpcUpdate(_, npc)
    if npc.Variant == VARIANT and npc.SubType == SUBTYPE then

        local data = npc:GetData()
        local sprite = npc:GetSprite()

        local animation = sprite:GetAnimation()
        local shootingAnimation = getShootingAnimation(npc)

        local shooting = animation:find("Shoot")

        sprite.FlipX = npc.Velocity.X < 0

        if not shooting then
            local idleAnim = getIdleAnimation(npc)
            if animation ~= idleAnim then
                sprite:Play(idleAnim, true)
            end
        end

        if animation ~= shootingAnimation and data.Resouled_CursedTumor and not (data.Resouled_CursedTumor < SHOOT_AMOUNT) then
            data.Resouled_CursedTumor = nil
        end

        if npc.FrameCount % ATTACK_FREQUENCY == 0 or (data.Resouled_CursedTumor and data.Resouled_CursedTumor == 0 and not shooting) then
            sprite:Play(shootingAnimation, true)
            data.Resouled_CursedTumor = 0
        end

        if sprite:IsEventTriggered("ResouledShoot") and (data.Resouled_CursedTumor and data.Resouled_CursedTumor < SHOOT_AMOUNT) then
            sprite:Play(shootingAnimation, true)
            fireTearsCircle(npc, TEAR_AMOUNT, (data.Resouled_CursedTumor%2 * (360/TEAR_AMOUNT))/2, TEAR_SPEED)
            data.Resouled_CursedTumor = data.Resouled_CursedTumor + 1
            SFXManager():Play(SoundEffect.SOUND_WHEEZY_COUGH)
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_NPC_UPDATE, onNpcUpdate, ID)

---@param entity Entity
local function postNpcTakeDMG(_, entity)
    if entity.Variant == VARIANT and entity.SubType == SUBTYPE then
        local data = entity:GetData()
        data.Resouled_CursedTumor = 0
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, postNpcTakeDMG, ID)

Resouled.StatTracker:RegisterCursedEnemy(ID, VARIANT, SUBTYPE)