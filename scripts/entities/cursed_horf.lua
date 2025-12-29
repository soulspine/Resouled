local CURSED_HORF_VARIANT = Isaac.GetEntityVariantByName("Cursed Horf")
local CURSED_HORF_TYPE = Isaac.GetEntityTypeByName("Cursed Horf")
local CURSED_HORF_SUBTYPE = Isaac.GetEntitySubTypeByName("Cursed Horf")

local PROJECTILE_PARAMS = Resouled.Stats:GetCursedProjectileParams()
local REFLECTED_BULLET_SPEED = 1

Resouled:RegisterCursedEnemyMorph(EntityType.ENTITY_HORF, nil, nil, CURSED_HORF_TYPE, CURSED_HORF_VARIANT, CURSED_HORF_SUBTYPE)

---@param e1 Entity
---@param e2 Entity
---@param vel Vector
---@return Vector | nil
local function getReflectVelocity(e1, e2, vel)
    e2 = Resouled:TryFindPlayerSpawner(e2)
    if e2 then
        return (e2.Position - e1.Position):Resized(vel:Length() * REFLECTED_BULLET_SPEED) + e2.Velocity * e2.Velocity:Length()/2
    end
    return nil
end

---@param entity Entity
---@param flags DamageFlag
---@param source EntityRef
---@param type EntityType
local function onEnemyHit(_, entity, amount, flags, source, frames, type)
    if entity.Variant == CURSED_HORF_VARIANT and not entity:IsDead() and source.Entity and Resouled:TryFindPlayerSpawner(source.Entity) then
        local vel = getReflectVelocity(entity, source.Entity, source.Entity.Velocity)
        if vel then
            entity:ToNPC():FireProjectiles(entity.Position, vel, 0, PROJECTILE_PARAMS)
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, onEnemyHit, CURSED_HORF_TYPE)

Resouled.StatTracker:RegisterCursedEnemy(CURSED_HORF_TYPE, CURSED_HORF_VARIANT, CURSED_HORF_SUBTYPE)