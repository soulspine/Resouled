local COTH_TYPE = Isaac.GetEntityTypeByName("COTH attack claws")
local COTH_VARIANT = Isaac.GetEntityVariantByName("COTH attack claws")
local COTH_SUBTYPE = Isaac.GetEntitySubTypeByName("COTH attack claws")

local BASE_HITBOX_SIZE = 20

---@param effect EntityEffect
local function postEffectInit(_, effect)
    if effect.SubType == COTH_SUBTYPE then
        effect.SpriteRotation = (Game():GetNearestPlayer(effect.Position).Position - effect.Position):Normalized():GetAngleDegrees()

        effect:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, postEffectInit, COTH_VARIANT)

---@param effect EntityEffect
local function postEffectUpdate(_, effect)
    if effect.SubType == COTH_SUBTYPE then
        local sprite = effect:GetSprite()
        if sprite:IsFinished("Idle") then
            effect:Remove()
        end

        local attackPos = sprite:GetNullFrame("AttackPos")
        if attackPos then
            local hitboxPos = effect.Position + attackPos:GetPos():Rotated(effect.SpriteRotation)
            local attackPosSize = attackPos:GetScale()
            local hitboxSize = (attackPosSize.X + attackPosSize.Y)/2

            local players = Isaac.FindInRadius(hitboxPos, hitboxSize * BASE_HITBOX_SIZE, EntityPartition.PLAYER)

            ---@param player EntityPlayer
            for _, player in pairs(players) do
                player:TakeDamage(1, DamageFlag.DAMAGE_NO_MODIFIERS, EntityRef(effect.SpawnerEntity or nil), 30)
            end
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, postEffectUpdate, COTH_VARIANT)