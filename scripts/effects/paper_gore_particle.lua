local VARIANT = Isaac.GetEntityVariantByName("Paper Gore Particle 1")

local VELOCITY_MULTIPLIER = 0.85

local BASE_OFFSET = -25

local MIN_STARTING_OFFSET_LOSS = -30
local MAX_STARTING_OFFSET_LOSS = 1
local OFFSET_TO_LOSE_PER_RENDER = 0.2

local MIN_BOUNCE_POWER_OFFSET = -10
local MAX_BOUNCE_POWER_OFFSET = 0

local MIN_ROTATION_MID_AIR = -7
local MAX_ROTATION_MID_AIR = 7

local MIN_X_OFFSET = -15
local MAX_X_OFFSET = 15

local MIN_Y_OFFSET = -10
local MAX_Y_OFFSET = 10

local BASE_GORE_SIZE = 0.75

---@param effect EntityEffect
local function postEffectInit(_, effect)
    local sprite = effect:GetSprite()
    local data = effect:GetData()
    sprite.Rotation = math.random(1, 360)
    effect.DepthOffset = -1000
    data.ResouledOffset = BASE_OFFSET
    data.ResouledOffsetToLose = math.random(MIN_STARTING_OFFSET_LOSS, MAX_STARTING_OFFSET_LOSS)/10
    data.ResouledRotationMidAir = math.random(MIN_ROTATION_MID_AIR, MAX_ROTATION_MID_AIR)
    data.ResouledBounced = false
    effect.Scale = BASE_GORE_SIZE + RNG(effect.InitSeed):RandomFloat()/4
    effect.Size = effect.Size * effect.Scale
    effect.Position = effect.Position + Vector(math.random(MIN_X_OFFSET, MAX_X_OFFSET), math.random(MIN_Y_OFFSET, MAX_Y_OFFSET))
    effect.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
end
Resouled:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, postEffectInit, VARIANT)

---@param effect EntityEffect
local function postEffectUpdate(_, effect)
    if effect.Velocity:Length() > 0 then
        effect.Velocity = effect.Velocity * VELOCITY_MULTIPLIER
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, postEffectUpdate, VARIANT)

---@param effect EntityEffect
local function preEffectRender(_, effect)
    local data = effect:GetData()

    if data.ResouledOffset < 0 then
        data.ResouledOffset = data.ResouledOffset + data.ResouledOffsetToLose
        data.ResouledOffsetToLose = data.ResouledOffsetToLose + OFFSET_TO_LOSE_PER_RENDER
        effect.SpriteRotation = effect.SpriteRotation + data.ResouledRotationMidAir
    end

    if data.ResouledOffset >= 0 and not data.ResouledBounced then
        data.ResouledOffsetToLose = math.random(MIN_BOUNCE_POWER_OFFSET, MAX_BOUNCE_POWER_OFFSET)/10
        data.ResouledBounced = true
        data.ResouledOffset = -0.0001
        effect.Velocity = (effect.Velocity + effect.Velocity:Rotated(math.random(-30, 30))) * math.random(1, 2)
        data.ResouledRotationMidAir = -data.ResouledRotationMidAir + math.random(-3, 3)
    end

    return Vector(0, data.ResouledOffset)
end
Resouled:AddCallback(ModCallbacks.MC_PRE_EFFECT_RENDER, preEffectRender, VARIANT)