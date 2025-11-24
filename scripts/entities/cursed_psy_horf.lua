local CURSED_PSY_HORF_VARIANT = Isaac.GetEntityVariantByName("Cursed Psy Horf")
local CURSED_PSY_HORF_TYPE = Isaac.GetEntityTypeByName("Cursed Psy Horf")
local CURSED_PSY_HORF_SUBTYPE = Isaac.GetEntitySubTypeByName("Cursed Psy Horf")

Resouled:RegisterCursedEnemyMorph(EntityType.ENTITY_PSY_HORF, nil, nil, CURSED_PSY_HORF_TYPE, CURSED_PSY_HORF_VARIANT, CURSED_PSY_HORF_SUBTYPE)

local CURSED_ENEMY_MORPH_CHANCE = 0.1

local SHOOT = "ResouledShoot"

local PROJECTILE_PARAMS = Resouled.Stats:GetCursedProjectileParams()
PROJECTILE_PARAMS.BulletFlags = ProjectileFlags.SMART

local REFLECTED_BULLET_SPEED = 2

---@param npc EntityNPC
local function preNpcUpdate(_, npc)
    if npc.Variant == CURSED_PSY_HORF_VARIANT then
        local sprite = npc:GetSprite()
        if sprite:IsEventTriggered(SHOOT) then
            npc:FireProjectiles(npc.Position, (npc:GetPlayerTarget().Position - npc.Position) / 25, 0, PROJECTILE_PARAMS)
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, preNpcUpdate, CURSED_PSY_HORF_TYPE)

---@param entity Entity
---@param flags DamageFlag
---@param source EntityRef
---@param type EntityType
local function onEnemyHit(_, entity, amount, flags, source, frames, type)
    if entity.Variant == CURSED_PSY_HORF_VARIANT and not entity:IsDead() and source.Entity then
        entity:ToNPC():FireProjectiles(entity.Position, -source.Entity.Velocity * REFLECTED_BULLET_SPEED, 0, PROJECTILE_PARAMS)
    end
end
Resouled:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, onEnemyHit, CURSED_PSY_HORF_TYPE)

Resouled.StatTracker:RegisterCursedEnemy(CURSED_PSY_HORF_TYPE, CURSED_PSY_HORF_VARIANT, CURSED_PSY_HORF_SUBTYPE)