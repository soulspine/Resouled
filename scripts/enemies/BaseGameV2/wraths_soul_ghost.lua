local WRATHS_SOUL_GHOST_TYPE = Isaac.GetEntityTypeByName("Wrath's Soul Ghost")
local WRATHS_SOUL_GHOST_VARIANT = Isaac.GetEntityVariantByName("Wrath's Soul Ghost")
local WRATHS_SOUL_GHOST_SUBTYPE = 2

local WRATHS_SOUL_SUBTYPE = 0

local TENTACLES_SUBTYPE = 3
local TENTACLES_OFFSET = Vector(0, -57)
local TENTACLES_ENTITY_COLLISION_CLASS = EntityCollisionClass.ENTCOLL_NONE
local TENTACLES_GRID_COLLISION_CLASS = EntityGridCollisionClass.GRIDCOLL_NONE
local TENTACLES_DEPTH_OFFSET = 100

local GHOST_GRID_COLLISION_CLASS = EntityGridCollisionClass.GRIDCOLL_WALLS

local DASH_ACTIVATION_DISTANCE = 75
local DASH_VELOCITY_MULTIPLIER = 5
local DASH_VELOCITY_DROP_STOP = 1.05
local DASH_COOLDOWN = 0.75 --seconds

local SPEED_MULTIPLIER = 3

local NORMAL = true

---@param npc EntityNPC
local function onNpcInit(_, npc)
    if npc.Variant == WRATHS_SOUL_GHOST_VARIANT and npc.SubType == WRATHS_SOUL_GHOST_SUBTYPE then
        local sprite = npc:GetSprite()
        local data = npc:GetData()
        sprite:Play("Idle", true)
        if NORMAL then
        end
        npc.GridCollisionClass = GHOST_GRID_COLLISION_CLASS

        data.Dashing = false
        data.DashCooldown = 0
        data.DashVelocityDropStop = false
        data.tentacles = Game():Spawn(WRATHS_SOUL_GHOST_TYPE, WRATHS_SOUL_GHOST_VARIANT, npc.Position, Vector.Zero, npc, TENTACLES_SUBTYPE, npc.InitSeed)
        data.tentacles.DepthOffset = TENTACLES_DEPTH_OFFSET
        data.minion = Game():Spawn(WRATHS_SOUL_GHOST_TYPE, WRATHS_SOUL_GHOST_VARIANT, npc.Position, Vector.Zero, npc, WRATHS_SOUL_SUBTYPE, npc.InitSeed)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_INIT, onNpcInit, WRATHS_SOUL_GHOST_TYPE)

---@param npc EntityNPC
local function onNpcUpdate(_, npc)
    if npc.Variant == WRATHS_SOUL_GHOST_VARIANT and npc.SubType == WRATHS_SOUL_GHOST_SUBTYPE then
        local sprite = npc:GetSprite()
        local data = npc:GetData()
        if not data.Dashing then
            npc.Velocity = (npc:GetPlayerTarget().Position - npc.Position):Normalized() * (npc.Position:Distance(npc:GetPlayerTarget().Position) / (100/SPEED_MULTIPLIER))
        end

        if data.DashCooldown > 0 then
            data.DashCooldown = data.DashCooldown - 1
        end

        if data.DashCooldown <= 0 and data.Dashing then
            data.Dashing = false
        end

        if data.Dashing then
            npc.Velocity = npc.Velocity / DASH_VELOCITY_DROP_STOP
        end

        if npc.Position:Distance(npc:GetPlayerTarget().Position) < DASH_ACTIVATION_DISTANCE and not data.Dashing then
            data.Dashing = true
            data.DashCooldown = DASH_COOLDOWN * 30
            npc.Velocity = npc.Velocity * DASH_VELOCITY_MULTIPLIER
        end
        data.tentacles.Position = npc.Position + TENTACLES_OFFSET
        data.tentacles.Velocity = npc.Velocity

        if npc.HitPoints <= 0 then
            data.tentacles:Remove()
            data.minion:Die()
        end
        return true
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, onNpcUpdate, WRATHS_SOUL_GHOST_TYPE)

---@param npc EntityNPC
local function tentacleInit(_, npc)
    if npc.Variant == WRATHS_SOUL_GHOST_VARIANT and npc.SubType == TENTACLES_SUBTYPE then
        if NORMAL then
        end
        npc:GetSprite():Play("Idle", true)
        npc.GridCollisionClass = TENTACLES_GRID_COLLISION_CLASS
        npc.EntityCollisionClass = TENTACLES_ENTITY_COLLISION_CLASS
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_INIT, tentacleInit, WRATHS_SOUL_GHOST_TYPE)

---@param npc EntityNPC
local function disableTentacleAI(_, npc)
    if npc.Variant == WRATHS_SOUL_GHOST_VARIANT and npc.SubType == TENTACLES_SUBTYPE then
        return true
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, disableTentacleAI, WRATHS_SOUL_GHOST_TYPE)