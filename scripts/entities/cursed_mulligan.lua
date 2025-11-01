local ID = EntityType.ENTITY_MULLIGAN
local VARIANT = Isaac.GetEntityVariantByName("Cursed Mulligan")
local SUBTYPE = Isaac.GetEntitySubTypeByName("Cursed Mulligan")

local FLY_LIGHT_COLOT = Color(200/255, 128/255, 128/255, 255/255, 128/255, 0, 255/255)

local CurseFlyConfig = {
    Type = Isaac.GetEntityTypeByName("Curse Fly"),
    Variant = Isaac.GetEntityVariantByName("Curse Fly"),
    SubType = Isaac.GetEntitySubTypeByName("Curse Fly"),
    ---@param npc EntityNPC
    ---@return EntityNPC
    chooseRandomTarget = function(npc)
        local enemiesIndexes = {}
        local enemies = WeightedOutcomePicker()

        local room = Game():GetRoom()
        local maxDistance = room:GetBottomRightPos().X - room:GetTopLeftPos().X

        for _, entity in pairs(Isaac.GetRoomEntities()) do
            local npc2 = entity:ToNPC()
            if npc2 and npc2.Index ~= npc.Index and npc2.Type ~= npc.Type and npc2:IsActiveEnemy() and npc2:IsEnemy() and npc2:IsVulnerableEnemy() then
                enemies:AddOutcomeWeight(npc2.Index, math.floor(npc2.HitPoints/npc2.MaxHitPoints * 100 + math.abs(maxDistance - npc2.Position:Distance(npc.Position)/2) + 0.5))
                enemiesIndexes[npc2.Index] = npc2
            end
        end
        return enemiesIndexes[enemies:PickOutcome(RNG(npc.InitSeed))]
    end,
    smoke = function(npc, size, alpha)
        local smoke = Game():Spawn(EntityType.ENTITY_EFFECT, EffectVariant.DARK_BALL_SMOKE_PARTICLE, npc.Position, npc.Velocity/2, nil, 0, Random() + 1):ToEffect()
        smoke.Timeout = 100
        smoke.SpriteOffset = Vector(0, -16)
        smoke.Color = Color(1, 1, 1, alpha, 0.5, 0, 1)
        smoke.SpriteScale = Vector(size, size)

        ---@diagnostic disable-next-line
        EntityEffect.CreateLight(smoke.Position, size, 10, 0, FLY_LIGHT_COLOT)
    end
}

local ON_DEATH_SPAWNS = {
    [1] = {
        T = EntityType.ENTITY_FLY,
        V = 0,
        S = 0,
        Weight = 0.25,
        Count = 1
    },
    [2] = {
        T = EntityType.ENTITY_ATTACKFLY,
        V = 0,
        S = 0,
        Weight = 1,
        Count = 1
    },
    [3] = {
        T = EntityType.ENTITY_SPIDER,
        V = 0,
        S = 0,
        Weight = 0.75,
        Count = 1
    },
    [4] = {
        T = EntityType.ENTITY_BIGSPIDER,
        V = 0,
        S = 0,
        Weight = 0.1,
        Count = 1
    },
    [5] = {
        T = EntityType.ENTITY_POOTER,
        V = 0,
        S = 0,
        Weight = 0.5,
        Count = 1
    },
    [6] = {
        T = EntityType.ENTITY_POOTER,
        V = 1, -- V shooting pooter
        S = 0,
        Weight = 0.1,
        Count = 1
    },
    [7] = {
        T = EntityType.ENTITY_SUCKER,
        V = 0,
        S = 0,
        Weight = 0.50,
        Count = 1
    },
    [8] = {
        T = EntityType.ENTITY_SUCKER,
        V = 1, -- the green one
        S = 0,
        Weight = 0.1,
        Count = 1
    },
    [9] = {
        T = EntityType.ENTITY_SUCKER,
        V = 3, -- the black one
        S = 0,
        Weight = 0.1,
        Count = 1
    },
    [10] = {
        T = EntityType.ENTITY_BOOMFLY,
        V = 0,
        S = 0,
        Weight = 0.1,
        Count = 1
    },
    [11] = {
        T = EntityType.ENTITY_SWARM,
        V = 0,
        S = 0,
        Weight = 0.2,
        Count = 1
    },
    [12] = {
        T = EntityType.ENTITY_SWARM_SPIDER,
        V = 0,
        S = 0,
        Weight = 0.2,
        Count = 5
    },
}
local ON_DEATH_SPAWN_MIN_COUNT = 3
local ON_DEATH_SPAWN_MAX_COUNT = 5

local DEATH_POOL = WeightedOutcomePicker()

for key, config in pairs(ON_DEATH_SPAWNS) do
    DEATH_POOL:AddOutcomeWeight(key, config.Weight * 100)
end

---@param npc EntityNPC
local function onNpcDeath(_, npc)
    if npc.Variant == VARIANT and npc.SubType == SUBTYPE then
        local rng = RNG(npc.InitSeed)

        local spawnCount = rng:RandomInt(ON_DEATH_SPAWN_MIN_COUNT, ON_DEATH_SPAWN_MAX_COUNT)

        for _ = 1, spawnCount do
            local config = ON_DEATH_SPAWNS[DEATH_POOL:PickOutcome(rng)]
            for _ = 1, config.Count do
                local spawn = Game():Spawn(config.T, config.V, npc.Position, Vector.Zero, npc, config.S, rng:GetSeed())
                spawn:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
            end
            Resouled:NewSeed()
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, onNpcDeath, ID)

---@param npc EntityNPC
local function onNpcInit(_, npc)
    if npc.Type == CurseFlyConfig.Type then
        npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        npc:AddEntityFlags(EntityFlag.FLAG_NO_BLOOD_SPLASH)

        npc.Target = CurseFlyConfig.chooseRandomTarget(npc)
        npc:GetSprite():Play("Idle", true)

        npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE

        npc.Velocity = Vector(10, 0):Rotated(math.random(360))

        npc:SetColor(Color(1, 1, 1, 0, 1), 3, 1, false, false)

        npc.CanShutDoors = false
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_INIT, onNpcInit)

---@param npc EntityNPC
local function onNpcUpdate(_, npc)
    if npc.Type == CurseFlyConfig.Type then
        local sprite = npc:GetSprite()

        if not npc.Target or npc.Target:IsDead() then
            npc.Target = CurseFlyConfig.chooseRandomTarget(npc)
            if not npc.Target then
                npc:Die()
                CurseFlyConfig.smoke(npc, 3, 0.5)
                return
            end
        end

        if sprite:IsEventTriggered("Flap") then
            CurseFlyConfig.smoke(npc, 1.25, 0.25)
        end

        local alpha = math.min(1, npc.Position:Distance(npc.Target.Position)/100, npc.FrameCount/15) * 1.5
        npc:SetColor(Color(1, 1, 1, alpha), 3, 1, false, false)

        sprite.Scale = Vector(alpha, alpha)
        local light = sprite:GetLayer("*Light")
        if light then
            light:SetSize(Vector(alpha, alpha))
        end
    
        local toTargetVector = (npc.Target.Position - npc.Position):Normalized()

        local frameCount = math.max(npc.FrameCount - 10, 0)

        npc.Velocity = (npc.Velocity + toTargetVector * math.min((frameCount * frameCount)/(100 + npc.FrameCount)/2, 100)) * 0.9

        sprite.PlaybackSpeed = math.max(npc.Velocity:Length()/5, 1)

        if npc.Position:Distance(npc.Target.Position) < npc.Target.Size + 15 and npc.Target.EntityCollisionClass ~= EntityCollisionClass.ENTCOLL_NONE then
            local color = npc.Target:GetColor()
            color.RO = color.RO + 0.5
            color.BO = color.BO + 1
            npc.Target:SetColor(color, 10, 1, true, true)

            CurseFlyConfig.smoke(npc, 3, 0.5)

            npc:Die()
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_NPC_UPDATE, onNpcUpdate)