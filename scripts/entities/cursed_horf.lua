local CURSED_HORF_VARIANT = Isaac.GetEntityVariantByName("Cursed Horf")
local CURSED_HORF_TYPE = Isaac.GetEntityTypeByName("Cursed Horf")
local CURSED_HORF_SUBTYPE = Isaac.GetEntitySubTypeByName("Cursed Horf")

local CURSED_ENEMY_MORPH_CHANCE = Resouled.Stats.CursedEnemyMorphChance

local REFLECTED_BULLET_SPEED = 2

---@param npc EntityNPC
local function onNpcInit(_, npc)
    --Try to turn enemy into a cursed enemy
    if Game():GetLevel():GetCurses() > 0 then
        Resouled:TryEnemyMorph(npc, CURSED_ENEMY_MORPH_CHANCE, CURSED_HORF_TYPE, CURSED_HORF_VARIANT, CURSED_HORF_SUBTYPE)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_INIT, onNpcInit, CURSED_HORF_TYPE)

---@param entity Entity
---@param flags DamageFlag
---@param source EntityRef
---@param type EntityType
local function onEnemyHit(_, entity, amount, flags, source, frames, type)
    if entity.Variant == CURSED_HORF_VARIANT and not entity:IsDead() and source.Entity then
        local PROJECTILE_PARAMS = ProjectileParams()
        entity:ToNPC():FireProjectiles(entity.Position, -source.Entity.Velocity * REFLECTED_BULLET_SPEED, 0, PROJECTILE_PARAMS)
    end
end
Resouled:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, onEnemyHit, CURSED_HORF_TYPE)