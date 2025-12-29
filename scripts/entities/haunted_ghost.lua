local CONFIG = {
    -- this means that it will try to find a host that has more hp than this percentage,
    -- if it fails to do that, it will consider all enemies in the room
    PrefferedHostHpThreshold = 0.3,
    TrailColor = Color(1, 0, 1),
    MoveSpeed = 5,
    -- distance within which ghost has to be to be considered attached to the host
    HostAttachmentDistance = 10,
    -- in updates, time after which ghost will look for a new host
    HostChangeCountdown = 420,
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
    local prefferedHosts = {};
    local allHosts = {};
    Resouled.Iterators:IterateOverRoomEntities(function(entity)
        local npc = entity:ToNPC();
        if (npc and not Resouled:MatchesEntityDesc(npc, CONST.Ent) and npc:IsVulnerableEnemy() and npc:IsActiveEnemy()) then
            table.insert(allHosts, EntityRef(npc));
            if (npc.HitPoints / npc.MaxHitPoints > CONFIG.PrefferedHostHpThreshold) then
                table.insert(prefferedHosts, allHosts[#allHosts]);
            end
        end
    end)

    local choices = (#prefferedHosts == 0) and allHosts or prefferedHosts;

    if (#choices == 0) then
        return nil;
    else
        return choices[rng:RandomInt(#choices) + 1];
    end
end

---@param npc EntityNPC
local function onGhostInit(_, npc)
    if (not Resouled:MatchesEntityDesc(npc, CONST.Ent)) then return; end
    npc:GetSprite():Play(CONST.Anim.Appear, true);
    npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS;
    npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS;

    local trail = Game():Spawn(
        CONST.Trail.Type,
        CONST.Trail.Variant,
        npc.Position,
        Vector.Zero,
        npc,
        CONST.Trail.SubType,
        Resouled:NewSeed()
    ):ToEffect();
    if (not trail) then return; end

    trail.Parent = npc;
    trail:FollowParent(npc);
    trail.Color = CONFIG.TrailColor

    npc:GetData().Resouled__HauntedGhost = {
        Rng = RNG(npc.InitSeed, 67),
        Host = nil,              -- will be set after spawning animation
        HostChangeCountdown = 0, -- 0 at first so it chooses a new host immediately after properly spawning

        -- if its attached, its gonna be immune to direct attacks but will take a portion of any damage the host takes,
        -- if its not attached, its moving towards its new host and is vulnerable atp but only to spectral damage
        Attached = false,
        Trail = EntityRef(trail),
    };
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_INIT, onGhostInit, CONST.Ent.Type)

---@param npc EntityNPC
local function onGhostUpdate(_, npc)
    if (not Resouled:MatchesEntityDesc(npc, CONST.Ent)) then return; end
    local sprite = npc:GetSprite();
    local data = npc:GetData().Resouled__HauntedGhost;

    -- play proper animation after appear
    if (sprite:IsFinished(CONST.Anim.Appear)) then
        sprite:Play(CONST.Anim.Idle, true);
    end

    -- return if still spawning
    if (sprite:IsPlaying(CONST.Anim.Appear)) then
        npc.Velocity = Vector.Zero;
        return;
    end

    if (data.HostChangeCountdown > 0) then
        data.HostChangeCountdown = data.HostChangeCountdown - 1;
    end

    -- find new host if countdown goes down to 0
    local findNewHost = (data.HostChangeCountdown == 0);

    if (data.Host ~= nil) then
        local host = data.Host.Entity:ToNPC();
        if (host and host:IsDead()) then
            -- find new host when current one is dead
            findNewHost = true;
        end
    else
        -- find new host if there is no host now
        findNewHost = true;
    end

    if (findNewHost) then
        if (data.Host) then
            -- remove host buff here
        end

        data.Host = findPossessionHost(data.Rng);
        -- no more valid hosts, just die
        if (data.Host == nil) then
            npc:Die();
            return;
        end
        data.Attached = false;
        data.HostChangeCountdown = CONFIG.HostChangeCountdown;

        -- add host buff here
    end

    if (npc.Position:Distance(data.Host.Entity.Position) <= CONFIG.HostAttachmentDistance) then
        data.Attached = true;
    end

    -- update visibility and position
    npc.Visible = not data.Attached;
    if (data.Attached) then
        npc.Position = data.Host.Entity.Position;
    elseif (data.Host ~= nil) then
        npc.Velocity = (data.Host.Entity.Position - npc.Position):Normalized() * CONFIG.MoveSpeed;
    end
end
Resouled:AddCallback(ModCallbacks.MC_NPC_UPDATE, onGhostUpdate, CONST.Ent.Type)
