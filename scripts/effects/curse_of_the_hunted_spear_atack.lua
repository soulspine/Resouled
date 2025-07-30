local COTH_TYPE = Isaac.GetEntityTypeByName("COTH attack spear")
local COTH_VARIANT = Isaac.GetEntityVariantByName("COTH attack spear")
local COTH_SUBTYPE = Isaac.GetEntitySubTypeByName("COTH attack spear")

local HitBox = Resouled.Stats.ResouledHitbox
local HITBOX_SIZE = 10

local SPEAR_SPEED = 30

local maxOffScreenDistance = 50

local Trail = {
    Color = Color(1, 1, 1, 1),
    TrailLength = 0.03,
    TrailSize = Vector(1.5, 1.5),
    TrailOffset = Vector(0, 0)
}

---@param effect EntityEffect
local function postEffectInit(_, effect)
    if effect.SubType == COTH_SUBTYPE then
        local data = effect:GetData()
        effect.SpriteRotation = (Game():GetNearestPlayer(effect.Position).Position - effect.Position):Normalized():GetAngleDegrees()
        data.ResouledHitbox = Game():Spawn(HitBox.Type, HitBox.Variant, effect.Position, Vector.Zero, effect, HitBox.SubType, effect.InitSeed)
        data.ResouledHitbox.Size = HITBOX_SIZE

        effect:GetSprite().Rotation = (Game():GetNearestPlayer(effect.Position).Position - effect.Position):GetAngleDegrees()

        local entityParent = effect
        local trail = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SPRITE_TRAIL, 0, entityParent.Position, Vector.Zero, entityParent):ToEffect()
        if trail and trail:ToEffect() then
            trail:FollowParent(entityParent)
            trail.Color = Trail.Color
            trail.MinRadius = Trail.TrailLength
            trail.SpriteScale = Trail.TrailSize
            trail.ParentOffset = Trail.TrailOffset

            local sprite = trail:GetSprite()
            for i = 0, sprite:GetLayerCount() - 1 do
                local layer = sprite:GetLayer(i)
                if layer then
                    local blend = layer:GetBlendMode()

                    blend.RGBSourceFactor = BlendFactor.ONE_MINUS_SRC_COLOR
                    blend.RGBDestinationFactor = BlendFactor.ONE_MINUS_SRC_COLOR
                end
            end
        end

        effect:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, postEffectInit, COTH_VARIANT)

---@param effect EntityEffect
local function postEffectUpdate(_, effect)
    if not Game():IsPaused() then
        if effect.SubType == COTH_SUBTYPE then
            local data = effect:GetData()
            local nearestPlayer = Game():GetNearestPlayer(effect.Position)
            local sprite = effect:GetSprite()

            
            if data.ResouledHitbox then
                data.ResouledHitbox.Position = effect.Position
            end
            effect.Velocity = Vector(SPEAR_SPEED, 0):Rotated(sprite.Rotation) + (nearestPlayer.Position - effect.Position):Normalized()
            effect.Position = effect.Position + effect.Velocity

            sprite.Rotation = effect.Velocity:GetAngleDegrees()
            
            local Screen = Vector(Isaac.GetScreenWidth(), Isaac.GetScreenHeight())
            local renderPos = Isaac.WorldToScreen(effect.Position)

            if renderPos.X < -maxOffScreenDistance or renderPos.X > Screen.X + maxOffScreenDistance or renderPos.Y < -maxOffScreenDistance or renderPos.Y > Screen.Y + maxOffScreenDistance then
                effect:Remove()
            end
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_EFFECT_RENDER, postEffectUpdate, COTH_VARIANT)