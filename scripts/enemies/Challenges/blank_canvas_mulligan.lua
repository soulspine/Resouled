local MULLIGAN_TYPE = Isaac.GetEntityTypeByName("Blank Canvas Mulligan")
local MULLIGAN_VARIANT = Isaac.GetEntityVariantByName("Blank Canvas Mulligan")

local FLY_TYPE = Isaac.GetEntityTypeByName("Blank Canvas Fly")
local FLY_VARIANT = Isaac.GetEntityVariantByName("Blank Canvas Fly")

local IDLE = "Idle"
local WALK = "Walk"
local FLIP = "Flip"

local FLIP_TRIGGER = "ResouledFlip"
local FLIP_START_TRIGGER = "ResouledFlip"
local CAN_FLIP_CHECK = "ResouledCanFlip"

local VELOCITY_MULTIPLIER = 0.75

local DEATH_FLY_COUNT = 5

---@param npc EntityNPC
local function postNpcInit(_, npc)
    if npc.Variant == MULLIGAN_VARIANT then
        local sprite = npc:GetSprite()
        sprite:Play(IDLE, true)
        npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_INIT, postNpcInit, MULLIGAN_TYPE)

---@param npc EntityNPC
local function npcUpdate(_, npc)
    if npc.Variant == MULLIGAN_VARIANT then
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
            SFXManager():Play(SoundEffect.SOUND_PAPER_OUT)
        end

        npc.Velocity = (npc.Velocity + (npc.Position - npc:GetPlayerTarget().Position):Normalized()) * VELOCITY_MULTIPLIER
    end
end
Resouled:AddCallback(ModCallbacks.MC_NPC_UPDATE, npcUpdate, MULLIGAN_TYPE)

---@param npc EntityNPC
local function postNpcDeath(_, npc)
    if npc.Variant == MULLIGAN_VARIANT then
        for i = 1, DEATH_FLY_COUNT do
            Game():Spawn(FLY_TYPE, FLY_VARIANT, npc.Position + Vector(math.random(-2, 2), math.random(-2, 2)), Vector.Zero, nil, 0, npc.InitSeed)
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, postNpcDeath, MULLIGAN_TYPE)