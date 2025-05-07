local FLY_TYPE = Isaac.GetEntityTypeByName("Blank Canvas Fly")
local FLY_VARIANT = Isaac.GetEntityVariantByName("Blank Canvas Fly")

local VELOCITY_MULTIPLIER = 0.75

local IDLE = "Idle"


local GORE_VARIANT = Isaac.GetEntityVariantByName("Paper Gore Particle 1")
local GORE_PARTICLE_COUNT = 4

local FLIP_SFX = Isaac.GetSoundIdByName("Paper Flip")
local DEATH1_SFX = Isaac.GetSoundIdByName("Paper Death 1")
local DEATH2_SFX = Isaac.GetSoundIdByName("Paper Death 2")
local DEATH3_SFX = Isaac.GetSoundIdByName("Paper Death 3")

local DEATH_SOUND_TABLE = {
    [1] = DEATH1_SFX,
    [2] = DEATH2_SFX,
    [3] = DEATH3_SFX,
}

local BASE_DOODLE_SIZE = 0.85

---@param npc EntityNPC
local function postNpcInit(_, npc)
    if npc.Variant == FLY_VARIANT then
        local sprite = npc:GetSprite()
        sprite:Play(IDLE, true)
        npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
        npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        npc.Scale = BASE_DOODLE_SIZE + RNG(npc.InitSeed):RandomFloat()/3
        npc.Size = npc.Size * npc.Scale
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_INIT, postNpcInit, FLY_TYPE)

---@param npc EntityNPC
local function npcUpdate(_, npc)
    if npc.Variant == FLY_VARIANT then
        npc.Pathfinder:MoveRandomly(false)
        
        npc.Velocity = (npc.Velocity + (npc:GetPlayerTarget().Position - npc.Position):Normalized()) * VELOCITY_MULTIPLIER
    end
end
Resouled:AddCallback(ModCallbacks.MC_NPC_UPDATE, npcUpdate, FLY_TYPE)

---@param npc EntityNPC
local function postNpcDeath(_, npc)
    if npc.Variant == FLY_VARIANT then
        local randomNum = math.random(1, 3)
        SFXManager():Play(DEATH_SOUND_TABLE[randomNum])
        for _ = 1, GORE_PARTICLE_COUNT + math.random(-1, 1) do
            Game():SpawnParticles(npc.Position, GORE_VARIANT, 1, math.random(3, 11), Color.Default, 0, math.random(1, 10)-1)
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, postNpcDeath, FLY_TYPE)