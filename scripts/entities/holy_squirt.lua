local ENTITY = Resouled:GetEntityByName("Holy Squirt")

local CONFIG = {
    EntityFlags = EntityFlag.FLAG_NO_BLOOD_SPLASH,
    EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL,
    GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS,
    TrailColor = Color(0.25, 0.2, 0.12, 1, 0.15, 0.15, 0.15),
    TrailRadius = 0.067,
    TrailScale = Vector.One * 4.5,
    TrailParentOffset = Vector(0, -15),
    ShitCooldown = 2 or Isaac.GetEntityTypeByName("Holy Portal"), -- how often it will spawn creep while dashing
    ShitLifespan = 90, -- how long the creep will last
    AfterSpawnDashCooldown = 30,
    DashVelocityLengthGain = 0.7, -- how much velocity it will gain per update while dashing, up to the max
    MaxDashVelocityLength = 12, -- max velocity length while dashing
    DashDuration = "∞", -- unused (spierdalaj)
    OnDeathDipSpawnCount = 2
}

local CONSTANTS = {
    Animations = {
        Appear = "Appear",
        Attack1 = "Attack01",
        Idle = "Idle",
        Dash = "Slide",
        Flush = "Flush",
    }
}

---@param npc EntityNPC
local function onNpcInit(_, npc)
    if not Resouled:MatchesEntityDesc(npc, ENTITY) then return end
    npc:GetSprite():Play(CONSTANTS.Animations.Appear, true)
    npc:GetData().Resouled__HolySquirt = {
        DashCooldown = CONFIG.AfterSpawnDashCooldown,
        ShitCooldown = CONFIG.ShitCooldown
    }
    npc:AddEntityFlags(CONFIG.EntityFlags)
    npc.EntityCollisionClass = CONFIG.EntityCollisionClass
    npc.GridCollisionClass = CONFIG.GridCollisionClass


    local trail = Game():Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SPRITE_TRAIL, npc.Position, Vector.Zero, npc, 0,
        Resouled:NewSeed()):ToEffect()
    if not trail then return end
    trail:FollowParent(npc)
    trail.Color = CONFIG.TrailColor
    trail.MinRadius = CONFIG.TrailRadius
    trail.SpriteScale = CONFIG.TrailScale

    trail.ParentOffset = CONFIG.TrailParentOffset

    trail:GetData().Update = true
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_INIT, onNpcInit, ENTITY.Type)

---@param npc EntityNPC
local function onNpcUpdate(_, npc)
    if not Resouled:MatchesEntityDesc(npc, ENTITY) then return end

    local data = npc:GetData().Resouled__HolySquirt
    local sprite = npc:GetSprite()

    sprite.FlipX = npc.Velocity.X < 0

    if sprite:IsFinished(CONSTANTS.Animations.Appear) then
        sprite:Play(CONSTANTS.Animations.Idle, true)
        npc.State = NpcState.STATE_IDLE
    end

    if data.DashCooldown > 0 then
        data.DashCooldown = data.DashCooldown - 1
        return
    elseif data.DashCooldown == 0 then
        data.DashCooldown = -1
        sprite:Play(CONSTANTS.Animations.Attack1, true)
    end

    if sprite:IsFinished(CONSTANTS.Animations.Attack1) then
        sprite:Play(CONSTANTS.Animations.Dash, true)

        npc.State = NpcState.STATE_ATTACK
    end

    if npc.State == NpcState.STATE_ATTACK then
        local velocity = npc.Velocity
        velocity = velocity +
            (npc:GetPlayerTarget().Position - npc.Position):Normalized() * CONFIG.DashVelocityLengthGain

        if velocity:Length() > CONFIG.MaxDashVelocityLength then
            velocity = velocity:Resized(CONFIG.MaxDashVelocityLength)
        end

        npc.Velocity = velocity

        if Isaac.GetFrameCount() % CONFIG.ShitCooldown == 0 then
            local creep = Game():Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CREEP_SLIPPERY_BROWN, npc.Position,
                Vector.Zero, npc, 0, Resouled:NewSeed()):ToEffect()
            if not creep then return end
            creep:Update()
            creep:SetTimeout(CONFIG.ShitLifespan)
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_NPC_UPDATE, onNpcUpdate, ENTITY.Type)

---@param npc EntityNPC
local function onNpcDeath(_, npc)
    if not Resouled:MatchesEntityDesc(npc, ENTITY) then return end
    local dip = Resouled:GetEntityByName("Holy Dip")
    for _ = 1, CONFIG.OnDeathDipSpawnCount do
        Game():Spawn(dip.Type, dip.Variant, npc.Position, Vector.Zero, npc, dip.SubType, Resouled:NewSeed())
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, onNpcDeath, ENTITY.Type)
