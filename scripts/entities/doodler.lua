local game = Game()

local CONST = {
    Ent = Resouled:GetEntityByName("Resouled Doodler"),
    Anim = {
        Base = {
            Idle = {
                Name = "Idle",
                Len = 1,
            },
            WalkForward = {
                Name = "WalkForward",
                Len = 26,
            },
            WalkRight = {
                Name = "WalkRight",
                Len = 26,
            },
            WalkLeft = {
                Name = "WalkLeft",
                Len = 26,
            },
            RunForward = {
                Name = "RunForward",
                Len = 20,
            },
            RunRight = {
                Name = "RunRight",
                Len = 20,
            },
            RunLeft = {
                Name = "RunLeft",
                Len = 20,
            },
        },
        Overlay = {
            HeadDownOpen = {
                Name = "HeadDownOpen",
                Len = 1,
            },
            HeadDown = {
                Name = "HeadDown",
                Len = 1,
            },
            HeadDownLifted = {
                Name = "HeadDownLifted",
                Len = 1,
            },
        },
        Death = "Death"
    },

    MinWalkDistance = 250,
    MaxWalkDistance = 750,
    DistanceFromWallsToBlockWalkDir = 150,
}

---@param vel Vector
---@return string
local function getBodyAnimationFromVelocity(vel)
   
    if vel:Length() < 0.1 then
        return CONST.Anim.Base.Idle.Name
    end

    local angle = vel:GetAngleDegrees()%360
    
    if angle < 45 or angle >= 315 then
        return CONST.Anim.Base.WalkRight.Name
    elseif (angle >= 45 and angle < 135) or (angle >= 225 and angle < 315) then
        return CONST.Anim.Base.WalkForward.Name
    elseif angle >= 135 and angle < 225 then
        return CONST.Anim.Base.WalkLeft.Name
    end

    return CONST.Anim.Base.Idle.Name
end

---@param pos Vector
---@return Vector
local function chooseTargetPos(pos)
    local distance = math.random(CONST.MinWalkDistance, CONST.MaxWalkDistance)
    local room = game:GetRoom()
    local topLeft = room:GetTopLeftPos()
    local bottomRight = room:GetBottomRightPos()
    local center = room:GetCenterPos()
    local blockedDirections = {}

    if pos.X - topLeft.X < CONST.DistanceFromWallsToBlockWalkDir then
        blockedDirections[Direction.LEFT] = true
    end
    if pos.X - bottomRight.X > -CONST.DistanceFromWallsToBlockWalkDir then
        blockedDirections[Direction.RIGHT] = true
    end
    if pos.Y - topLeft.Y < CONST.DistanceFromWallsToBlockWalkDir then
        blockedDirections[Direction.LEFT] = true
    end
    if pos.X - bottomRight.Y > -CONST.DistanceFromWallsToBlockWalkDir then
        blockedDirections[Direction.LEFT] = true
    end

    local validDirections = {}
    for i = 0, 3 do
        if not blockedDirections[i] then
            local addChance = false

            if i == 0 and pos.X > center.X then addChance = true
            elseif i == 1 and pos.Y > center.Y then addChance = true
            elseif i == 2 and pos.X < center.X then addChance = true
            elseif i == 3 and pos.Y < center.Y then addChance = true
            end

            table.insert(validDirections, i)
            if addChance == true then for _ = 1, 2 - i%2 do table.insert(validDirections, i) end end
        end
    end
    local walkDir = validDirections[math.random(#validDirections)]

    return Isaac.GetFreeNearPosition(pos + Vector(-distance, 0):Rotated(90 * walkDir), 24)
end

---@param doodler EntityNPC
local function onDooderInit(_, doodler)
    if not Resouled:MatchesEntityDesc(doodler, CONST.Ent) then return end

    local sprite = doodler:GetSprite()
    sprite:Play(CONST.Anim.Base.WalkForward.Name, true)
    sprite:PlayOverlay(CONST.Anim.Overlay.HeadDown.Name, true)
    doodler:GetData().Resouled_Doodler = {}

    doodler.State = NpcState.STATE_MOVE
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_INIT, onDooderInit, CONST.Ent.Type)

---@param doodler EntityNPC
local function onDoodlerUpdate(_, doodler)
    if not Resouled:MatchesEntityDesc(doodler, CONST.Ent) then return end
    
    local playerTarget = doodler:GetPlayerTarget()
    local sprite = doodler:GetSprite()
    local room = game:GetRoom()
    local data = doodler:GetData().Resouled_Doodler
    
    doodler.Velocity = doodler.Velocity * 0.9

    
    if doodler.State == NpcState.STATE_MOVE then
        local bodyAnim = getBodyAnimationFromVelocity(doodler.Velocity)
        if sprite:GetAnimation() ~= bodyAnim then
            sprite:Play(bodyAnim, true)
        end

        if not data.TargetPos then data.TargetPos = chooseTargetPos(doodler.Position) end

        doodler.Pathfinder:FindGridPath(data.TargetPos, 0.75, 0, false)

        if doodler.Position:Distance(data.TargetPos) < 50 then
            data.TargetPos = nil

            --doodler.State = NpcState.STATE_IDLE
            --data.WalkCooldown = 30
        end
    elseif doodler.State == NpcState.STATE_IDLE then
        
        if data.WalkCooldown then
            data.WalkCooldown = data.WalkCooldown - 1

            if data.WalkCooldown <= 0 then
                data.WalkCooldown = nil
                doodler.State = NpcState.STATE_MOVE
            end
        end

        doodler.Velocity = doodler.Velocity * 0.75

    elseif doodler.State == NpcState.STATE_SUICIDE then
        
        if not sprite:IsPlaying(CONST.Anim.Death) then sprite:Play(CONST.Anim.Death) end
        sprite:RemoveOverlay()

        if sprite:IsEventTriggered("Explosion") then
            game:BombExplosionEffects(doodler.Position + Vector(0, 1), 0, nil, nil, nil, 1.35, false, nil, DamageFlag.DAMAGE_FAKE)
        end

        if sprite:IsFinished(CONST.Anim.Death) then

            Resouled:SpawnPaperGore(doodler.Position, 20, 2)
            Resouled:SpawnPaperGore(doodler.Position, 40, 1.5)
            Resouled:SpawnPaperGore(doodler.Position, 40, 1)

            doodler:Kill()

        end

        doodler.Velocity = doodler.Velocity * 0.9
    end

end
Resouled:AddCallback(ModCallbacks.MC_NPC_UPDATE, onDoodlerUpdate, CONST.Ent.Type)

---@param en Entity
---@param am number
local function preNpcTakeDMG(_, en, am)
    if not Resouled:MatchesEntityDesc(en, CONST.Ent) then return end
    local npc = en:ToNPC()
    if not npc then return end
    if npc.State == NpcState.STATE_SUICIDE then return false end -- STATE_SUICIDE because STATE_DEATH and STATE_DEATH_UNIQUE stopped npc updates
    if am > npc.HitPoints then npc.State = NpcState.STATE_SUICIDE npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE return false end
end
Resouled:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, preNpcTakeDMG, CONST.Ent.Type)
