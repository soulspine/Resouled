local HitBox = Resouled.Stats.ResouledHitbox

---@param npc EntityNPC
local function postNpcInit(_, npc)
    if npc.Variant == HitBox.Variant and npc.SubType == HitBox.SubType then
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
        npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
        npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        npc:ClearEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
        npc:ClearEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_INIT, postNpcInit, HitBox.Type)

---@param npc EntityNPC
local function npcUpdate(_, npc)
    if npc.Variant == HitBox.Variant and npc.SubType == HitBox.SubType then
        if npc.SpawnerEntity == nil then
            npc:Remove()
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_NPC_UPDATE, npcUpdate, HitBox.Type)

---@param player EntityPlayer
---@param collider Entity
local function prePlayerCollision(_, player, collider)
    if collider.Type == HitBox.Type and collider.Variant == HitBox.Variant and collider.SubType == HitBox.SubType then
        player:TakeDamage(1, DamageFlag.DAMAGE_NO_PENALTIES, EntityRef(collider), 45)
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_PLAYER_COLLISION, prePlayerCollision)