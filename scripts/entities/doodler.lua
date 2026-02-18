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
    paperEnemiesStringLookup[id.."."..var.."."..sub] = true
end

---@return table
local function getRandomPaperEnemy()
    return paperEnemies[math.random(#paperEnemies)]
end

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
        Death = "Death",
        Erase = "EraseBlankCanvas",
        SpawnBlankCanvas = "SpawnBlankCanvas"
    },

    MinWalkDistance = 250,
    MaxWalkDistance = 750,
    DistanceFromWallsToBlockWalkDir = 150,
    ChanceToAttackWhenNearTargetPos = 1/1,
    MinPaperEnemySpawnRadius = 20,
    MaxPaperEnemySpawnRadius = 100,
    TearEraseArea = 50,

    Attacks = {
        [1] = NpcState.STATE_ATTACK, --Spawn Blank Canvas
        [2] = NpcState.STATE_ATTACK2 --Magic Marker (placeholder only aura rn)
    },

    AttackChecks = {
        [1] = function()
            local paperEnemyPresent = false
            ---@param npc EntityNPC
            Resouled.Iterators:IterateOverRoomNpcs(function(npc)
                if not paperEnemyPresent and paperEnemiesStringLookup[npc.Type.."."..npc.Variant.."."..npc.SubType] then
                    paperEnemyPresent = true
                end
            end)
            return not paperEnemyPresent
        end,
        [2] = function()
            return true
        end
    }
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

            if math.random() < CONST.ChanceToAttackWhenNearTargetPos then
                local attack = math.random(#CONST.Attacks)
                if CONST.AttackChecks[attack]() == true then
                    doodler.State = CONST.Attacks[attack]
                end
            end
        end
    elseif doodler.State == NpcState.STATE_ATTACK then

        if not sprite:IsPlaying(CONST.Anim.SpawnBlankCanvas) and doodler.I1 == 0 then
            sprite:Play(CONST.Anim.SpawnBlankCanvas, true)
            sprite:RemoveOverlay()
            doodler.I1 = 1
        end

        if sprite:IsEventTriggered("SpawnBlankCanvas") then
            local ids = getRandomPaperEnemy()
            game:Spawn(
                ids.Id,
                ids.Var,
                doodler.Position + Vector(math.random(CONST.MinPaperEnemySpawnRadius, CONST.MaxPaperEnemySpawnRadius), 0):Rotated(180 * math.random()),
                Vector.Zero,
                doodler,
                ids.Sub,
                Random()
            )
        end

        if sprite:IsFinished(CONST.Anim.SpawnBlankCanvas) then
            sprite:Play(CONST.Anim.Base.Idle.Name, true)
            sprite:PlayOverlay(CONST.Anim.Overlay.HeadDown.Name, true)
            doodler.State = NpcState.STATE_MOVE
            doodler.I1 = 0
        end
    elseif doodler.State == NpcState.STATE_ATTACK2 then

        local topLeft = room:GetTopLeftPos()

        Resouled:CreatePaperAura(
            topLeft + (room:GetBottomRightPos() - topLeft) * math.random()
        )

        doodler.State = NpcState.STATE_MOVE

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

    if Resouled:IsPaperAuraVisible() then
        
        local tears = Isaac.FindInRadius(doodler.Position, CONST.TearEraseArea, EntityPartition.TEAR)

        for _, en in ipairs(tears) do
            
            local tear = en:ToTear()
            if tear and Resouled:IsPosInsidePaperAura(tear.Position) then
               
                tear:Kill()

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
    if am > npc.HitPoints then npc.State = NpcState.STATE_SUICIDE npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE Resouled:HidePaperAura() return false end
end
Resouled:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, preNpcTakeDMG, CONST.Ent.Type)
