local IsaacEnemy = {
    Animations = {
        Body = {
            Idle = "BodyIdle",
            Down = "WalkDown",
            Up = "WalkUp",
            Left = "WalkLeft",
            Right = "WalkRight"
        },
        Head = {
            Down = "HeadDown",
            Up = "HeadUp",
            Left = "HeadLeft",
            Right = "HeadRight",
            ShootDown = "ShootDown",
            ShootUp = "ShootUp",
            ShootLeft = "ShootLeft",
            ShootRight = "ShootRight"
        },
        Extra = {
            Death = "Death",
            Hit = "Hit"
        }
    },
    Sounds = {
        Death = SoundEffect.SOUND_ISAACDIES,
        Hit = SoundEffect.SOUND_ISAAC_HURT_GRUNT
    },
    Type = Isaac.GetEntityTypeByName("Isaac Enemy"),
    Variant = Isaac.GetEntityVariantByName("Isaac Enemy"),
    SubType = Isaac.GetEntitySubTypeByName("Isaac Enemy"),

    ProjectileAvoidanceRange = 100,
    ShootCooldown = 40,
    ShootField = 20
}
local game = Game()
local sfx = SFXManager()

local SpritesheetPath = "gfx/characters/costumes/character_001_isaac.png"

local Animations = IsaacEnemy.Animations
local SoundsIsac = IsaacEnemy.Sounds

local bodyAnimFromDirection = {
    [Direction.NO_DIRECTION] = Animations.Body.Idle,
    [Direction.UP] = Animations.Body.Up,
    [Direction.DOWN] = Animations.Body.Down,
    [Direction.LEFT] = Animations.Body.Left,
    [Direction.RIGHT] = Animations.Body.Right
}
local headAnimFromDirection = {
    [Direction.NO_DIRECTION] = Animations.Head.Down,
    [Direction.UP] = Animations.Head.Up,
    [Direction.DOWN] = Animations.Head.Down,
    [Direction.LEFT] = Animations.Head.Left,
    [Direction.RIGHT] = Animations.Head.Right
}
local shootAnimFromDir = {
    [0] = Animations.Head.ShootRight,
    [1] = Animations.Head.ShootDown,
    [2] = Animations.Head.ShootLeft,
    [3] = Animations.Head.ShootUp,
    [4] = Animations.Head.ShootRight
}
local shootAnimToNormal = {
    [Animations.Head.ShootDown] = Animations.Head.Down,
    [Animations.Head.ShootRight] = Animations.Head.Right,
    [Animations.Head.ShootLeft] = Animations.Head.Left,
    [Animations.Head.ShootUp] = Animations.Head.Up,
}
local projectileVelociryFromDir = {
    [0] = Vector(1, 0),
    [1] = Vector(0, 1),
    [2] = Vector(-1, 0),
    [3] = Vector(0, -1),
    [4] = Vector(1, 0)
}

local function getRandomPitch()
    return 1 + math.random(-20, 20)/100
end

---@param npc EntityNPC
---@return boolean
local function isIsaac(npc)
    return npc.Variant == IsaacEnemy.Variant and npc.SubType == IsaacEnemy.SubType
end

---@param npc EntityNPC
local function hideBodyAndHead(npc)
    local sprite = npc:GetSprite()
    sprite:GetLayer("Head"):SetVisible(false)
    sprite:GetLayer("Body"):SetVisible(false)
end

---@param npc EntityNPC
local function showBodyAndHead(npc)
    local sprite = npc:GetSprite()
    sprite:GetLayer("Head"):SetVisible(true)
    sprite:GetLayer("Body"):SetVisible(true)
end

---@param vel Vector
---@return Vector
local function VectorTo8DirVelocity(vel)
    local newVel
    local angle = vel:GetAngleDegrees() % 360

    if angle > 337.5 or angle <= 22.5 then
        newVel = Vector(1, 0)
    elseif angle > 22.5 and angle <= 67.5 then
        newVel = Vector(1, 1):Normalized()
    elseif angle > 67.5 and angle <= 112.5 then
        newVel = Vector(0, 1)
    elseif angle > 112.5 and angle <= 157.5 then
        newVel = Vector(-1, 1):Normalized()
    elseif angle > 157.5 and angle <= 202.5 then
        newVel = Vector(-1, 0)
    elseif angle > 202.5 and angle <= 247.5 then
        newVel = Vector(-1, -1):Normalized()
    elseif angle > 247.5 and angle <= 292.5 then
        newVel = Vector(0, -1)
    elseif angle > 292.5 and angle <= 337.5 then
        newVel = Vector(1, -1):Normalized()
    end

    return newVel
end

---@param vel Vector
---@return Direction
local function getDirFromVelocity(vel)
    local angle = vel:GetAngleDegrees() % 360

    if angle > 315 or angle <= 45 then
        return Direction.RIGHT
    elseif angle > 45 and angle <= 135 then
        return Direction.DOWN
    elseif angle > 135 and angle <= 225 then
        return Direction.LEFT
    elseif angle > 225 and angle <= 315 then
        return Direction.UP
    end

    return Direction.NO_DIRECTION
end

local function switchEye(npc)
    local data = npc:GetData()
    local eye = data.Resouled_IsaacEnemy.Eye
    if eye == "Left" then
        eye = "Right"
    else
        eye = "Left"
    end
    data.Resouled_IsaacEnemy.ShootCooldown = IsaacEnemy.ShootCooldown
end


---@param npc EntityNPC
local function onNpcInit(_, npc)
    if isIsaac(npc) then
        local sprite = npc:GetSprite()
        local data = npc:GetData()

        data.Resouled_IsaacEnemy = {
            Eye = "Left",
            ShootCooldown = IsaacEnemy.ShootCooldown/3
        }
        
        for i = 0, sprite:GetLayerCount() - 1 do
            sprite:ReplaceSpritesheet(i, SpritesheetPath, true)
        end

        sprite:Play(Animations.Body.Idle, true)
        sprite:PlayOverlay(Animations.Head.Down, true)

        npc:AddEntityFlags(EntityFlag.FLAG_NO_BLOOD_SPLASH)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_INIT, onNpcInit, IsaacEnemy.Type)

---@param npc EntityNPC
local function npcUpdate(_, npc)
    if isIsaac(npc) then
        local room = game:GetRoom()

        local target = npc:GetPlayerTarget()
        local sprite = npc:GetSprite()
        local data = npc:GetData()

        local anim = sprite:GetAnimation()

        local dying = anim == Animations.Extra.Death

        if not dying then
            if data.Resouled_IsaacEnemy.ShootCooldown > 0 then
                data.Resouled_IsaacEnemy.ShootCooldown = data.Resouled_IsaacEnemy.ShootCooldown - 1
                if data.Resouled_IsaacEnemy.ShootCooldown < 0 then
                    data.Resouled_IsaacEnemy.ShootCooldown = 0
                end
            end
            
            ---@type EntityTear | nil
            local tearPresent = nil
            
            ---@param tear EntityTear
            Resouled.Iterators:IterateOverRoomTears(function(tear)
                if room:CheckLine(npc.Position, tear.Position, LineCheckMode.ENTITY) then
                    local velocityAngle = tear.Velocity:GetAngleDegrees() % 360
                    local angle = (npc.Position - tear.Position):GetAngleDegrees() % 360
                    if velocityAngle < angle + 45 and velocityAngle > angle - 45 then
                        if not tearPresent then
                            if tear.Position:Distance(npc.Position) <= IsaacEnemy.ProjectileAvoidanceRange then
                                tearPresent = tear
                            end
                        else
                            if tear.Position:Distance(npc.Position) < tearPresent.Position:Distance(npc.Position) then
                                tearPresent = tear
                            end
                        end
                    end
                end
            end)
            
            local npcToTargetVector = target.Position - npc.Position
            
            if tearPresent then
                npc.Velocity = npc.Velocity + VectorTo8DirVelocity(npc.Position - tearPresent.Position) * 0.85
            else
                if not room:CheckLine(npc.Position, target.Position, LineCheckMode.ENTITY) then
                    npc.Pathfinder:FindGridPath(target.Position, 1, 900, true)
                end
                
                npc.Velocity = (npc.Velocity + VectorTo8DirVelocity(npcToTargetVector)) * 0.85
            end
            
            local shooting = sprite:GetOverlayAnimation():find("Shoot")

            local hit = anim == Animations.Extra.Hit
            
            if not hit then
                if npc.Velocity:LengthSquared() > 0.75 then
                    local dir = getDirFromVelocity(npc.Velocity)
                    if not sprite:IsPlaying(bodyAnimFromDirection[dir]) then
                        sprite:Play(bodyAnimFromDirection[dir], true)
                    end
                    
                    if not shooting then
                        if not sprite:IsOverlayPlaying(headAnimFromDirection[dir]) then
                            sprite:PlayOverlay(headAnimFromDirection[dir], true)
                        end
                    end
                else
                    if not sprite:IsPlaying(Animations.Body.Idle) then
                        sprite:Play(Animations.Body.Idle, true)
                    end
                    
                    if not shooting then
                        if not sprite:IsOverlayPlaying(Animations.Head.Down) then
                            sprite:PlayOverlay(Animations.Head.Down, true)
                        end
                    end
                end
                
                if shooting then
                    local overlayAnim = sprite:GetOverlayAnimation()
                    if sprite:IsOverlayFinished(overlayAnim) then
                        sprite:PlayOverlay(shootAnimToNormal[overlayAnim], true)
                    end
                end

                if data.Resouled_IsaacEnemy.ShootCooldown == 0 then
                    local toTargetAngle = npcToTargetVector:GetAngleDegrees() % 360
                    local shot = false
                    for i = 0, 4 do
                        if not shot and not shooting then
                            local angle = 90 * i
                            if toTargetAngle < angle + IsaacEnemy.ShootField and toTargetAngle > angle - IsaacEnemy.ShootField then
                                shot = true
                                sprite:PlayOverlay(shootAnimFromDir[i], true)
                            
                                local spawnPos = npc.Position
                                spawnPos.X = spawnPos.X + sprite:GetOverlayNullFrame(data.Resouled_IsaacEnemy.Eye.."Eye"):GetPos().X
                            
                                local spawnVel = projectileVelociryFromDir[i] * 10
                                spawnVel = spawnVel + npc.Velocity/2
                            
                                npc:FireProjectiles(spawnPos, spawnVel, 0, ProjectileParams())
                            
                                switchEye(npc)
                            end
                        end
                    end
                end
            else
                if sprite:IsFinished(anim) then
                    sprite:Play(Animations.Body.Idle, true)
                    showBodyAndHead(npc)
                end
            end
        else -- dying
            npc.Velocity = Vector.Zero
            if sprite:IsFinished(anim) then
                npc:Die()
            end
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_NPC_UPDATE, npcUpdate, IsaacEnemy.Type)

---@param npc EntityNPC
---@param amount number
---@param damageFlag DamageFlag
---@param source EntityRef
local function onNpcTakeDamage(_, npc, amount, damageFlag, source)
    if isIsaac(npc) then
        local sprite = npc:GetSprite()

        if npc.HitPoints - amount <= 0 then
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
            npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
            
            
            hideBodyAndHead(npc)

            sprite:Play(Animations.Extra.Death, true)
            
            npc.Velocity = Vector.Zero
            
            sfx:Play(SoundsIsac.Death, nil, nil, nil, getRandomPitch())

            return false
        end

        sfx:Play(SoundsIsac.Hit, nil, nil, nil, getRandomPitch())

        sprite:Play(Animations.Extra.Hit, true)
        hideBodyAndHead(npc)
    end
end
Resouled:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, onNpcTakeDamage, IsaacEnemy.Type)