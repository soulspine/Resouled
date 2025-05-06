local FLY_TYPE = Isaac.GetEntityTypeByName("Blank Canvas Fly")
local FLY_VARIANT = Isaac.GetEntityVariantByName("Blank Canvas Fly")

local VELOCITY_MULTIPLIER = 0.75

local IDLE = "Idle"
local DEATH = "Death"

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
        local sprite = npc:GetSprite()
        npc.Pathfinder:MoveRandomly(false)
        if not sprite:IsPlaying(DEATH) then
            npc.Velocity = (npc.Velocity + (npc:GetPlayerTarget().Position - npc.Position):Normalized()) * VELOCITY_MULTIPLIER
        else
            npc.Velocity = npc.Velocity * VELOCITY_MULTIPLIER
        end

        if sprite:IsFinished(DEATH) then
            npc:Die()
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_NPC_UPDATE, npcUpdate, FLY_TYPE)

---@param entity Entity
local function entityTakeDamage(_, entity, amount)
    if entity.Variant == FLY_VARIANT then
        if entity.HitPoints - amount <= 0 then
            entity:GetSprite():Play(DEATH, true)
            entity.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
            entity.CollisionDamage = 0
            local randomNum = math.random(1, 3)
            SFXManager():Play(DEATH_SOUND_TABLE[randomNum])
            return false
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, entityTakeDamage, FLY_TYPE)