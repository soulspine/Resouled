local MULLIGAN_TYPE = Isaac.GetEntityTypeByName("Blank Canvas Mulligan")
local MULLIGAN_VARIANT = Isaac.GetEntityVariantByName("Blank Canvas Mulligan")
local MULLIGAN_SUBTYPE = Isaac.GetEntitySubTypeByName("Blank Canvas Mulligan")

local FLY_TYPE = Isaac.GetEntityTypeByName("Blank Canvas Fly")
local FLY_VARIANT = Isaac.GetEntityVariantByName("Blank Canvas Fly")
local FLY_SUBTYPE = Isaac.GetEntitySubTypeByName("Blank Canvas Fly")

local GORE_PARTICLE_COUNT = 15

local IDLE = "Idle"
local WALK = "Walk"
local FLIP = "Flip"

local FLIP_TRIGGER = "ResouledFlip"
local FLIP_START_TRIGGER = "ResouledFlip"
local CAN_FLIP_CHECK = "ResouledCanFlip"

local FLIP_SFX = Isaac.GetSoundIdByName("Paper Flip")
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

local DEATH_FLY_COUNT = 5

---@param npc EntityNPC
local function postNpcInit(_, npc)
    if npc.Variant == MULLIGAN_VARIANT and npc.SubType == MULLIGAN_SUBTYPE then
        local sprite = npc:GetSprite()
        sprite:Play(IDLE, true)
        npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        npc.Scale = BASE_DOODLE_SIZE + RNG(npc.InitSeed):RandomFloat()/3
        npc.Size = npc.Size * npc.Scale
        npc:AddEntityFlags(EntityFlag.FLAG_NO_BLOOD_SPLASH)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_INIT, postNpcInit, MULLIGAN_TYPE)

---@param npc EntityNPC
local function npcUpdate(_, npc)
    if npc.Variant == MULLIGAN_VARIANT and npc.SubType == MULLIGAN_SUBTYPE then
        local sprite = npc:GetSprite()

        if npc.Velocity:LengthSquared() < 0.01 and not sprite:IsPlaying(IDLE) and not sprite:IsPlaying(FLIP) then
            sprite:Play(IDLE, true)
        elseif npc.Velocity:LengthSquared() > 0.01 and not sprite:IsPlaying(WALK) and not sprite:IsPlaying(FLIP) then
            sprite:Play(WALK, true)
        end

        if npc:GetPlayerTarget().Position.X - npc.Position.X < 0 and sprite.FlipX and not sprite:IsPlaying(FLIP) and sprite:IsEventTriggered(CAN_FLIP_CHECK) then
            sprite:Play(FLIP, true)
        elseif npc:GetPlayerTarget().Position.X - npc.Position.X > 0 and not sprite.FlipX and not sprite:IsPlaying(FLIP) and sprite:IsEventTriggered(CAN_FLIP_CHECK) then
            sprite:Play(FLIP, true)
        end

        if sprite:IsEventTriggered("FlipStep") then
            sprite:Play(FLIP, true)
        end

        if sprite:IsEventTriggered(FLIP_TRIGGER) then
            if sprite.FlipX then
                sprite.FlipX = false
            else
                sprite.FlipX = true
            end
        end

        if sprite:IsEventTriggered(FLIP_START_TRIGGER) then
            SFXManager():Play(FLIP_SFX, SFX_VOLUME)
        end

        npc.Velocity = (npc.Velocity + (npc.Position - npc:GetPlayerTarget().Position):Normalized()) * VELOCITY_MULTIPLIER
    end
end
Resouled:AddCallback(ModCallbacks.MC_NPC_UPDATE, npcUpdate, MULLIGAN_TYPE)

---@param npc EntityNPC
local function postNpcDeath(_, npc)
    if npc.Variant == MULLIGAN_VARIANT and npc.SubType == MULLIGAN_SUBTYPE then
        for i = 1, DEATH_FLY_COUNT do
            Game():Spawn(FLY_TYPE, FLY_VARIANT, npc.Position + Vector(math.random(-2, 2), math.random(-2, 2)), Vector.Zero, nil, FLY_SUBTYPE, npc.InitSeed)
        end
        local randomNum = math.random(1, 3)
        SFXManager():Play(DEATH_SOUND_TABLE[randomNum], SFX_VOLUME)
        Resouled:SpawnPaperGore(npc.Position, GORE_PARTICLE_COUNT)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, postNpcDeath, MULLIGAN_TYPE)

Resouled:RegisterPaperEnemy(MULLIGAN_TYPE, MULLIGAN_VARIANT, MULLIGAN_SUBTYPE)