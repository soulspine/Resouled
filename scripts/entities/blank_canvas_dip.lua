local DIP_TYPE = Isaac.GetEntityTypeByName("Blank Canvas Dip")
local DIP_VARIANT = Isaac.GetEntityVariantByName("Blank Canvas Dip")

local GORE_PARTICLE_COUNT = 4

local IDLE = "Idle"
local FLIP = "Flip"

local FLIP_TRIGGER = "ResouledFlip"
local FLIP_START_TRIGGER = "ResouledFlip"

local FLIP_SFX = Isaac.GetSoundIdByName("Paper Flip")
local DEATH1_SFX = Isaac.GetSoundIdByName("Paper Death 1")
local DEATH2_SFX = Isaac.GetSoundIdByName("Paper Death 2")
local DEATH3_SFX = Isaac.GetSoundIdByName("Paper Death 3")

local SFX_VOLUME = 1.5

local MIN_INNACURACY = -45
local MAX_INNACURACY = 45

local DEATH_SOUND_TABLE = {
    [1] = DEATH1_SFX,
    [2] = DEATH2_SFX,
    [3] = DEATH3_SFX,
}

local BASE_DOODLE_SIZE = 0.85

local VELOCITY_MULTIPLIER = 0.85
local DASH_SPEED = 15

---@param npc EntityNPC
local function postNpcInit(_, npc)
    if npc.Variant == DIP_VARIANT then
        local sprite = npc:GetSprite()
        local data = npc:GetData()
        sprite:Play(IDLE, true)
        npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        npc.Scale = BASE_DOODLE_SIZE + RNG(npc.InitSeed):RandomFloat()/3
        npc.Size = npc.Size * npc.Scale
        data.ResouledDashing = false
        npc:AddEntityFlags(EntityFlag.FLAG_NO_BLOOD_SPLASH)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_INIT, postNpcInit, DIP_TYPE)

---@param npc EntityNPC
local function npcUpdate(_, npc)
    if npc.Variant == DIP_VARIANT then
        local data = npc:GetData()
        local sprite = npc:GetSprite()

        if not data.ResouledDashing then
            npc.Velocity = (npc.Velocity + (npc:GetPlayerTarget().Position - npc.Position):Normalized():Rotated(math.random(MIN_INNACURACY, MAX_INNACURACY)) * DASH_SPEED) * VELOCITY_MULTIPLIER
            data.ResouledDashing = true
        end

        npc.Velocity = npc.Velocity * VELOCITY_MULTIPLIER
        
        if npc.Velocity:LengthSquared() < 0.01 then
            data.ResouledDashing = false
        end
                if npc:GetPlayerTarget().Position.X - npc.Position.X > 0 and sprite.FlipX and not sprite:IsPlaying(FLIP) then
            sprite:Play(FLIP, true)
        elseif npc:GetPlayerTarget().Position.X - npc.Position.X < 0 and not sprite.FlipX and not sprite:IsPlaying(FLIP) then
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
    end
end
Resouled:AddCallback(ModCallbacks.MC_NPC_UPDATE, npcUpdate, DIP_TYPE)

---@param npc EntityNPC
local function postNpcDeath(_, npc)
    if npc.Variant == DIP_VARIANT then
        local randomNum = math.random(1, 3)
        SFXManager():Play(DEATH_SOUND_TABLE[randomNum], SFX_VOLUME)
        Resouled:SpawnPaperGore(npc.Position, GORE_PARTICLE_COUNT)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, postNpcDeath, DIP_TYPE)