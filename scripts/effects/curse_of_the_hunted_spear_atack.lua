local COTH_TYPE = Isaac.GetEntityTypeByName("COTH attack spear")
local COTH_VARIANT = Isaac.GetEntityVariantByName("COTH attack spear")

local HITBOX_TYPE = Isaac.GetEntityTypeByName("ResouledHitbox")
local HITBOX_VARIANT = Isaac.GetEntityVariantByName("ResouledHitbox")
local HITBOX_SUBTYPE = Isaac.GetEntityTypeByName("ResouledHitbox")

local SPEAR_SPEED = 30

---@param effect EntityEffect
local function postEffectInit(_, effect)
    local data = effect:GetData()
    effect.SpriteRotation = (Game():GetNearestPlayer(effect.Position).Position - effect.Position):Normalized():GetAngleDegrees()
    data.ResouledHitbox = Game():Spawn(HITBOX_TYPE, HITBOX_VARIANT, effect.Position, Vector.Zero, effect, HITBOX_SUBTYPE, effect.InitSeed)
    data.ResouledHitbox.Size = 15
end
Resouled:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, postEffectInit, COTH_VARIANT)

---@param effect EntityEffect
local function postEffectUpdate(_, effect)
    local sprite = effect:GetSprite()
    local data = effect:GetData()
    if data.ResouledTrail then
        data.ResouledHitbox:Remove()
        for i = 0, sprite:GetLayerCount() - 1 do
            sprite:GetLayer(i):SetRotation(math.random(0, 360))
        end
        data.ResouledTrail = nil
    end
    if sprite:IsPlaying("Idle") then
        data.ResouledHitbox.Position = effect.Position
        effect.Velocity = Vector(1, 0):Normalized():Rotated(effect.SpriteRotation) * SPEAR_SPEED * (Game():GetNearestPlayer(effect.Position).MoveSpeed)
        effect.Position = effect.Position + effect.Velocity

        if sprite:WasEventTriggered("ResouledTrail") then
            local trail = Game():Spawn(COTH_TYPE, COTH_VARIANT, effect.Position - effect.Velocity, Vector.Zero, effect, 0, effect.InitSeed)
            trail:GetSprite():Play("Trail", true)
            trail:GetData().ResouledTrail = true
            trail.SpriteRotation = effect.SpriteRotation
            trail.DepthOffset = effect.DepthOffset + 10
        end
        
        if Game():GetNearestPlayer(effect.Position).Position:Distance(effect.Position) > 1500 then
            effect:Remove()
        end
    end

    if sprite:IsFinished("Trail") then
        effect:Remove()
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, postEffectUpdate, COTH_VARIANT)