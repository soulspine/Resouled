local HITBOX_TYPE = Isaac.GetEntityTypeByName("ResouledHitbox")
local HITBOX_VARIANT = Isaac.GetEntityVariantByName("ResouledHitbox")
local HITBOX_SUBTYPE = Isaac.GetEntitySubTypeByName("ResouledHitbox")

---@param npc EntityNPC
local function postNpcInit(_, npc)
    if npc.Variant == HITBOX_VARIANT and npc.SubType == HITBOX_SUBTYPE then
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
        npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
        npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_INIT, postNpcInit, HITBOX_TYPE)

---@param npc EntityNPC
local function npcUpdate(_, npc)
    if npc.Variant == HITBOX_VARIANT and npc.SubType == HITBOX_SUBTYPE then
        if npc.SpawnerEntity == nil then
            npc:Remove()
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_NPC_UPDATE, npcUpdate, HITBOX_TYPE)

---@param player EntityPlayer
---@param collider Entity
local function prePlayerCollision(_, player, collider)
    if collider.Type == HITBOX_TYPE and collider.Variant == HITBOX_VARIANT and collider.SubType == HITBOX_SUBTYPE then
        player:TakeDamage(1, DamageFlag.DAMAGE_NO_PENALTIES, EntityRef(collider), 45)
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_PLAYER_COLLISION, prePlayerCollision)