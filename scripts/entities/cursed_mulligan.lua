local ID = EntityType.ENTITY_MULLIGAN
local VARIANT = Isaac.GetEntityVariantByName("Cursed Mulligan")
local SUBTYPE = Isaac.GetEntitySubTypeByName("Cursed Mulligan")

Resouled:RegisterCursedEnemyMorph(EntityType.ENTITY_MULLIGAN, 0, nil, ID, VARIANT, SUBTYPE)

local FLY_LIGHT_COLOT = Color(200/255, 128/255, 128/255, 255/255, 128/255, 0, 255/255)
local FLY_TAIL_CONFIG = {
    Color = Color(0.5, 0, 1, 0.25),
    Length = 0.1,
    Offset = Vector(0, -16),
}

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
            if npc2 then
                local data = npc2:GetData()
                
                if npc2.Index ~= npc.Index and npc2.Type ~= npc.Type and npc2:IsActiveEnemy() and npc2:IsEnemy() and npc2:IsVulnerableEnemy() and not (npc.SpawnerEntity and npc.SpawnerEntity.Index == npc2.Index) and
                not data.Resouled_NoCursedMulliganTargetting
                then
                    local weight = math.floor(npc2.HitPoints/npc2.MaxHitPoints * 100 + math.abs(maxDistance - npc2.Position:Distance(npc.Position)/2) + 0.5)
                    if data.Resouled_CursedMulliganDeath then
                        weight = math.max(weight - 15, 0)
                    end
                    enemies:AddOutcomeWeight(npc2.Index, weight)
                    enemiesIndexes[npc2.Index] = npc2
                end
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
    end,
    MinDistanceFromPlayerToDie = 10,
}

CurseFlyConfig.spawn =
---@param npc EntityNPC
---@return EntityNPC
function(npc)
    ---@type EntityNPC
    local fly = Game():Spawn(CurseFlyConfig.Type, CurseFlyConfig.Variant, npc.Position, Vector.Zero, npc, CurseFlyConfig.SubType, Random() + 1):ToNPC()
    CurseFlyConfig.smoke(fly, 2, 0.75)
    return fly
end

local ON_DEATH_SPAWNS = {
    [1] = {
        T = EntityType.ENTITY_FLY,
        V = 0,
        S = 0,
        Weight = 1,
        Count = 1
    },
    [2] = {
        T = EntityType.ENTITY_ATTACKFLY,
        V = 0,
        S = 0,
        Weight = 0.5,
        Count = 1
    },
    [3] = {
        T = EntityType.ENTITY_SPIDER,
        V = 0,
        S = 0,
        Weight = 0.5,
        Count = 1
    },
    [4] = {
        T = EntityType.ENTITY_POOTER,
        V = 0,
        S = 0,
        Weight = 0.25,
        Count = 1
    },
}
local ON_DEATH_CURSE_FLY_SPAWN_MIN_COUNT = 2
local ON_DEATH_CURSE_FLY_SPAWN_MAX_COUNT = 5

local ON_DEATH_FROM_POOL_SPAWN_MIN_COUNT = 1
local ON_DEATH_FROM_POOL_SPAWN_MAX_COUNT = 2

local DEATH_POOL = WeightedOutcomePicker()

for key, config in pairs(ON_DEATH_SPAWNS) do
    DEATH_POOL:AddOutcomeWeight(key, config.Weight * 100)
end

---@param npc EntityNPC
local function curseMulliganDeathEffect(npc)
    local rng = RNG(npc.InitSeed)

    local spawnCount = rng:RandomInt(ON_DEATH_CURSE_FLY_SPAWN_MIN_COUNT, ON_DEATH_CURSE_FLY_SPAWN_MAX_COUNT)

    for _ = 1, spawnCount do
        CurseFlyConfig.spawn(npc)
    end
end

---@param npc EntityNPC
local function curseMulliganCurseDeathEffect(npc)
    local rng = RNG(npc.InitSeed)

    local spawnCount = rng:RandomInt(ON_DEATH_FROM_POOL_SPAWN_MIN_COUNT, ON_DEATH_FROM_POOL_SPAWN_MAX_COUNT)

    for _ = 1, spawnCount do
        local config = ON_DEATH_SPAWNS[DEATH_POOL:PickOutcome(rng)]
        for _ = 1, config.Count do
            local spawn = Game():Spawn(config.T, config.V, npc.Position, Vector.Zero, npc, config.S, rng:GetSeed())
            spawn:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
            spawn.Color = Color(1, 1, 1, 1, 0.125, 0, 0.25)
            spawn:GetData().Resouled_NoCursedMulliganTargetting = true
        end
        Resouled:NewSeed()
    end
end

---@param npc EntityNPC
local function onNpcDeath(_, npc)
    if npc.Variant == VARIANT and npc.SubType == SUBTYPE then
        curseMulliganDeathEffect(npc)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, onNpcDeath, ID)

---@param entity Entity
---@param amount number
local function npcTakeDMG(_, entity, amount)
    if amount > entity.HitPoints then
        local npc = entity:ToNPC()
        if npc and npc:GetData().Resouled_CursedMulliganDeath then
            curseMulliganCurseDeathEffect(npc)
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, npcTakeDMG)

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


        local entityParent = npc
        local trail = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SPRITE_TRAIL, 0, entityParent.Position,
        Vector.Zero, entityParent):ToEffect()
        if trail then
            trail:FollowParent(entityParent)
            trail.Color = FLY_TAIL_CONFIG.Color
            trail.MinRadius = FLY_TAIL_CONFIG.Length
            trail.SpriteScale = Vector.One
            
            trail.ParentOffset = FLY_TAIL_CONFIG.Offset * 1.5
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_INIT, onNpcInit)

---@param npc EntityNPC
local function onNpcUpdate(_, npc)
    if npc.Type == CurseFlyConfig.Type and npc.Variant == CurseFlyConfig.Variant and npc.SubType == CurseFlyConfig.SubType then
        local sprite = npc:GetSprite()

        local players = Isaac.FindInRadius(npc.Position, CurseFlyConfig.MinDistanceFromPlayerToDie, EntityPartition.PLAYER)
        if #players > 0 then
            CurseFlyConfig.smoke(npc, 2, 0.75)
            npc:Die()
        end

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
            SFXManager():Play(SoundEffect.SOUND_BIRD_FLAP, 0.25, nil, nil, 1.5)
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

            local fly = Game():Spawn(EntityType.ENTITY_FLY, 0, npc.Target.Position + npc.Velocity:Resized(15), npc.Velocity, npc, 0, Random() + 1)
            fly:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
            fly.Velocity = npc.Velocity

            color = fly:GetColor()
            color.RO = color.RO + 0.5
            color.BO = color.BO + 1
            fly:SetColor(color, 10, 1, true, true)

            npc.Target:GetData().Resouled_CursedMulliganDeath = true

            npc:Die()
        end
    elseif npc.Type == ID and npc.Variant == VARIANT and npc.SubType == SUBTYPE then
        local sprite = npc:GetSprite()

        if npc.FrameCount % 100 == 0 then
            sprite:PlayOverlay("ResouledSpewFly", true)
            npc.State = NpcState.STATE_ATTACK
        end

        if sprite:IsOverlayEventTriggered("ResouledShoot") then
            CurseFlyConfig.spawn(npc)

            local color = npc:GetColor()
            color.RO = color.RO + 0.5
            color.BO = color.BO + 1
            npc:SetColor(color, 10, 1, true, true)
        end

        if sprite:IsOverlayFinished("ResouledSpewFly") then
            npc.State = NpcState.STATE_MOVE
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_NPC_UPDATE, onNpcUpdate)

Resouled.StatTracker:RegisterCursedEnemy(ID, VARIANT, SUBTYPE)