local ENTITY = Resouled:GetEntityByName("Holy Dip")

local CONFIG = {
    EntityFlags = EntityFlag.FLAG_NO_BLOOD_SPLASH,
    EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL,
    GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS,
    AfterSpawnDashCooldown = 90,
    DashDuration = 90,
    ChargeVelocityGainX = 0.15,           -- how much velocity it will gain per update while charging up after spawning
    ChargeVelocityRangeY = 2,             -- how much velocity it will gain or lose per update while charging up after spawning
    MaxChargeVelocityVectorLength = 3,    -- max velocity it can reach while charging up after spawning
    MaxDashVelocityVectorLength = 20,     -- max velocity it can reach while dashing
    DashVelocityLengthGain = 2,           -- how much velocity it will gain per update while dashing, up to the max
    DashVelocityCollisionReduction = 0.4, -- how much velocity it will lose on collision while dashing
}

local CONSTANTS = {
    Animations = {
        Idle = "Idle",
        Dash = "Move",
        Flush = "Flush",
    }
}

---@param npc EntityNPC
local function onNpcInit(_, npc)
    if not Resouled:MatchesEntityDesc(npc, ENTITY) then return end
    npc:GetSprite():Play(CONSTANTS.Animations.Idle, true)
    npc:GetData().Resouled__HolyDip = {
        DashCooldown = CONFIG.AfterSpawnDashCooldown,
        DashDuration = CONFIG.DashDuration,
        RNG = RNG(npc.InitSeed, 22)
    }
    npc:AddEntityFlags(CONFIG.EntityFlags)
    npc.EntityCollisionClass = CONFIG.EntityCollisionClass
    npc.GridCollisionClass = CONFIG.GridCollisionClass
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_INIT, onNpcInit, ENTITY.Type)

---@param npc EntityNPC
local function onNpcUpdate(_, npc)
    if not Resouled:MatchesEntityDesc(npc, ENTITY) then return end

    local data = npc:GetData().Resouled__HolyDip
    local sprite = npc:GetSprite()
    ---@type RNG
    local rng = data.RNG

    if data.DashCooldown > 0 then
        data.DashCooldown = data.DashCooldown - 1
        local setNegative = npc.Velocity.X > 0

        npc.Velocity = Vector(
            math.abs(npc.Velocity.X) + CONFIG.ChargeVelocityGainX,
            npc.Velocity.Y + rng:RandomInt(-CONFIG.ChargeVelocityRangeY * 100, CONFIG.ChargeVelocityRangeY * 100) / 100
        )
        if setNegative then
            npc.Velocity = Vector(-npc.Velocity.X, npc.Velocity.Y)
        end

        if npc.Velocity:Length() > CONFIG.MaxChargeVelocityVectorLength then
            npc.Velocity = npc.Velocity:Resized(CONFIG.MaxChargeVelocityVectorLength)
        end

        return -- do nothing until cooldown is over
    elseif sprite:IsPlaying(CONSTANTS.Animations.Idle) then
        sprite:Play(CONSTANTS.Animations.Dash, true)
    end

    if data.DashDuration > 0 then
        local velLength = npc.Velocity:Length()
        if velLength < CONFIG.MaxDashVelocityVectorLength then
            npc.Velocity = npc.Velocity:Resized(velLength + CONFIG.DashVelocityLengthGain)
        else
            npc.Velocity = npc.Velocity:Resized(CONFIG.MaxDashVelocityVectorLength)
        end

        sprite.FlipX = npc.Velocity.X < 0

        local oValues = 1 - data.DashDuration / CONFIG.DashDuration

        sprite.Color = Color(
            sprite.Color.R,
            sprite.Color.G,
            sprite.Color.B,
            sprite.Color.A,
            oValues,
            oValues,
            oValues
        )

        data.DashDuration = data.DashDuration - 1
        return
    elseif sprite:IsPlaying(CONSTANTS.Animations.Dash) then
        npc.Velocity = Vector.Zero
        sprite:Play(CONSTANTS.Animations.Flush, true)
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        return
    end

    if sprite:IsFinished(CONSTANTS.Animations.Flush) then
        npc:Die()
    end
end
Resouled:AddCallback(ModCallbacks.MC_NPC_UPDATE, onNpcUpdate, ENTITY.Type)

---@param npc EntityNPC
---@param gridIndex integer
---@param gridEntity GridEntity | nil
local function onNpcGridCollision(_, npc, gridIndex, gridEntity)
    if not Resouled:MatchesEntityDesc(npc, ENTITY) then return end
    npc.Velocity = npc.Velocity * (1 - CONFIG.DashVelocityCollisionReduction)
end
Resouled:AddCallback(ModCallbacks.MC_PRE_NPC_GRID_COLLISION, onNpcGridCollision, ENTITY.Type)

local function onEntityTakeDamage(_, entity, amount, flags, source, countdown)
    if Resouled:MatchesEntityDesc(entity, ENTITY) then
        return false -- ignore all damage, make it only die after its dash
    end
end
Resouled:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, onEntityTakeDamage, ENTITY.Type)
