local g = Game()
local sfx = SFXManager()

-- CONFIG
local CONFIG = {
    -- sound effect that will play whenever the blank canvas spawning attack is done
    SpawnAttackSFX = SoundEffect.SOUND_SUMMON_POOF,
    -- those enemies will have a chance to be spawned when using the blank canvas spawn attack
    SpawnAttackEnemies = {
        Resouled.Enums.Enemies.BLANK_CANVAS_MULLIGAN,
        Resouled.Enums.Enemies.BLANK_CANVAS_GAPER,
        Resouled.Enums.Enemies.BLANK_CANVAS_FLY,
        Resouled.Enums.Enemies.BLANK_CANVAS_POOTER,
        Resouled.Enums.Enemies.BLANK_CANVAS_TEAR,
        Resouled.Enums.Enemies.BLANK_CANVAS_DIP,
    },
    MarkerThrowAttackInitialVelocityLength = 15,
    MarkerThrowAttackInitialVelocityLoss = 0.03,
    MarkerThrowAttackAuraSize = 150,
    MarkerThrowAttackTimeout = 15 * 60, -- *60 because its -1 per frame
}

-- CONSTANTS
local DOODLER_ENTITY = Resouled.Enums.Enemies.DOODLER
local MARKER_ENTITY = Resouled.Enums.Enemies.DOODLER_MARKER
local PLAYER_COSTUME = Isaac.GetCostumeIdByPath("gfx_resouled/characters/doodlification.anm2")

local ANIMATIONS = {
    Idle = "Idle",
    WalkForward = "WalkForward",
    WalkRight = "WalkRight",
    WalkLeft = "WalkLeft",
    RunForward = "RunForward",
    RunRight = "RunRight",
    RunLeft = "RunLeft",
    Death = "Death",
    Erase = "EraseBlankCanvas",
    SpawnAttack = "SpawnBlankCanvas",
    MarkerAttack = "PullOut",
    MarkerIdle = "MARKERONLY"
}

local OVERLAY_ANIMATIONS = {
    HeadDown = "HeadDown",
    HeadDownOpen = "HeadDownOpen",
    HeadDownLifted = "HeadDownLifted",
}

local ANIMATION_EVENTS = {
    MarkerThrow = "MarkerThrow"
}

---@param entity EntityNPC
local function isDoodler(entity)
    return Resouled:MatchesEntityDesc(entity, DOODLER_ENTITY)
end

---@param entity EntityNPC
local function isMarker(entity)
    return Resouled:MatchesEntityDesc(entity, MARKER_ENTITY)
end

-- STATES DEFINITIONS:
-- NpcState.STATE_ATTACK - marker throw attack to spawn the paper aura, always the first action

---@param entity EntityNPC
local function doodlerStateAttackUpdate(_, entity)
    if not (isDoodler(entity) and entity.State == NpcState.STATE_ATTACK) then return end

    local sprite = entity:GetSprite()

    if sprite:IsOverlayPlaying() then
        sprite:RemoveOverlay()
    end

    if not sprite:IsPlaying(ANIMATIONS.MarkerAttack) then
        sprite:Play(ANIMATIONS.MarkerAttack, true)
    end

    local markerCount = Isaac.CountEntities(entity, MARKER_ENTITY.Type, MARKER_ENTITY.Variant, MARKER_ENTITY.SubType)

    --if markerCount > 0 then return end

    if sprite:IsEventTriggered(ANIMATION_EVENTS.MarkerThrow) then
        local target = g:GetNearestPlayer(entity.Position)
        local deg = (target.Position - entity.Position):GetAngleDegrees()
        local initialVelocity = Vector.One:Resized(CONFIG.MarkerThrowAttackInitialVelocityLength):Rotated(deg - 45) -- -45 because idk, just happens

        g:Spawn(
            MARKER_ENTITY.Type,
            MARKER_ENTITY.Variant,
            entity.Position + Vector(-12, -14) * entity.Scale, -- magic number offset to account for where the marker is within the animation
            initialVelocity,
            entity,
            MARKER_ENTITY.SubType,
            Resouled:NewSeed()
        ).Target = target
    end
end

---@param entity EntityNPC
local function markerInit(_, entity)
    if not isMarker(entity) then return end
    entity:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
    entity:GetSprite():Play(ANIMATIONS.MarkerIdle, true)
    entity.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
    entity.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_BULLET
end

---@param entity EntityNPC
local function markerUpdate(_, entity)
    if not isMarker(entity) then return end

    entity:GetSprite().Rotation = entity.Velocity:GetAngleDegrees()
    entity.Velocity:Resize(entity.Velocity:Length() - CONFIG.MarkerThrowAttackInitialVelocityLoss)
end

---@param entity EntityNPC
---@param gridIndex integer
---@param gridEntity? GridEntity
local function markerGridCollision(_, entity, gridIndex, gridEntity)
    if not isMarker(entity) then return end

    Resouled:CreatePaperAura(
        function() return entity.Position end,
        CONFIG.MarkerThrowAttackTimeout,
        CONFIG.MarkerThrowAttackAuraSize
    )

    entity:Remove()
end

---@param entity EntityNPC
local function doodlerInit(_, entity)
    if not isDoodler(entity) then return end

    local sprite = entity:GetSprite()

    -- set head animation and body animation
    sprite:Play(ANIMATIONS.Idle, true)
    sprite:PlayOverlay(OVERLAY_ANIMATIONS.HeadDown, true)

    -- set state as attack1 immediately after spawning to spawn the paper aura
    entity.State = NpcState.STATE_ATTACK
end

---@param entity EntityNPC
local function subscribe(_, entity)
    if not isDoodler(entity) then return end

    print("Subscribe happened")
    Resouled:AddCallback(ModCallbacks.MC_NPC_UPDATE, doodlerStateAttackUpdate, DOODLER_ENTITY.Type)
    Resouled:AddCallback(ModCallbacks.MC_POST_NPC_INIT, doodlerInit, DOODLER_ENTITY.Type)

    Resouled:AddCallback(ModCallbacks.MC_POST_NPC_INIT, markerInit, MARKER_ENTITY.Type)
    Resouled:AddCallback(ModCallbacks.MC_NPC_UPDATE, markerUpdate, MARKER_ENTITY.Type)
    Resouled:AddCallback(ModCallbacks.MC_PRE_NPC_GRID_COLLISION, markerGridCollision, MARKER_ENTITY.Type)
end

local function unsubscribe()
    print("Unsubscribe happened")
    Resouled:RemoveCallback(ModCallbacks.MC_POST_NPC_INIT, doodlerInit)
    Resouled:RemoveCallback(ModCallbacks.MC_NPC_UPDATE, doodlerStateAttackUpdate)

    Resouled:RemoveCallback(ModCallbacks.MC_POST_NPC_INIT, markerInit)
    Resouled:RemoveCallback(ModCallbacks.MC_NPC_UPDATE, markerUpdate)
    Resouled:RemoveCallback(ModCallbacks.MC_PRE_NPC_GRID_COLLISION, markerGridCollision)
end

Resouled:AddCallback(ModCallbacks.MC_POST_NPC_INIT, subscribe, DOODLER_ENTITY.Type)
Resouled:AddCallback(ModCallbacks.MC_PRE_ROOM_EXIT, unsubscribe)


--[[
---@param vel Vector
---@return string
local function getBodyAnimationFromVelocity(vel)
    if vel:Length() < 0.1 then
        return CONST.Anim.Base.Idle.Name
    end

    local angle = vel:GetAngleDegrees() % 360

    if angle < 45 or angle >= 315 then
        return CONST.Anim.Base.WalkRight.Name
    elseif (angle >= 45 and angle < 135) or (angle >= 225 and angle < 315) then
        return CONST.Anim.Base.WalkForward.Name
    elseif angle >= 135 and angle < 225 then
        return CONST.Anim.Base.WalkLeft.Name
    end

    return CONST.Anim.Base.Idle.Name
end

---@param vel Vector
---@return string
local function getRunBodyAnimationFromVelocity(vel)
    if vel:Length() < 0.1 then
        return CONST.Anim.Base.Idle.Name
    end

    local angle = vel:GetAngleDegrees() % 360

    if angle < 45 or angle >= 315 then
        return CONST.Anim.Base.RunRight.Name
    elseif (angle >= 45 and angle < 135) or (angle >= 225 and angle < 315) then
        return CONST.Anim.Base.RunForward.Name
    elseif angle >= 135 and angle < 225 then
        return CONST.Anim.Base.RunLeft.Name
    end

    return CONST.Anim.Base.Idle.Name
end

local function getHeadAnimation()
    return CONST.Anim.Overlay.HeadDown.Name
end

---@param pos Vector
---@return Vector
local function chooseTargetPosInsideAura(pos)
    local auraCenter = Resouled:GetPaperAuraPosition() or pos
    local auraSize = 80 -- random value that looked good
    local targetPos = auraCenter + Vector(math.random(-auraSize, auraSize), math.random(-auraSize, auraSize))
    return Isaac.GetFreeNearPosition(targetPos, 67)
end

---@param pos Vector
---@return Vector
local function chooseTargetPos(pos)
    local auraVisible = Resouled:IsPaperAuraVisible()
    local distance = math.random(CONST.MinWalkDistance, CONST.MaxWalkDistance) *
        (auraVisible and CONFIG.AuraWalkDistanceMultiplier or 1)
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
    ::FindNormalDirection::
    for i = 0, 3 do
        if not blockedDirections[i] then
            if auraVisible then
                local direction = math.floor(((center - pos):Rotated(-90 * i + 180):GetAngleDegrees() % 360) / 90 + 0.5) -
                    1
                local checkedDirections = 0

                ::RollAgain::
                if not blockedDirections[direction] then
                    checkedDirections = checkedDirections + 1
                    direction = (direction) % 3 + 1

                    if checkedDirections < 4 then
                        goto RollAgain
                    else
                        auraVisible = false
                        goto FindNormalDirection
                    end
                end

                table.insert(validDirections, direction)
            else
                local addChance = false
                if i == 0 and pos.X > center.X then
                    addChance = true
                elseif i == 1 and pos.Y > center.Y then
                    addChance = true
                elseif i == 2 and pos.X < center.X then
                    addChance = true
                elseif i == 3 and pos.Y < center.Y then
                    addChance = true
                end

                table.insert(validDirections, i)
                if addChance == true then for _ = 1, 2 - i % 2 do table.insert(validDirections, i) end end
            end
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

local prevState = nil

---@param doodler EntityNPC
local function onDoodlerUpdate(_, doodler)
    if not Resouled:MatchesEntityDesc(doodler, CONST.Ent) then return end

    local playerTarget = doodler:GetPlayerTarget()
    local sprite = doodler:GetSprite()
    local room = game:GetRoom()
    local data = doodler:GetData().Resouled_Doodler
    local auraVisible = Resouled:IsPaperAuraVisible()

    doodler.Velocity = doodler.Velocity * 0.9

    if prevState ~= doodler.State then
        prevState = doodler.State
        print(prevState)
    end

    if doodler.State == NpcState.STATE_MOVE then
        if not auraVisible then
            data.AuraEnterTime = nil
        end

        if data.TargetPos and not doodler.Pathfinder:HasPathToPos(data.TargetPos, false) then data.TargetPos = nil end

        -- prio pathfing inside aura if possible
        if auraVisible and not Resouled:IsPosInsidePaperAura(doodler.Position) then
            local bodyAnim = getRunBodyAnimationFromVelocity(doodler.Velocity)
            local headAnim = getHeadAnimation()

            if sprite:GetAnimation() ~= bodyAnim then
                sprite:Play(bodyAnim, true)
            end

            if sprite:GetOverlayAnimation() ~= headAnim then
                sprite:PlayOverlay(headAnim, true)
            end

            doodler.Pathfinder:FindGridPath(Resouled:GetPaperAuraPosition() or Vector.Zero, 1.1, 0, false)

            if data.TargetPos then data.TargetPos = nil end
            --
        elseif not auraVisible or Resouled:IsPosInsidePaperAura(doodler.Position) then
            local bodyAnim = getBodyAnimationFromVelocity(doodler.Velocity)
            local headAnim = getHeadAnimation()

            if sprite:GetAnimation() ~= bodyAnim then
                sprite:Play(bodyAnim, true)
            end

            if sprite:GetOverlayAnimation() ~= headAnim then
                sprite:PlayOverlay(headAnim, true)
            end

            -- track time spent in aura
            if auraVisible and Resouled:IsPosInsidePaperAura(doodler.Position) then
                if not data.AuraEnterTime then
                    data.AuraEnterTime = 0
                end
                data.AuraEnterTime = data.AuraEnterTime + 1
            else
                data.AuraEnterTime = nil
            end

            -- pick new target pos if enough time has passed
            if not data.TargetPos then
                if not (auraVisible and data.AuraEnterTime and data.AuraEnterTime < CONFIG.AuraStayDuration) then
                    if auraVisible and Resouled:IsPosInsidePaperAura(doodler.Position) then
                        data.TargetPos = chooseTargetPosInsideAura(doodler.Position)
                    else
                        data.TargetPos = chooseTargetPos(doodler.Position)
                    end
                end
            end

            if data.TargetPos then
                doodler.Pathfinder:FindGridPath(data.TargetPos, 0.75, 0, false)

                if doodler.Position:Distance(data.TargetPos) < 50 then
                    data.TargetPos = nil
                    if math.random() < CONST.ChanceToAttackWhenNearTargetPos then
                        local attack = nil
                        if auraVisible then -- choose random next attack when aura present
                            attack = math.random(#CONFIG.Attacks)
                        else                -- choose marker attack when aura is not visible
                            attack = 2
                        end

                        if attack and CONFIG.AttackChecks[attack](doodler) then
                            doodler.State = CONFIG.Attacks[attack]
                        end
                    end
                end
            end
        end
    elseif doodler.State == NpcState.STATE_ATTACK then
        if sprite:IsFinished(CONST.Anim.SpawnBlankCanvas) then
            sprite:Play(CONST.Anim.Base.Idle.Name, true)
            sprite:PlayOverlay(CONST.Anim.Overlay.HeadDown.Name, true)
            doodler.State = NpcState.STATE_MOVE
            return
        end

        if not sprite:IsPlaying(CONST.Anim.SpawnBlankCanvas) then
            sprite:Play(CONST.Anim.SpawnBlankCanvas, true)
            sprite:RemoveOverlay()
        end

        if sprite:IsEventTriggered("SpawnBlankCanvas") then
            local ids = getRandomPaperEnemy()
            if game:Spawn(
                    ids.Id,
                    ids.Var,
                    doodler.Position +
                    Vector(math.random(CONST.MinPaperEnemySpawnRadius, CONST.MaxPaperEnemySpawnRadius), 0):Rotated(180 *
                        math.random()),
                    Vector.Zero,
                    doodler,
                    ids.Sub,
                    Random()
                ) then
                sfx:Play(CONFIG.BlankCanvasSpawnSFX)
            end
        end
    elseif doodler.State == NpcState.STATE_ATTACK2 then
        local attackAnim = CONST.Anim.MarkerAttack

        if sprite:IsFinished(attackAnim) then
            doodler.State = NpcState.STATE_MOVE
        end

        if not sprite:IsPlaying(attackAnim) then
            sprite:RemoveOverlay()
            sprite:Play(attackAnim, true)
        end

        if sprite:IsEventTriggered("MarkerThrow") then
            game:Spawn(
                CONST.Marker.Type,
                CONST.Marker.Variant,
                doodler.Position,
                (doodler.Position - doodler:GetPlayerTarget().Position):Normalized() * 2,
                doodler,
                CONST.Marker.SubType,
                Resouled:NewSeed()
            )
        end


        doodler.Velocity = doodler.Velocity * 0.9
    elseif doodler.State == NpcState.STATE_ATTACK3 then -- walk to the aura and start erasing grids
        -- remove head overlay animation since erase animation has it already included
        if sprite:IsOverlayPlaying() then
            sprite:RemoveOverlay()
        end

        local triggerNow = sprite:IsFinished(CONST.Anim.Erase)

        -- play erase animation if its not played
        if not sprite:IsPlaying(CONST.Anim.Erase) then
            sprite:Play(CONST.Anim.Erase, true)
        end

        local candidates = {}

        if not triggerNow then goto return_griderase end

        Resouled.Iterators:IterateOverGridEntities(function(gridEntity, index)
            if Resouled:IsPosInsidePaperAura(gridEntity.Position) and gridEntity.State ~= 2 then
                table.insert(candidates, gridEntity)
            end
        end)

        if #candidates == 0 then
            doodler.State = NpcState.STATE_MOVE
            sprite:Play(CONST.Anim.Base.Idle.Name)
            sprite:PlayOverlay(CONST.Anim.Overlay.HeadDown.Name)
        else
            ---@type GridEntity
            local chosenGrid = candidates[math.random(#candidates)]

            chosenGrid:Destroy()
            print("DESTROY")
        end

        ::return_griderase::
    elseif doodler.State == NpcState.STATE_SUICIDE then
        if not sprite:IsPlaying(CONST.Anim.Death) then sprite:Play(CONST.Anim.Death) end
        sprite:RemoveOverlay()

        if sprite:IsEventTriggered("Explosion") then
            game:BombExplosionEffects(doodler.Position + Vector(0, 1), 0, nil, nil, nil, 1.35, false, nil,
                DamageFlag.DAMAGE_FAKE)
        end

        if sprite:IsFinished(CONST.Anim.Death) then
            Resouled:SpawnPaperGore(doodler.Position, 20, 2)
            Resouled:SpawnPaperGore(doodler.Position, 40, 1.5)
            Resouled:SpawnPaperGore(doodler.Position, 40, 1)

            game:Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, doodler.Position, Vector.Zero, nil,
                Resouled.Enums.Items.PROTOTYPE_DUMMY, Resouled:NewSeed())

            doodler:Kill()
        end

        doodler.Velocity = doodler.Velocity * 0.9
    elseif doodler.State == NpcState.STATE_SPECIAL then
        if sprite:IsEventTriggered("Erase") and not data.EraseCooldown then
            for _, en in ipairs(Isaac.FindInRadius(doodler.Position, CONST.TearEraseArea, EntityPartition.TEAR)) do
                en:Remove()
                data.EraseCooldown = CONFIG.EraseCooldown
            end
        end

        if sprite:IsFinished(CONST.Anim.Erase) then
            sprite:Play(CONST.Anim.Base.Idle.Name, true)
            sprite:PlayOverlay(CONST.Anim.Overlay.HeadDown.Name, true)
            doodler.State = NpcState.STATE_MOVE
        end

        doodler.Velocity = doodler.Velocity * 0.9
    end

    if data.EraseCooldown then
        data.EraseCooldown = data.EraseCooldown - 1
        if data.EraseCooldown < 1 then
            data.EraseCooldown = nil
        end
    elseif not data.EraseCooldown and doodler.State ~= NpcState.STATE_SPECIAL then
        if Resouled:IsPaperAuraVisible() then
            local tears = Isaac.FindInRadius(doodler.Position, CONST.TearEraseArea, EntityPartition.TEAR)

            for _, en in ipairs(tears) do
                if Resouled:IsPosInsidePaperAura(en.Position) then
                    doodler.State = NpcState.STATE_SPECIAL
                    sprite:Play(CONST.Anim.Erase, true)
                    sprite:RemoveOverlay()
                    break
                end
            end
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_NPC_UPDATE, onDoodlerUpdate, CONST.Ent.Type)

-- add doodlification if inside paper aura
local function postPlayerUpdate(_, player)
    if not player:IsNullItemCostumeVisible(CONST.Costume, PlayerSpriteLayer.SPRITE_HEAD5) and Resouled:IsPosInsidePaperAura(player.Position) then
        player:AddNullCostume(CONST.Costume)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, postPlayerUpdate)

-- remove doodlification upon room leave
local function onRoomLeave()
    Resouled.Iterators:IterateOverPlayers(function(player)
        player:TryRemoveNullCostume(CONST.Costume)
    end)
end
Resouled:AddCallback(ModCallbacks.MC_PRE_NEW_ROOM, onRoomLeave)

---@param en Entity
---@param am number
local function preNpcTakeDMG(_, en, am)
    if not Resouled:MatchesEntityDesc(en, CONST.Ent) then return end
    local npc = en:ToNPC()
    if not npc then return end
    if npc.State == NpcState.STATE_SUICIDE then return false end -- STATE_SUICIDE because STATE_DEATH and STATE_DEATH_UNIQUE stopped npc updates
    if am > npc.HitPoints then
        npc.State = NpcState.STATE_SUICIDE
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        Resouled:HidePaperAura()
        return false
    end
end
Resouled:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, preNpcTakeDMG, CONST.Ent.Type)

--- MARKER INIT
---@param npc EntityNPC
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_INIT, function(_, npc)
    if not Resouled:MatchesEntityDesc(npc, CONST.Marker) then return end
    npc:GetSprite():Play(CONST.Anim.MarkerOnly, true)
    npc.Target = npc:GetPlayerTarget()
    npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
end, CONST.Marker.Type)

--- MARKER UPDATE
---@param npc EntityNPC
Resouled:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, npc)
    if not Resouled:MatchesEntityDesc(npc, CONST.Marker) then return end
    local velLen = npc.Velocity:Length()
    npc.Velocity = (npc.Target.Position - npc.Position):Resized(math.min((velLen + 0.01) * 1.3,
        CONFIG.MarkerMaxSpeedVectorLength))
    npc:GetSprite().Rotation = npc.Velocity:GetAngleDegrees() + 90
end, CONST.Marker.Type)

---@param npc EntityNPC
---@param collider Entity
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_COLLISION, function(_, npc, collider)
    if not Resouled:MatchesEntityDesc(npc, CONST.Marker) then return end
    if collider:ToPlayer() then
        npc:Kill()
    end
end, CONST.Marker.Type)

--- MARKER DEATH
---@param npc EntityNPC
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, function(_, npc)
    if not Resouled:MatchesEntityDesc(npc, CONST.Marker) then return end

    local auraConfig = getRandomAuraConfig()

    Resouled:CreatePaperAura(function()
        return npc.Position
    end, auraConfig.Timeout, auraConfig.Size)
end, CONST.Marker.Type)

local function hideAura()
    Resouled:HidePaperAura(false)
end

Resouled:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, hideAura)
Resouled:AddCallback(ModCallbacks.MC_PRE_NEW_ROOM, hideAura)

--]]
