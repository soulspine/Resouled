local MULLIGAN_TYPE = Isaac.GetEntityTypeByName("Blank Canvas Mulligan")
local MULLIGAN_VARIANT = Isaac.GetEntityVariantByName("Blank Canvas Mulligan")

local IDLE = "Idle"
local WALK = "Walk"

local VELOCITY_MULTIPLIER = 0.7

---@param npc EntityNPC
local function postNpcInit(_, npc)
    if npc.Variant == MULLIGAN_VARIANT then
        local sprite = npc:GetSprite()
        sprite:Play(IDLE, true)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_INIT, postNpcInit, MULLIGAN_TYPE)

---@param npc EntityNPC
local function npcUpdate(_, npc)
    if npc.Variant == MULLIGAN_VARIANT then
        local sprite = npc:GetSprite()

        if npc.Velocity:LengthSquared() < 0.01 and not sprite:IsPlaying(IDLE) then
            sprite:Play(IDLE, true)
        elseif npc.Velocity:LengthSquared() > 0.01 and not sprite:IsPlaying(WALK) then
            sprite:Play(WALK, true)
        end
        
        npc.Velocity = (npc.Velocity + (npc:GetPlayerTarget().Position - npc.Position):Normalized()) * VELOCITY_MULTIPLIER
    end
end
Resouled:AddCallback(ModCallbacks.MC_NPC_UPDATE, npcUpdate, MULLIGAN_TYPE)