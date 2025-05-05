local GAPER_TYPE = Isaac.GetEntityTypeByName("Blank Canvas Gaper")
local GAPER_VARIANT = Isaac.GetEntityVariantByName("Blank Canvas Gaper")

local IDLE = "Idle"
local WALK = "Walk"
local FLIP = "Flip"

local FLIP_TRIGGER = "ResouledFlip"
local FLIP_START_TRIGGER = "ResouledFlip"
local CAN_FLIP_CHECK = "ResouledCanFlip"

local VELOCITY_MULTIPLIER = 0.75

---@param npc EntityNPC
local function postNpcInit(_, npc)
    if npc.Variant == GAPER_VARIANT then
        local sprite = npc:GetSprite()
        sprite:Play(IDLE, true)
        npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_INIT, postNpcInit, GAPER_TYPE)

---@param npc EntityNPC
local function npcUpdate(_, npc)
    if npc.Variant == GAPER_VARIANT then
        local sprite = npc:GetSprite()

        if npc.Velocity:LengthSquared() < 0.01 and not sprite:IsPlaying(IDLE) and not sprite:IsPlaying(FLIP) then
            sprite:Play(IDLE, true)
        elseif npc.Velocity:LengthSquared() > 0.01 and not sprite:IsPlaying(WALK) and not sprite:IsPlaying(FLIP) then
            sprite:Play(WALK, true)
        end

        if npc:GetPlayerTarget().Position.X - npc.Position.X > 0 and sprite.FlipX and not sprite:IsPlaying(FLIP) and sprite:IsEventTriggered(CAN_FLIP_CHECK) then
            sprite:Play(FLIP, true)
        elseif npc:GetPlayerTarget().Position.X - npc.Position.X < 0 and not sprite.FlipX and not sprite:IsPlaying(FLIP) and sprite:IsEventTriggered(CAN_FLIP_CHECK) then
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

        npc.Velocity = (npc.Velocity + (npc:GetPlayerTarget().Position - npc.Position):Normalized()) * VELOCITY_MULTIPLIER
    end
end
Resouled:AddCallback(ModCallbacks.MC_NPC_UPDATE, npcUpdate, GAPER_TYPE)