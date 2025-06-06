local CURSED_GAPER_TYPE = Isaac.GetEntityTypeByName("Cursed Gaper")
local CURSED_GAPER_VARIANT = Isaac.GetEntityVariantByName("Cursed Gaper")
local CURSED_GAPER_SUBTYPE = Isaac.GetEntitySubTypeByName("Cursed Gaper")

local CURSED_ENEMY_MORPH_CHANCE = 0.1

---@param npc EntityNPC
local function onNpcInit(_, npc)
    --Try to turn enemy into a cursed enemy
    if Game():GetLevel():GetCurses() > 0 then
        Resouled:TryEnemyMorph(npc, CURSED_ENEMY_MORPH_CHANCE, CURSED_GAPER_TYPE, CURSED_GAPER_VARIANT, 0)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_INIT, onNpcInit, CURSED_GAPER_TYPE)

---@param npc EntityNPC
---@param collider Entity
local function postNpcCollision(_, npc, collider)
    local colliderNPC = collider:ToNPC()
    if colliderNPC and colliderNPC.Type == EntityType.ENTITY_GAPER then
        if npc.Variant == CURSED_GAPER_VARIANT and colliderNPC.Variant ~= CURSED_GAPER_VARIANT then
            local newGaper = Game():Spawn(CURSED_GAPER_TYPE, CURSED_GAPER_VARIANT, colliderNPC.Position, colliderNPC.Velocity, colliderNPC.SpawnerEntity, CURSED_GAPER_SUBTYPE, colliderNPC.InitSeed)
            newGaper:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
            newGaper.HitPoints = colliderNPC.HitPoints
            colliderNPC:Remove()
            Game():Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, newGaper.Position, Vector.Zero, nil, 0, newGaper.InitSeed)
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_COLLISION, postNpcCollision, EntityType.ENTITY_GAPER)