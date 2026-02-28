local game = Game()

local paperEnemies = {}
local paperEnemiesStringLookup = {}
---@param id integer
---@param var integer
---@param sub integer
function Resouled:RegisterPaperEnemy(id, var, sub)
    table.insert(paperEnemies,
        {
            Id = id,
            Var = var,
            Sub = sub
        }
    )
    paperEnemiesStringLookup[id .. "." .. var .. "." .. sub] = true
end

---@return table
local function getRandomPaperEnemy()
    return paperEnemies[math.random(#paperEnemies)]
end

local CONST = {
    Ent = Resouled:GetEntityByName("Resouled Doodler"),
    Marker = Resouled:GetEntityByName("Resouled Doodler Marker"),
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
        Death = "Death",
        Erase = "EraseBlankCanvas",
        SpawnBlankCanvas = "SpawnBlankCanvas",
        MarkerAttack = "PullOut",
        MarkerOnly = "MARKERONLY"
    },

    MinWalkDistance = 250,
    MaxWalkDistance = 750,
    DistanceFromWallsToBlockWalkDir = 150,
    ChanceToAttackWhenNearTargetPos = 1 / 1,
    MinPaperEnemySpawnRadius = 20,
    MaxPaperEnemySpawnRadius = 100,
    TearEraseArea = 50,
    MaxSimultaneousPaperEnemies = 3,
}

local CONFIG = {
    MarkerMaxSpeedVectorLength = 6.5,

    AuraSizes = {
        Small = 60,
        Medium = 80,
        Big = 100
    },
    AuraTimeouts = {
        Short = 200,
        Medium = 350,
        Long = 500
    },

    EraseCooldown = 15,
    AuraWalkDistanceMultiplier = 0.25,

    Attacks = {
        [1] = NpcState.STATE_ATTACK, --Spawn Blank Canvas
        [2] = NpcState.STATE_ATTACK2 --Magic Marker
    },

    AttackChecks = {
        [1] = function()
            local paperEnemyCount = 0
            ---@param npc EntityNPC
            Resouled.Iterators:IterateOverRoomNpcs(function(npc)
                if paperEnemiesStringLookup[npc.Type .. "." .. npc.Variant .. "." .. npc.SubType] then
                    paperEnemyCount = paperEnemyCount + 1
                end
            end)
            return paperEnemyCount <= CONST.MaxSimultaneousPaperEnemies
        end,
        [2] = function()
            if Resouled:IsPaperAuraVisible() then return false end
            
            ---@param npc EntityNPC
            Resouled.Iterators:IterateOverRoomNpcs(function(npc)
                if Resouled:MatchesEntityDesc(npc, CONST.Marker) then
                    ---@diagnostic disable-next-line
                    return false
                end
            end)

            return true
        end
    }
}

---@return table
local function getRandomAuraConfig()
    local auraSizes = {}
    for _, size in pairs(CONFIG.AuraSizes) do
        table.insert(auraSizes, size)
    end

    local auraTimeouts = {}
    for _, timeout in pairs(CONFIG.AuraTimeouts) do
        table.insert(auraTimeouts, timeout)
    end

    return {
        Size = auraSizes[math.random(#auraSizes)],
        Timeout = auraTimeouts[math.random(#auraTimeouts)]
    }
end

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
local function chooseTargetPos(pos)
    local auraVisible = Resouled:IsPaperAuraVisible()
    local distance = math.random(CONST.MinWalkDistance, CONST.MaxWalkDistance) * (auraVisible and CONFIG.AuraWalkDistanceMultiplier or 1)
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
                local direction = math.floor(((center - pos):Rotated(-90 * i + 180):GetAngleDegrees()%360)/90 + 0.5) - 1
                local checkedDirections = 0
                
                ::RollAgain::
                if not blockedDirections[direction] then
                    checkedDirections = checkedDirections + 1
                    direction = (direction)%3 + 1

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

---@param doodler EntityNPC
local function onDoodlerUpdate(_, doodler)
    if not Resouled:MatchesEntityDesc(doodler, CONST.Ent) then return end

    local playerTarget = doodler:GetPlayerTarget()
    local sprite = doodler:GetSprite()
    local room = game:GetRoom()
    local data = doodler:GetData().Resouled_Doodler
    local auraVisible = Resouled:IsPaperAuraVisible()

    doodler.Velocity = doodler.Velocity * 0.9

    if doodler.State == NpcState.STATE_MOVE then
        if data.TargetPos and not doodler.Pathfinder:HasPathToPos(data.TargetPos, false) then data.TargetPos = nil end
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

        elseif not auraVisible or Resouled:IsPosInsidePaperAura(doodler.Position) then
            local bodyAnim = getBodyAnimationFromVelocity(doodler.Velocity)
            local headAnim = getHeadAnimation()
            if sprite:GetAnimation() ~= bodyAnim then
                sprite:Play(bodyAnim, true)
            end
            
            if sprite:GetOverlayAnimation() ~= headAnim then
                sprite:PlayOverlay(headAnim, true)
            end
            
            if not data.TargetPos then data.TargetPos = chooseTargetPos(doodler.Position) end
            
            doodler.Pathfinder:FindGridPath(data.TargetPos, 0.75, 0, false)
            
            if doodler.Position:Distance(data.TargetPos) < 50 then
                data.TargetPos = nil
                
                if math.random() < CONST.ChanceToAttackWhenNearTargetPos then
                    local attack = math.random(#CONFIG.Attacks)
                    if CONFIG.AttackChecks[attack]() == true then
                        doodler.State = CONFIG.Attacks[attack]
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
            game:Spawn(
                ids.Id,
                ids.Var,
                doodler.Position +
                Vector(math.random(CONST.MinPaperEnemySpawnRadius, CONST.MaxPaperEnemySpawnRadius), 0):Rotated(180 *
                    math.random()),
                Vector.Zero,
                doodler,
                ids.Sub,
                Random()
            )
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

            game:Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, doodler.Position, Vector.Zero, nil, Resouled.Enums.Items.PROTOTYPE_DUMMY, Random())

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

Resouled:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function()
    Resouled:HidePaperAura(false)
end)