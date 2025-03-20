local WRATHS_SOUL_GHOST_TYPE = Isaac.GetEntityTypeByName("Wrath's Soul Ghost")
local WRATHS_SOUL_GHOST_VARIANT = Isaac.GetEntityVariantByName("Wrath's Soul Ghost")
local WRATHS_SOUL_GHOST_SUBTYPE = 2

local NORMAL = true

local WRATHS_SOUL_SUBTYPE = 0

local TENTACLES_SUBTYPE = 3
local TENTACLES_OFFSET = Vector(0, -57)
local TENTACLES_ENTITY_COLLISION_CLASS = EntityCollisionClass.ENTCOLL_NONE
local TENTACLES_GRID_COLLISION_CLASS = EntityGridCollisionClass.GRIDCOLL_NONE
local TENTACLES_DEPTH_OFFSET = 100

local GHOST_GRID_COLLISION_CLASS = EntityGridCollisionClass.GRIDCOLL_WALLS

local MIN_SOULS = 1
local MAX_SOULS = 3
local SOULS_ENTITY_COLLISION_CLASS = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS

local PATHFIND_SPEED = 0.75

local ATTACK_COOLDOWN = 5 * 30 --seconds

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
        data.AttackCooldown = ATTACK_COOLDOWN

    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_INIT, onNpcInit, WRATHS_SOUL_GHOST_TYPE)

---@param npc EntityNPC
local function onNpcUpdate(_, npc)
    if npc.Variant == WRATHS_SOUL_GHOST_VARIANT and npc.SubType == WRATHS_SOUL_GHOST_SUBTYPE then
        local sprite = npc:GetSprite()
        local data = npc:GetData()
        
        npc.Pathfinder:FindGridPath(npc:GetPlayerTarget().Position, PATHFIND_SPEED, 0, true)
        
        data.tentacles.Position = npc.Position + TENTACLES_OFFSET
        data.tentacles.Velocity = npc.Velocity

        if npc.HitPoints <= 0 then
            data.tentacles:Remove()
            data.minion:Die()
        end

        data.AttackCooldown = data.AttackCooldown - 1
        if data.AttackCooldown == 0 then
            local VelocityTranslation = {
                [1] = Vector(2,2),
                [2] = Vector(-2,2),
                [3] = Vector(2,-2),
            }
            for _ = 1, math.random(MIN_SOULS, MAX_SOULS) do
                local ghost = Game():Spawn(EntityType.ENTITY_BEAST, 3, npc.Position, VelocityTranslation[_], npc, 0, npc.InitSeed)
                ghost.Target = npc:GetPlayerTarget()
                ghost.EntityCollisionClass = SOULS_ENTITY_COLLISION_CLASS
                data.AttackCooldown = ATTACK_COOLDOWN
            end
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

---@param npc EntityNPC
local function onNpcDeath(_, npc)
    if npc.Variant ~= WRATHS_SOUL_GHOST_VARIANT then
        Resouled:TrySpawnSoulPickup(Resouled.Souls.WRATH, npc.Position)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, onNpcDeath, WRATHS_SOUL_GHOST_TYPE)