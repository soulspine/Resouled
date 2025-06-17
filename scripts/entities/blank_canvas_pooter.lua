local POOTER_TYPE = Isaac.GetEntityTypeByName("Blank Canvas Pooter")
local POOTER_VARIANT = Isaac.GetEntityVariantByName("Blank Canvas Pooter")

local GORE_VARIANT = Isaac.GetEntityVariantByName("Paper Gore Particle 1")
local GORE_PARTICLE_COUNT = 6

local IDLE = "Idle"

local DEATH1_SFX = Isaac.GetSoundIdByName("Paper Death 1")
local DEATH2_SFX = Isaac.GetSoundIdByName("Paper Death 2")
local DEATH3_SFX = Isaac.GetSoundIdByName("Paper Death 3")

local SFX_VOLUME = 1.5

local DEATH_SOUND_TABLE = {
    [1] = DEATH1_SFX,
    [2] = DEATH2_SFX,
    [3] = DEATH3_SFX,
}

local BASE_DOODLE_SIZE = 0.85

local VELOCITY_MULTIPLIER = 0.75

local FOLLOW_SPEED = 0.2

local ATTACK_DISTANCE = 300
local ATTACK_COOLDOWN = 75
local PROJECTILE_SPEED = 10

---@param npc EntityNPC
local function postNpcInit(_, npc)
    if npc.Variant == POOTER_VARIANT then
        local sprite = npc:GetSprite()
        local data = npc:GetData()
        sprite:Play(IDLE, true)
        npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        npc.Scale = BASE_DOODLE_SIZE + RNG(npc.InitSeed):RandomFloat()/3
        npc.Size = npc.Size * npc.Scale
        data.ResouledAttackCooldown = ATTACK_COOLDOWN
        npc:AddEntityFlags(EntityFlag.FLAG_NO_BLOOD_SPLASH)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_INIT, postNpcInit, POOTER_TYPE)

---@param npc EntityNPC
local function npcUpdate(_, npc)
    if npc.Variant == POOTER_VARIANT then
        local data = npc:GetData()
        npc.Pathfinder:MoveRandomly(false)
        
        npc.Velocity = (npc.Velocity + (npc:GetPlayerTarget().Position - npc.Position):Normalized() * FOLLOW_SPEED) * VELOCITY_MULTIPLIER

        if data.ResouledAttackCooldown then
            if data.ResouledAttackCooldown > 0 then
                data.ResouledAttackCooldown = data.ResouledAttackCooldown - 1
            end

            if data.ResouledAttackCooldown <= 0 and npc:GetPlayerTarget().Position:Distance(npc.Position) < ATTACK_DISTANCE then
                Resouled:SpawnPaperTear(npc.Position, (npc:GetPlayerTarget().Position - npc.Position):Normalized() * PROJECTILE_SPEED, Vector(0, -20), npc)
                data.ResouledAttackCooldown = ATTACK_COOLDOWN
            end
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_NPC_UPDATE, npcUpdate, POOTER_TYPE)

---@param npc EntityNPC
local function postNpcDeath(_, npc)
    if npc.Variant == POOTER_VARIANT then
        local randomNum = math.random(1, 3)
        SFXManager():Play(DEATH_SOUND_TABLE[randomNum], SFX_VOLUME)
        Resouled:SpawnPaperGore(npc.Position, GORE_PARTICLE_COUNT)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, postNpcDeath, POOTER_TYPE)