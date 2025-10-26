local ENTITY = Resouled:GetEntityByName("Holy Dip")

local CONFIG = {
    EntityFlags = EntityFlag.FLAG_NO_BLOOD_SPLASH | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK,
    EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL,
    GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS,
    SpawnVelocityLength = 20,
    DashVelocityLengthDecrease = 0.03,    -- how much velocity it will lose per update
    DashVelocityCollisionReduction = 0.1, -- how much velocity % it will lose on collision while dashing
    DisappearDuration = 25,               -- how many updates it will take to disappear before dying
}

local CONSTANTS = {
    Animations = {
        Spawn = "Drop",
        Dash = "Spin",
    }
}

---@param npc EntityNPC
local function onNpcInit(_, npc)
    if not Resouled:MatchesEntityDesc(npc, ENTITY) then return end
    npc:GetSprite():Play(CONSTANTS.Animations.Spawn, true)
    npc:GetData().Resouled__HolyDip = {
        MaxVelocityLength = CONFIG.SpawnVelocityLength,
        InitialVelocityLength = CONFIG.SpawnVelocityLength,
        Dying = false,
    }
    ---@diagnostic disable-next-line: param-type-mismatch
    npc:AddEntityFlags(CONFIG.EntityFlags)
    npc.EntityCollisionClass = CONFIG.EntityCollisionClass
    npc.GridCollisionClass = CONFIG.GridCollisionClass
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_INIT, onNpcInit, ENTITY.Type)

---@param npc EntityNPC
local function onNpcUpdate(_, npc)
    if not Resouled:MatchesEntityDesc(npc, ENTITY) then return end

    local sprite = npc:GetSprite()

    if sprite:IsPlaying(CONSTANTS.Animations.Spawn) then return end
    if sprite:IsFinished(CONSTANTS.Animations.Spawn) then
        sprite:Play(CONSTANTS.Animations.Dash, true)
        npc.Velocity = (npc:GetPlayerTarget().Position - npc.Position):Resized(CONFIG.SpawnVelocityLength)
    end

    local data = npc:GetData().Resouled__HolyDip

    local velocityProgress = data.MaxVelocityLength / data.InitialVelocityLength

    sprite.PlaybackSpeed = velocityProgress

    if data.Dying then
        sprite.Color.A = sprite.Color.A - 1 / CONFIG.DisappearDuration

        if sprite.Color.A < 0 then
            npc:Die()
        end
        return
    end

    if velocityProgress > 0 then
        npc.Velocity = npc.Velocity:Resized(data.MaxVelocityLength)

        local oValues = 1 - velocityProgress

        sprite.Color = Color(
            sprite.Color.R,
            sprite.Color.G,
            sprite.Color.B,
            sprite.Color.A,
            oValues,
            oValues,
            oValues
        )

        data.MaxVelocityLength = math.max(0, data.MaxVelocityLength - CONFIG.DashVelocityLengthDecrease)
        return
    elseif sprite:IsPlaying(CONSTANTS.Animations.Dash) then
        data.Dying = true
    end
end
Resouled:AddCallback(ModCallbacks.MC_NPC_UPDATE, onNpcUpdate, ENTITY.Type)

---@param npc EntityNPC
---@param gridIndex integer
---@param gridEntity GridEntity | nil
local function onNpcGridCollision(_, npc, gridIndex, gridEntity)
    if not Resouled:MatchesEntityDesc(npc, ENTITY) then return end
    local data = npc:GetData()
    data.Resouled__HolyDip.MaxVelocityLength = data.Resouled__HolyDip.MaxVelocityLength *
        (1 - CONFIG.DashVelocityCollisionReduction)
end
Resouled:AddCallback(ModCallbacks.MC_PRE_NPC_GRID_COLLISION, onNpcGridCollision, ENTITY.Type)

local function onEntityTakeDamage(_, entity, amount, flags, source, countdown)
    if Resouled:MatchesEntityDesc(entity, ENTITY) then
        return false -- ignore all damage, make it only die after its dash
    end
end
Resouled:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, onEntityTakeDamage, ENTITY.Type)
