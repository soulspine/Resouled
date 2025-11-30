-- I PUT THE ACTUAL LOGIC BEHIND THEIR EFFECT IN PROGLOTTIDS FILE
-- THIS JUST REPLACES THEIR SPRITESHEETS AND ADDS TEAR FLAGS

local BLACK_PROGLOTTIDS_EGG = Resouled:GetEntityByName("Black Proglottid's Egg")
local PINK_PROGLOTTIDS_EGG = Resouled:GetEntityByName("Pink Proglottid's Egg")
local WHITE_PROGLOTTIDS_EGG = Resouled:GetEntityByName("White Proglottid's Egg")
local RED_PROGLOTTIDS_EGG = Resouled:GetEntityByName("Red Proglottid's Egg")

local CLEAR_EGG_SPRITESHEET = "gfx_resouled/tears/egg_clear.png"
local PINK_EGG_SPRITESHEET = "gfx_resouled/tears/egg_pink.png"
local WHITE_EGG_SPRITESHEET = "gfx_resouled/tears/egg_white.png"

local PINK_EGG_PARTICLE = Resouled:GetEntityByName("Pink Cracked Egg Particle")
local WHITE_EGG_PARTICLE = Resouled:GetEntityByName("White Cracked Egg Particle")
local CLEAR_EGG_PARTICLE = Resouled:GetEntityByName("Clear Cracked Egg Particle")

local PINK_EGG_PARTICLE_SPRITESHEET = "gfx_resouled/effects/particles/egg_cracked_pink.png"
local WHITE_EGG_PARTICLE_SPRITESHEET = "gfx_resouled/effects/particles/egg_cracked_white.png"
local CLEAR_EGG_PARTICLE_SPRITESHEET = "gfx_resouled/effects/particles/egg_cracked_clear.png"

local EGG_SPRITESHEETS = {
    [BLACK_PROGLOTTIDS_EGG.SubType] = PINK_EGG_SPRITESHEET,
    [WHITE_PROGLOTTIDS_EGG.SubType] = WHITE_EGG_SPRITESHEET,
    [PINK_PROGLOTTIDS_EGG.SubType] = WHITE_EGG_SPRITESHEET,
    [RED_PROGLOTTIDS_EGG.SubType] = CLEAR_EGG_SPRITESHEET,
}

local PARTICLE_SPRITESHEETS = {
    [PINK_EGG_PARTICLE.SubType] = PINK_EGG_PARTICLE_SPRITESHEET,
    [WHITE_EGG_PARTICLE.SubType] = WHITE_EGG_PARTICLE_SPRITESHEET,
    [CLEAR_EGG_PARTICLE.SubType] = CLEAR_EGG_PARTICLE_SPRITESHEET,
}

local EGG_TO_PARTICLE_LOOKUP = {
    [BLACK_PROGLOTTIDS_EGG.SubType] = PINK_EGG_PARTICLE.SubType,
    [WHITE_PROGLOTTIDS_EGG.SubType] = WHITE_EGG_PARTICLE.SubType,
    [PINK_PROGLOTTIDS_EGG.SubType] = WHITE_EGG_PARTICLE.SubType,
    [RED_PROGLOTTIDS_EGG.SubType] = CLEAR_EGG_PARTICLE.SubType,
}

local EGG_HIT_SOUND = SoundEffect.SOUND_BOIL_HATCH
local EGG_HIT_SOUND_VOLUME = 1
local EGG_HIT_PARTICLE_SPAWN_COUNT_MIN = 4
local EGG_HIT_PARTICLE_SPAWN_COUNT_MAX = 5
local EGG_PARTICLE_ANIMATION_COUNT = 4 -- PARTICLES HAVE ANIMATIONS 1-4 - DIFFERENT PARTS OF THE CRACKED EGG
local EGG_PARTICLE_SPEED = 10
local EGG_PARTICLE_MAX_ROTATION_DOWNWARDS = 25
local EGG_PARTICLE_MAX_ROTATION_UPWARDS = 25
local EGG_PARTICLE_MAX_SPREAD = 45
local EGG_PARTICLE_WEIGHT = 0.6
local EGG_PARTICLE_BOUNCINESS = 0.25
local EGG_PARTICLE_FRICTION = 0.3
local EGG_PARTICLE_GRID_COLLISION = GridCollisionClass.COLLISION_SOLID

local SPRITESHEET_LAYER = 0

local ANIMATION_IDLE = "Idle"

local TEAR_FALLING_SPEED = -30
local TEAR_FALLING_ACCELERATION = 2.5
local TEAR_FLAGS = TearFlags.TEAR_SPECTRAL | TearFlags.TEAR_HOMING

--- Passed string has to be formatted like this: something_red.png, then return would be "color"
---@param str string
local function pullColorOutOfString(str)
    return str:match("_(.-)%.png$")
end

---@param tear EntityTear
local function onTearInit(_, tear)
    local targetSpritesheet = EGG_SPRITESHEETS[tear.SubType]
    if not targetSpritesheet then return end

    local sprite = tear:GetSprite()
    sprite:ReplaceSpritesheet(SPRITESHEET_LAYER, targetSpritesheet, true)
    sprite:Play(ANIMATION_IDLE, true)
    tear:AddTearFlags(TEAR_FLAGS)
    tear.FallingAcceleration = TEAR_FALLING_ACCELERATION
    tear.FallingSpeed = TEAR_FALLING_SPEED
    tear:GetData().RESOULED_PROGLOTTID_EGG_COLOR = pullColorOutOfString(targetSpritesheet)
end
Resouled:AddCallback(ModCallbacks.MC_POST_TEAR_INIT, onTearInit, BLACK_PROGLOTTIDS_EGG.Variant)

---@param effect EntityEffect
local function onEffectInit(_, effect)
    local targetSpritesheet = PARTICLE_SPRITESHEETS[effect.SubType]
    if not targetSpritesheet then return end

    local sprite = effect:GetSprite()
    sprite:ReplaceSpritesheet(SPRITESHEET_LAYER, targetSpritesheet, true)
    sprite:Play(tostring(math.random(EGG_PARTICLE_ANIMATION_COUNT)))
end
Resouled:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, onEffectInit, PINK_EGG_PARTICLE.Variant)

---@param tear EntityTear
local function onTearDeath(_, tear)
    local targetSubType = EGG_TO_PARTICLE_LOOKUP[tear.SubType]
    if not targetSubType then return end

    for _ = 1, Resouled:GetRandomParticleCount(EGG_HIT_PARTICLE_SPAWN_COUNT_MIN, EGG_HIT_PARTICLE_SPAWN_COUNT_MAX) do
        Resouled:SpawnPrettyParticles(
            PINK_EGG_PARTICLE.Variant,
            targetSubType,
            EGG_PARTICLE_SPEED,
            tear.FallingSpeed,
            EGG_PARTICLE_MAX_ROTATION_DOWNWARDS,
            EGG_PARTICLE_MAX_ROTATION_UPWARDS,
            tear.Position,
            -tear.Height,
            tear.Velocity:GetAngleDegrees(), -- DIRECTION
            EGG_PARTICLE_MAX_SPREAD,         -- SPREAD
            EGG_PARTICLE_WEIGHT,
            EGG_PARTICLE_BOUNCINESS,
            EGG_PARTICLE_FRICTION,
            EGG_PARTICLE_GRID_COLLISION
        )
    end
    SFXManager():Play(EGG_HIT_SOUND, EGG_HIT_SOUND_VOLUME)
end
Resouled:AddCallback(ModCallbacks.MC_POST_TEAR_DEATH, onTearDeath, BLACK_PROGLOTTIDS_EGG.Variant)
