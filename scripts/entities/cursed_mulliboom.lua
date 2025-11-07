local ID = Isaac.GetEntityTypeByName("Cursed Mulliboom")
local VARIANT = Isaac.GetEntityVariantByName("Cursed Mulliboom")
local SUBTYPE = Isaac.GetEntitySubTypeByName("Cursed Mulliboom")

local EXPLOSION_DAMAGE = 60
local BLAST_RADIUS = 87

---@param npc EntityNPC
local function npcDeath(_, npc)
    if npc.Variant == VARIANT and npc.SubType == SUBTYPE then
        local npcs = Isaac.FindInRadius(npc.Position, BLAST_RADIUS, EntityPartition.ENEMY)
        for _, npc2 in pairs(npcs) do
            if npc2:IsEnemy() and npc2:IsActiveEnemy() and npc2:IsVulnerableEnemy() and not npc2:IsDead() and npc2.HitPoints > 0 then
                Game():BombExplosionEffects(npc2.Position, EXPLOSION_DAMAGE)
            end
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, npcDeath, ID)

Resouled.StatTracker:RegisterCursedEnemy(ID, VARIANT, SUBTYPE)