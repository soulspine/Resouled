local CURSED_HORF_VARIANT = Isaac.GetEntityVariantByName("Cursed Horf")
local CURSED_HORF_TYPE = Isaac.GetEntityTypeByName("Cursed Horf")
local CURSED_HORF_SUBTYPE = Isaac.GetEntitySubTypeByName("Cursed Horf")

local PROJECTILE_PARAMS = Resouled.Stats:GetCursedProjectileParams()
local REFLECTED_BULLET_SPEED = 2

Resouled:RegisterCursedEnemyMorph(EntityType.ENTITY_HORF, nil, nil, CURSED_HORF_TYPE, CURSED_HORF_VARIANT, CURSED_HORF_SUBTYPE)

---@param entity Entity
---@param flags DamageFlag
---@param source EntityRef
---@param type EntityType
local function onEnemyHit(_, entity, amount, flags, source, frames, type)
    if entity.Variant == CURSED_HORF_VARIANT and not entity:IsDead() and source.Entity then
        entity:ToNPC():FireProjectiles(entity.Position, -source.Entity.Velocity * REFLECTED_BULLET_SPEED, 0, PROJECTILE_PARAMS)
    end
end
Resouled:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, onEnemyHit, CURSED_HORF_TYPE)

Resouled.StatTracker:RegisterCursedEnemy(CURSED_HORF_TYPE, CURSED_HORF_VARIANT, CURSED_HORF_SUBTYPE)