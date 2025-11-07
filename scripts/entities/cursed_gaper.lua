local CURSED_GAPER_TYPE = Isaac.GetEntityTypeByName("Cursed Gaper")
local CURSED_GAPER_VARIANT = Isaac.GetEntityVariantByName("Cursed Gaper")
local CURSED_GAPER_SUBTYPE = Isaac.GetEntitySubTypeByName("Cursed Gaper")

local CURSED_ENEMY_MORPH_CHANCE = Resouled.Stats.CursedEnemyMorphChance

---@param npc EntityNPC
local function onNpcInit(_, npc)
    --Try to turn enemy into a cursed enemy
    if Game():GetLevel():GetCurses() > 0 then
        Resouled:TryEnemyMorph(npc, CURSED_ENEMY_MORPH_CHANCE, CURSED_GAPER_TYPE, CURSED_GAPER_VARIANT, 0)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_INIT, onNpcInit, CURSED_GAPER_TYPE)

---@param npc EntityNPC
local function onNpcUpdate(_, npc)
    if npc.Variant == CURSED_GAPER_VARIANT and npc.SubType == CURSED_GAPER_SUBTYPE then
        ---@type EntityNPC | nil
        local nearestGaper = nil

        ---@param npc2 EntityNPC
        Resouled.Iterators:IterateOverRoomNpcs(function(npc2)
            if npc2.Type == EntityType.ENTITY_GAPER and npc2.Variant ~= CURSED_GAPER_VARIANT then
                if not nearestGaper then
                    nearestGaper = npc2
                elseif npc.Position:Distance(npc2.Position) < npc.Position:Distance(nearestGaper.Position) then
                    nearestGaper = npc2
                end
            end
        end)

        if nearestGaper then
            npc:TryForceTarget(nearestGaper, 2)
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_NPC_UPDATE, onNpcUpdate, CURSED_GAPER_TYPE)

---@param npc EntityNPC
---@param collider Entity
local function postNpcCollision(_, npc, collider)
    local colliderNPC = collider:ToNPC()
    if colliderNPC and colliderNPC.Type == EntityType.ENTITY_GAPER then
        if npc.Variant == CURSED_GAPER_VARIANT and npc.SubType == CURSED_GAPER_SUBTYPE and colliderNPC.Variant ~= CURSED_GAPER_VARIANT then
            local newGaper = Game():Spawn(CURSED_GAPER_TYPE, CURSED_GAPER_VARIANT, colliderNPC.Position, colliderNPC.Velocity, colliderNPC.SpawnerEntity, CURSED_GAPER_SUBTYPE, colliderNPC.InitSeed)
            newGaper:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
            newGaper.HitPoints = colliderNPC.HitPoints
            colliderNPC:Remove()
            Game():Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, newGaper.Position, Vector.Zero, nil, 0, newGaper.InitSeed)
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_COLLISION, postNpcCollision, EntityType.ENTITY_GAPER)

Resouled.StatTracker:RegisterCursedEnemy(CURSED_GAPER_TYPE, CURSED_GAPER_VARIANT, CURSED_GAPER_SUBTYPE)