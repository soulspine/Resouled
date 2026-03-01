local CONFIG = {
    -- this means that it will try to find a host that has more hp than this percentage,
    -- if it fails to do that, it will consider all enemies in the room
    PrefferedHostHpThreshold = 0.3,
    DamageTransferPercentage = 0.35,
    TrailColor = Color(1, 0, 1),
    MoveSpeed = 5,
    -- distance within which ghost has to be to be considered attached to the host
    HostAttachmentDistance = 10,
    -- in updates, time after which ghost will look for a new host
    HostChangeCountdown = 420,
    Aura = {
        Lifespan = 100,
        MaxSimultaneous = 3,
        Color = Color(0.75 / 1.5, 0.25 / 1.5, 1 / 1.5, 0.7),
        MaxScaleMult = 1.5
    },
}

local CONST = {
    Ent = Resouled:GetEntityByName("Resouled Haunted Ghost"),
    Trail = Resouled:EntityDescConstructor(EntityType.ENTITY_EFFECT, EffectVariant.SPRITE_TRAIL, 0),
    Anim = {
        Idle = "Idle",
        Appear = "Appear",
    }
}

---@param rng RNG
---@return EntityRef | nil
local function findPossessionHost(rng)
    local prefferedHosts = {}
    local allHosts = {}
    Resouled.Iterators:IterateOverRoomEntities(function(entity)
        local npc = entity:ToNPC()
        if (npc and not Resouled:MatchesEntityDesc(npc, CONST.Ent)
                and npc:IsVulnerableEnemy()
                and npc:IsActiveEnemy()
                and npc:GetData().Resouled__PossessedByHauntedGhost == nil
            ) then
            table.insert(allHosts, EntityRef(npc))
            if (npc.HitPoints / npc.MaxHitPoints > CONFIG.PrefferedHostHpThreshold) then
                table.insert(prefferedHosts, allHosts[#allHosts])
            end
        end
    end)

    local choices = (#prefferedHosts == 0) and allHosts or prefferedHosts

    if (#choices == 0) then
        return nil
    else
        return choices[rng:RandomInt(#choices) + 1]
    end
end

local POP_VELOCITY = Vector(2, 0)
local POP_COOLDOWN = 30
---@param entity Entity
local function popGhost(entity)
    entity.Velocity = POP_VELOCITY:Rotated(math.random() * 360)
    entity:GetData().Resouled__HauntedGhost.PopTimer = POP_COOLDOWN
end

---@param npc EntityNPC
local function onGhostInit(_, npc)
    if (not Resouled:MatchesEntityDesc(npc, CONST.Ent)) then return end
    npc:GetSprite():Play(CONST.Anim.Appear, true)
    npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
    npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS

    local trail = Game():Spawn(
        CONST.Trail.Type,
        CONST.Trail.Variant,
        npc.Position,
        Vector.Zero,
        npc,
        CONST.Trail.SubType,
        Resouled:NewSeed()
    ):ToEffect();
    if (not trail) then return end

    trail.Parent = npc
    trail:FollowParent(npc)
    trail.Color = CONFIG.TrailColor

    npc:GetData().Resouled__HauntedGhost = {
        Rng = RNG(npc.InitSeed, 67),
        Host = nil,              -- will be set after spawning animation
        HostChangeCountdown = 0, -- 0 at first so it chooses a new host immediately after properly spawning

        -- if its attached, its gonna be immune to direct attacks but will take a portion of any damage the host takes,
        -- if its not attached, its moving towards its new host and is vulnerable atp but only to spectral damage
        Attached = false,
        Trail = EntityRef(trail),
    }
    popGhost(npc)
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_INIT, onGhostInit, CONST.Ent.Type)

---@param npc EntityNPC
local function onGhostUpdate(_, npc)
    if (not Resouled:MatchesEntityDesc(npc, CONST.Ent)) then return end
    local sprite = npc:GetSprite()
    local data = npc:GetData().Resouled__HauntedGhost

    -- play proper animation after appear
    if (sprite:IsFinished(CONST.Anim.Appear)) then
        sprite:Play(CONST.Anim.Idle, true)
    end

    -- return if still spawning
    if (sprite:IsPlaying(CONST.Anim.Appear)) then
        return;
    end

    if (data.HostChangeCountdown > 0) then
        data.HostChangeCountdown = data.HostChangeCountdown - 1
    end

    -- find new host if countdown goes down to 0
    local findNewHost = (data.HostChangeCountdown == 0)

    if (data.Host ~= nil) then
        local host = data.Host.Entity:ToNPC()
        if (host and host:IsDead()) then
            -- find new host when current one is dead
            findNewHost = true
        end
    else
        -- find new host if there is no host now
        findNewHost = true
    end

    if (findNewHost) then
        if (data.Host) then
            data.Host.Entity:GetData().Resouled__PossessedByHauntedGhost = nil
        end

        data.Host = findPossessionHost(data.Rng)
        -- no more valid hosts, just die
        if (data.Host == nil) then
            npc:Die()
            return
        end
        popGhost(npc)
        data.Attached = false;
        data.HostChangeCountdown = CONFIG.HostChangeCountdown

        -- add host buff here
    end

    if (npc.Position:Distance(data.Host.Entity.Position) <= CONFIG.HostAttachmentDistance) then
        data.Attached = true
        data.Host.Entity:GetData().Resouled__PossessedByHauntedGhost = EntityRef(npc)
    end

    -- update visibility and position
    npc.Visible = not data.Attached
    if (data.Attached) then
        npc.Position = data.Host.Entity.Position
    elseif (data.Host ~= nil) then
        local toPlayer = data.Host.Entity.Position - npc.Position
        local frameCount = data.PopTimer


        if frameCount and frameCount < 0 then
            npc.Velocity = (npc.Velocity + toPlayer * math.min(frameCount ^ 2) / (1000 - frameCount)) * 0.05
        end
    end

    if data.PopTimer then
        data.PopTimer = data.PopTimer - 1
        if data.PopTimer > -1 then
            npc.Velocity = npc.Velocity * 0.85
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_NPC_UPDATE, onGhostUpdate, CONST.Ent.Type)

---@param entity Entity
---@param amount number
---@param damageFlags DamageFlag
---@param source EntityRef
---@param countdown integer
local function onNpcTakeDamage(_, entity, amount, damageFlags, source, countdown)
    local data = entity:GetData()
    local src = source.Entity and
        (source.Entity:ToPlayer() or source.Entity:ToTear() or source.Entity:ToLaser() or source.Entity:ToKnife()) or nil

    -- make ghost only take damage with spectral flag and if its not attached
    if (src and Resouled:MatchesEntityDesc(entity, CONST.Ent)) then
        if (data.Resouled__HauntedGhost.Attached)
        then
            if (data.Resouled__HauntedGhostValidDamageTick) then
                data.Resouled__HauntedGhostValidDamageTick = nil
                return                                                 -- sustain the damage since its transferred
            else
                return false                                           -- negate it
            end
        else                                                           -- not attached
            -- checking .l here because its a 128bit container, i need to extract the lower part
            if ((src.TearFlags & TearFlags.TEAR_SPECTRAL).l == 0) then -- no spectral
                return false
            end
        end
        print("non-attached damage", src.TearFlags & TearFlags.TEAR_SPECTRAL == 1)
    else -- other enemies, make damage get transferred to the ghost if its currently possessing that entity
        local npc = entity:ToNPC();
        if not (npc) then return; end

        ---@type EntityRef | nil
        local ghost = data.Resouled__PossessedByHauntedGhost;
        if (not ghost) then return; end

        ghost.Entity:GetData().Resouled__HauntedGhostValidDamageTick = true
        ghost.Entity:TakeDamage(
            amount * CONFIG.DamageTransferPercentage,
            damageFlags,
            source,
            countdown
        )
    end
end
Resouled:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, onNpcTakeDamage)

---@param npc EntityNPC
local function onNpcRender(_, npc)
    if npc:GetData().Resouled__PossessedByHauntedGhost then
        local sprite = npc:GetSprite()
        local colorPre = Color(sprite.Color.R, sprite.Color.G, sprite.Color.B, sprite.Color.A)
        local scalePre = Vector(sprite.Scale.X, sprite.Scale.Y)

        sprite.Color = Color(0, 0, 0, 0, CONFIG.Aura.Color.R, CONFIG.Aura.Color.G, CONFIG.Aura.Color.B)

        local frameCount = npc.FrameCount % CONFIG.Aura.Lifespan
        for i = 1, CONFIG.Aura.MaxSimultaneous do
            local auraStrength = ((frameCount - (CONFIG.Aura.Lifespan / CONFIG.Aura.MaxSimultaneous) * (i - 1)) %
                CONFIG.Aura.Lifespan) / CONFIG.Aura.Lifespan

            sprite.Color.A = (1 - auraStrength) * CONFIG.Aura.Color.A
            sprite.Scale = scalePre + auraStrength * (CONFIG.Aura.MaxScaleMult - 1) * Vector.One
            sprite:Render(Isaac.WorldToScreen(npc.Position + npc.Size * sprite.Scale.Y * Vector(0, 0.25)))
        end

        sprite.Scale = scalePre
        sprite.Color = colorPre
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_NPC_RENDER, onNpcRender)

---@param npc EntityNPC
Resouled:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, npc)
    local data = npc:GetData()
    npc:SetSpeedMultiplier(1)
    if not data.Resouled__PossessedByHauntedGhost then return end

    npc:SetSpeedMultiplier(1.5)
    print(npc:GetSpeedMultiplier())
end)
