local COTH_TYPE = Isaac.GetEntityTypeByName("COTH attack claws")
local COTH_VARIANT = Isaac.GetEntityVariantByName("COTH attack claws")

local HITBOX_TYPE = Isaac.GetEntityTypeByName("ResouledHitbox")
local HITBOX_VARIANT = Isaac.GetEntityVariantByName("ResouledHitbox")
local HITBOX_SUBTYPE = Isaac.GetEntityTypeByName("ResouledHitbox")

local ATTACK_DISTANCE_FROM_CENTER = 10

---@param effect EntityEffect
local function postEffectInit(_, effect)
    effect.SpriteRotation = (Game():GetNearestPlayer(effect.Position).Position - effect.Position):Normalized():GetAngleDegrees() + 90
end
Resouled:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, postEffectInit, COTH_VARIANT)

---@param effect EntityEffect
local function postEffectUpdate(_, effect)
        local sprite = effect:GetSprite()
        local data = effect:GetData()
        if sprite:IsFinished("Idle") then
            effect:Remove()
        end
        
    if sprite:GetFrame() == 5 then
            local HITBOX_OFFSET = Vector(-45, -20)
            local HITBOX_SIZE = 22
            
        data.ResouledHitbox = Game():Spawn(HITBOX_TYPE, HITBOX_VARIANT, effect.Position + (HITBOX_OFFSET):Rotated(effect.SpriteRotation), Vector.Zero, effect, HITBOX_SUBTYPE, effect.InitSeed)
            data.ResouledHitbox.Size = HITBOX_SIZE
            local smoke = Game():Spawn(EntityType.ENTITY_EFFECT, EffectVariant.DARK_BALL_SMOKE_PARTICLE, effect.Position + (HITBOX_OFFSET):Rotated(effect.SpriteRotation), Vector.Zero, nil, 0, effect.InitSeed)
            smoke.Color = Color(1, 0, 0, 0.5)
            smoke.SpriteScale = Vector(1.5, 1.5)
            smoke:GetSprite().PlaybackSpeed = 0.75
        end
        
    if sprite:GetFrame() == 6 then
            data.ResouledHitbox:Remove()
            
        local HITBOX_OFFSET = Vector(-33, -27)
            local HITBOX_SIZE = 25
            
        data.ResouledHitbox = Game():Spawn(HITBOX_TYPE, HITBOX_VARIANT, effect.Position + (HITBOX_OFFSET):Rotated(effect.SpriteRotation), Vector.Zero, effect, HITBOX_SUBTYPE, effect.InitSeed)
            data.ResouledHitbox.Size = HITBOX_SIZE
            local smoke = Game():Spawn(EntityType.ENTITY_EFFECT, EffectVariant.DARK_BALL_SMOKE_PARTICLE, effect.Position + (HITBOX_OFFSET):Rotated(effect.SpriteRotation), Vector.Zero, nil, 0, effect.InitSeed)
            smoke.Color = Color(2, 1, 1, 0.6)
            smoke.SpriteScale = Vector(1.5, 1.5)
            smoke:GetSprite().PlaybackSpeed = 0.75
        end
        
    if sprite:GetFrame() == 7 then
            data.ResouledHitbox:Remove()
            
        local HITBOX_OFFSET = Vector(-10, -32)
            local HITBOX_SIZE = 26
            
        data.ResouledHitbox = Game():Spawn(HITBOX_TYPE, HITBOX_VARIANT, effect.Position + (HITBOX_OFFSET):Rotated(effect.SpriteRotation), Vector.Zero, effect, HITBOX_SUBTYPE, effect.InitSeed)
            data.ResouledHitbox.Size = HITBOX_SIZE
            local smoke = Game():Spawn(EntityType.ENTITY_EFFECT, EffectVariant.DARK_BALL_SMOKE_PARTICLE, effect.Position + (HITBOX_OFFSET):Rotated(effect.SpriteRotation), Vector.Zero, nil, 0, effect.InitSeed)
            smoke.Color = Color(3, 1, 1, 0.7)
            smoke.SpriteScale = Vector(1.5, 1.5)
            smoke:GetSprite().PlaybackSpeed = 0.75
        end
        
        if sprite:GetFrame() == 8 then
            data.ResouledHitbox:Remove()
            
        local HITBOX_OFFSET = Vector(12, -28)
            local HITBOX_SIZE = 26
            
        data.ResouledHitbox = Game():Spawn(HITBOX_TYPE, HITBOX_VARIANT, effect.Position + (HITBOX_OFFSET):Rotated(effect.SpriteRotation), Vector.Zero, effect, HITBOX_SUBTYPE, effect.InitSeed)
            data.ResouledHitbox.Size = HITBOX_SIZE
            local smoke = Game():Spawn(EntityType.ENTITY_EFFECT, EffectVariant.DARK_BALL_SMOKE_PARTICLE, effect.Position + (HITBOX_OFFSET):Rotated(effect.SpriteRotation), Vector.Zero, nil, 0, effect.InitSeed)
            smoke.Color = Color(4, 1, 1, 0.8)
            smoke.SpriteScale = Vector(1.5, 1.5)
            smoke:GetSprite().PlaybackSpeed = 0.75
        end
        
    if sprite:GetFrame() == 9 then
            data.ResouledHitbox:Remove()
            
        local HITBOX_OFFSET = Vector(27, -25)
            local HITBOX_SIZE = 24
            
        data.ResouledHitbox = Game():Spawn(HITBOX_TYPE, HITBOX_VARIANT, effect.Position + (HITBOX_OFFSET):Rotated(effect.SpriteRotation), Vector.Zero, effect, HITBOX_SUBTYPE, effect.InitSeed)
            data.ResouledHitbox.Size = HITBOX_SIZE
            local smoke = Game():Spawn(EntityType.ENTITY_EFFECT, EffectVariant.DARK_BALL_SMOKE_PARTICLE, effect.Position + (HITBOX_OFFSET):Rotated(effect.SpriteRotation), Vector.Zero, nil, 0, effect.InitSeed)
            smoke.Color = Color(5, 1, 1, 0.9)
            smoke.SpriteScale = Vector(1.5, 1.5)
            smoke:GetSprite().PlaybackSpeed = 0.75
        end
        
    if sprite:GetFrame() == 10 then
            data.ResouledHitbox:Remove()
            
        local HITBOX_OFFSET = Vector(35, -20)
            local HITBOX_SIZE = 20
            
        data.ResouledHitbox = Game():Spawn(HITBOX_TYPE, HITBOX_VARIANT, effect.Position + (HITBOX_OFFSET):Rotated(effect.SpriteRotation), Vector.Zero, effect, HITBOX_SUBTYPE, effect.InitSeed)
            data.ResouledHitbox.Size = HITBOX_SIZE
            local smoke = Game():Spawn(EntityType.ENTITY_EFFECT, EffectVariant.DARK_BALL_SMOKE_PARTICLE, effect.Position + (HITBOX_OFFSET):Rotated(effect.SpriteRotation), Vector.Zero, nil, 0, effect.InitSeed)
            smoke.Color = Color(6, 1, 1, 1)
            smoke.SpriteScale = Vector(1.5, 1.5)
            smoke:GetSprite().PlaybackSpeed = 0.75
        end
        
    if sprite:GetFrame() == 10 then
            data.ResouledHitbox:Remove()
        end
end
Resouled:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, postEffectUpdate, COTH_VARIANT)