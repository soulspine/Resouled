local WRATHS_GIGA_BOMB_TYPE = Isaac.GetEntityTypeByName("Wrath's Giga Bomb")
local WRATHS_GIGA_BOMB_VARIANT = Isaac.GetEntityVariantByName("Wrath's Giga Bomb")
local WRATHS_GIGA_BOMB_SUBTYPE = 1

local SPAWN_ANM = "Spawn"
local FUSE_ANM = "Fuse"

local FUSE_TRIGGER = "FuseStart"
local EXPLOSION_TRIGGER = "Explosion"

---@param npc EntityNPC
local function onNpcInit(_, npc)
    if npc.Variant == WRATHS_GIGA_BOMB_VARIANT and npc.SubType == WRATHS_GIGA_BOMB_SUBTYPE then
        local sprite = npc:GetSprite()
        sprite:Play(SPAWN_ANM, true)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_INIT, onNpcInit, WRATHS_GIGA_BOMB_TYPE)

---@param npc EntityNPC
local function onNpcUpdate(_, npc)
    if npc.Variant == WRATHS_GIGA_BOMB_VARIANT and npc.SubType == WRATHS_GIGA_BOMB_SUBTYPE then
        local sprite = npc:GetSprite()
        if sprite:WasEventTriggered(FUSE_TRIGGER) then
            sprite:Play(FUSE_ANM, true)
        end
        if sprite:WasEventTriggered(EXPLOSION_TRIGGER) then
            Game():BombExplosionEffects(npc.Position, 1, TearFlags.TEAR_EXPLOSIVE, Color(1, 1, 1), npc, 2, true, true, DamageFlag.DAMAGE_EXPLOSION)
            Game():GetRoom():MamaMegaExplosion(npc.Position)
            Game():Spawn(WRATHS_GIGA_BOMB_TYPE, WRATHS_GIGA_BOMB_VARIANT, npc.Position, Vector.Zero, nil, 0, npc.InitSeed)
            npc:Remove()
        end
        return true
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, onNpcUpdate, WRATHS_GIGA_BOMB_TYPE)

---@param entity Entity
---@param amount number
---@param damageFlag integer
---@param source EntityRef
---@param countdown integer
local function onEntityTakeDamage(_, entity, amount, damageFlag, source, countdown)
    if source.Entity.Type == WRATHS_GIGA_BOMB_TYPE and source.Entity.Variant == WRATHS_GIGA_BOMB_VARIANT and source.Entity.SubType == WRATHS_GIGA_BOMB_SUBTYPE then
        if entity == nil then
            return
        end
        return false
    end
end
Resouled:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, onEntityTakeDamage)