local SOUL_BALL_TYPE = Isaac.GetEntityTypeByName("Soul Ball")
local SOUL_BALL_VARIANT = Isaac.GetEntityVariantByName("Soul Ball")

local NORMAL = true

local PARTICLE_TYPE = EffectVariant.DARK_BALL_SMOKE_PARTICLE
local PARTICLE_COUNT = 5
local PARTICLE_SPEED = 5
local PARTICLE_COLOR = Color(8, 10, 12)
local NORMAL_PARTICLE_COLOR = Color(1.5,1,1)
local PARTICLE_HEIGHT = 0
local PARTICLE_SUBTYPE = 0
local PARTICLE_OFFSET = Vector(0, -25)

---@param npc EntityNPC
local function onNpcInit(_, npc)
    if npc.Variant == SOUL_BALL_VARIANT then
        local sprite = npc:GetSprite()
        sprite:Play("Idle", true)
        if NORMAL then
            sprite:ReplaceSpritesheet(0, "gfx/souls/soul_ball_normal.png")
            sprite:LoadGraphics()
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_INIT, onNpcInit, SOUL_BALL_TYPE)

---@param npc EntityNPC
local function onNpcUpdate(_, npc)
    if npc.Variant == SOUL_BALL_VARIANT then
        if NORMAL then
            Game():SpawnParticles(npc.Position + PARTICLE_OFFSET, PARTICLE_TYPE, PARTICLE_COUNT, PARTICLE_SPEED, NORMAL_PARTICLE_COLOR, PARTICLE_HEIGHT, PARTICLE_SUBTYPE)
        else
            Game():SpawnParticles(npc.Position + PARTICLE_OFFSET, PARTICLE_TYPE, PARTICLE_COUNT, PARTICLE_SPEED, PARTICLE_COLOR, PARTICLE_HEIGHT, PARTICLE_SUBTYPE)
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, onNpcUpdate, SOUL_BALL_TYPE)