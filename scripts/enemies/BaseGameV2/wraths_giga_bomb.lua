local WRATHS_GIGA_BOMB_TYPE = Isaac.GetEntityTypeByName("Wrath's Giga Bomb")
local WRATHS_GIGA_BOMB_VARIANT = Isaac.GetEntityVariantByName("Wrath's Giga Bomb")
local WRATHS_GIGA_BOMB_SUBTYPE = 1

local SPAWN_ANM = "Spawn"
local FUSE_ANM = "Fuse"

local EVENT_TRIGGER_RESOULED_FUSE_START = "ResouledFuseStart"
local EVENT_TRIGGER_RESOULED_EXPLOSION = "ResouledExplosion"

local EXPLOSION_DAMAGE = 0
local EXPLOSION_COLOR = Color(1, 1, 1, 1, 0, 0, 0)
local EXPLOSION_TEAR_FLAGS = (TearFlags.TEAR_EXPLOSIVE | TearFlags.TEAR_GIGA_BOMB)
local EXPLOSION_RADIUS_MULTIPLIER = 2
local EXPLOSION_LINE_CHECK = false
local EXPLOSION_DAMAGE_SOURCE = false
local EXPLOSION_DAMAGE_FLAGS = (DamageFlag.DAMAGE_FAKE)

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
        if sprite:WasEventTriggered(EVENT_TRIGGER_RESOULED_FUSE_START) then
            sprite:Play(FUSE_ANM, true)
        elseif sprite:IsEventTriggered(EVENT_TRIGGER_RESOULED_EXPLOSION) then
            Game():BombExplosionEffects(npc.Position, EXPLOSION_DAMAGE, EXPLOSION_TEAR_FLAGS, EXPLOSION_COLOR, npc, EXPLOSION_RADIUS_MULTIPLIER, EXPLOSION_LINE_CHECK, EXPLOSION_DAMAGE_SOURCE, EXPLOSION_DAMAGE_FLAGS)
            Game():Spawn(WRATHS_GIGA_BOMB_TYPE, WRATHS_GIGA_BOMB_VARIANT, npc.Position, Vector.Zero, nil, 0, npc.InitSeed)
            npc:Remove()
        end
        return true
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, onNpcUpdate, WRATHS_GIGA_BOMB_TYPE)