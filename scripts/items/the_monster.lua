local ITEM = Resouled.Enums.Items.THE_MONSTER

local Monster = {
    Sprite = Resouled:CreateLoadedSprite("gfx_resouled/the_monster.anm2"),
    HeadDirToAnimTranslation = { [Direction.LEFT] = "Left", [Direction.UP] = "Up", [Direction.RIGHT] = "Right", [Direction.DOWN] = "Down" },
    OffsetPerMonster = 13,
    AlphaWhenItemPickup = 0.16,
    AlphaToSubtractPerMonster = 0, --Make dss option
    MaxMonsters = nil,             --Make dss option
    WobbleEnabled = true,
}

local Chargebar = {
    Sprite = Resouled:CreateLoadedSprite("gfx/chargebar.anm2", nil, { [0] = "gfx_resouled/ui/monster_chargebar.png" }),
    Offset = Vector(-30, -45),
    ChargeBase = 65,              -- updates
    ChargeReductionPerCopy = 0.2, -- x copies will result in (1-reduction) ^ (x-1) * base
    Animations = {
        Charging = {
            Length = 101,
            Name = "Charging",
            Loop = false,
        },
        Charged = {
            Length = 6,
            Name = "Charged",
            Loop = true,
        },
        StartCharged = {
            Length = 12,
            Name = "StartCharged",
            Loop = false,
        },
        Disappear = {
            Length = 9,
            Name = "Disappear",
            Loop = false,
        },
    },
}

local Tongue = {
    Sprite = Resouled:CreateLoadedSprite("gfx_resouled/effects/monster_tongue.anm2", "Idle"),
    PointLength = 8,
    PointCount = 128/8, -- sprite is 128x16 so 128 / 8 because each segment is 8 long
    PlayerHeadOffset = Vector(0, -50),
    Range = 200,
    GrabRadius = 15,
    EnemyCheckFrequency = 3
}
Tongue.Beam = Beam(Tongue.Sprite, 0, false, false)

---@param player EntityPlayer
local function monstersRender(_, player)
    local itemCount = player:GetCollectibleNum(ITEM)
    if itemCount <= 0 or not player:IsVisible() then return end

    local data = player:GetData()
    data.RESOULED__MONSTER_MOUTH_POS = {}

    local playerSprite = player:GetSprite()
    local headLayer = playerSprite:GetLayer("head")

    if not headLayer then return end

    -- setting correct rotation
    local targetAnim = Monster.HeadDirToAnimTranslation[player:GetHeadDirection()]
    if not Monster.Sprite:IsPlaying(targetAnim) then
        Monster.Sprite:Play(targetAnim, true)
    end

    -- setting correct size
    Monster.Sprite.Scale = player.SpriteScale * headLayer:GetSize()

    Monster.Sprite.Offset = Vector(0, 0)
    Monster.Sprite.Color.A = 1

    --Make picked up things visible through monsters
    local playerAnimation = playerSprite:GetAnimation()
    local makeSeeThrough = playerAnimation:find("Item") or playerAnimation:find("Pickup")

    local tiltMax = -player.Velocity

    -- rendering monsters
    for i = 0, itemCount - 1 do
        if makeSeeThrough then
            Monster.Sprite.Color.A = math.min(1, Monster.AlphaWhenItemPickup * i)
        end

        local pos = player.Position + player.SpriteOffset + player.PositionOffset + headLayer:GetPos() + player:GetFlyingOffset()

        -- adapt to player shooting
        if playerSprite:GetOverlayAnimation():find("Head") and playerSprite:GetOverlayFrame() > 0 then
            pos = pos + Vector(0, 2)
        end
        Monster.Sprite:Render(Isaac.WorldToScreen(pos))
        table.insert(data.RESOULED__MONSTER_MOUTH_POS, pos)

        --Make the stack less and less visible
        Monster.Sprite.Color.A = Monster.Sprite.Color.A - Monster.AlphaToSubtractPerMonster
        Monster.Sprite.Offset.Y = Monster.Sprite.Offset.Y - Monster.OffsetPerMonster * Monster.Sprite.Scale.Y

        if Monster.WobbleEnabled then
            local itersProgression = (i + 1) / itemCount
            Monster.Sprite.Offset.X = Monster.Sprite.Offset.X + tiltMax.X * itersProgression
            Monster.Sprite.Offset.Y = Monster.Sprite.Offset.Y + tiltMax.Y * itersProgression
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, monstersRender)

---@param player EntityPlayer
local function chargebarRender(_, player)
    local data = player:GetData()

    local currentAnimation = Chargebar.Sprite:GetAnimation()

    if data.RESOULED__MONSTER_CHARGEBAR then
        if currentAnimation == Chargebar.Animations.Disappear.Name then
            Chargebar.Sprite:Play(Chargebar.Animations.Charging.Name, true)
        elseif currentAnimation == Chargebar.Animations.Charging.Name then
            local percentageCharged = 1 -
                data.RESOULED__MONSTER_CHARGEBAR.Remaining / data.RESOULED__MONSTER_CHARGEBAR.Total
            local targetFrame = math.floor(percentageCharged * (Chargebar.Animations.Charging.Length))

            if targetFrame == Chargebar.Animations.Charging.Length then
                Chargebar.Sprite:Play(Chargebar.Animations.StartCharged.Name, true)
            else
                Chargebar.Sprite:SetFrame(Chargebar.Animations.Charging.Name, targetFrame)
            end
        elseif currentAnimation == Chargebar.Animations.StartCharged.Name and Chargebar.Sprite:GetFrame() == Chargebar.Animations.StartCharged.Length - 1 then
            Chargebar.Sprite:Play(Chargebar.Animations.Charged.Name, true)
        end
    elseif currentAnimation ~= Chargebar.Animations.Disappear.Name then
        Chargebar.Sprite:SetAnimation(Chargebar.Animations.Disappear.Name)
    end

    local currentAnimation = Chargebar.Sprite:GetAnimation()

    if currentAnimation ~= Chargebar.Animations.Charging.Name then
        local animLength = 0
        local loop = false
        for _, anim in pairs(Chargebar.Animations) do
            if anim.Name == currentAnimation then
                animLength = anim.Length
                loop = anim.Loop
                break
            end
        end

        if animLength > 0 then
            if (currentAnimation == Chargebar.Animations.StartCharged.Name or currentAnimation == Chargebar.Animations.Charged.Name)
                and Game():GetFrameCount() % 2 ~= 0 then -- slow down 2 times because it's too fast otherwise
                goto dont_increment_frame
            end

            if loop then
                Chargebar.Sprite:SetFrame(currentAnimation, (Chargebar.Sprite:GetFrame() + 1) % animLength)
            else
                Chargebar.Sprite:SetFrame(currentAnimation, math.min(Chargebar.Sprite:GetFrame() + 1, animLength - 1))
            end
        end
    end

    ::dont_increment_frame::

    if not (currentAnimation == Chargebar.Animations.Disappear.Name and Chargebar.Sprite:GetFrame() == Chargebar.Animations.Disappear.Length) then
        Chargebar.Sprite:Render(Isaac.WorldToScreen(player.Position + Chargebar.Offset * player.SpriteScale))
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, chargebarRender)

---@param player EntityPlayer
local function chargebarPlayerUpdate(_, player)
    local itemCount = player:GetCollectibleNum(ITEM)

    if itemCount == 0 then return end

    local data = player:GetData()
    local playerAnimation = player:GetSprite():GetAnimation()

    -- shoot or reset on release
    if not Resouled:IsPlayerShooting(player) or playerAnimation:find("Item") or playerAnimation:find("Pickup") then
        if data.RESOULED__MONSTER_CHARGEBAR and data.RESOULED__MONSTER_CHARGEBAR.Remaining == 0 then
            -- shoot here
            local dir = player:GetLastDirection()
            data.RESOULED__MONSTER_TONGUE = {
                TargetPosition = (dir + player:GetTearMovementInheritance(dir)/10):Normalized() * Tongue.Range + player.Position + Tongue.PlayerHeadOffset/2 * player.SpriteScale.Y,
                Points = {},
                VelocityMult = 1,
            }
            data.RESOULED__MONSTER_TONGUE.TargetAngle = data.RESOULED__MONSTER_TONGUE.TargetPosition:GetAngleDegrees()
        end
        data.RESOULED__MONSTER_CHARGEBAR = nil
        return
    end

    -- count down charge if player is shooting
    if data.RESOULED__MONSTER_CHARGEBAR then
        data.RESOULED__MONSTER_CHARGEBAR.Remaining = math.max(data.RESOULED__MONSTER_CHARGEBAR.Remaining - 1, 0)
    else -- create charge based on how many copies of the item player has
        local cd = Chargebar.ChargeBase * (1 - Chargebar.ChargeReductionPerCopy) ^ (itemCount - 1)
        data.RESOULED__MONSTER_CHARGEBAR = {
            Remaining = cd,
            Total = cd
        }
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_PLAYER_UPDATE, chargebarPlayerUpdate)


-----------------------------------------------------------------------------------------
---@param player EntityPlayer
local function newTongueRender(_, player)
    local data = player:GetData().RESOULED__MONSTER_TONGUE
    if not data then return end
    
    local initPos = player.Position +
    Tongue.PlayerHeadOffset * player.SpriteScale.Y
    local endPos = data.TargetPosition
    
    if #data.Points == 0 then
        for _ = 1, Tongue.PointCount do
            table.insert(data.Points, {
                Pos = initPos,
                Vel = Vector.Zero
            })
        end
        data.Points[#data.Points].Vel = (data.TargetPosition - initPos):Normalized() * 30
    end
    if not Game():IsPaused() then
        
        data.Points[1].Pos = initPos

        if data.GrabbedEnemy then
            local enemy = data.GrabbedEnemy.Entity
            if enemy:IsDead() or not enemy:IsActiveEnemy(false) or enemy.HitPoints <= 0 then
                data.GrabbedEnemy = nil
            end
        end
        
        if Isaac.GetFrameCount()%Tongue.EnemyCheckFrequency == 0 and not data.GrabbedEnemy then
            for _, entity in ipairs(Isaac.FindInRadius(data.Points[Tongue.PointCount].Pos, Tongue.GrabRadius, EntityPartition.ENEMY)) do
                local npc = entity:ToNPC()
                if npc and Resouled:IsValidEnemy(npc) then
                    data.GrabbedEnemy = EntityRef(npc)
                    for i = 2, #data.Points do
                        local p = data.Points[i]
                        p.Vel = p.Vel + (initPos - p.Pos):Normalized() * 5
                    end
                        
                    if data.VelocityMult > 0 then
                        data.VelocityMult = -data.VelocityMult
                    end
                    break
                end
            end
        end
    
        if (initPos:Distance(endPos) < data.Points[Tongue.PointCount].Pos:Distance(initPos)) and data.VelocityMult > 0 then --Crossed max distance
            data.VelocityMult = -data.VelocityMult
        
            for i = 2, #data.Points do
                local p = data.Points[i]
                p.Vel = p.Vel + (initPos - p.Pos):Normalized() * 5
            end
        end
    
        local segmentLength = Tongue.Range / (Tongue.PointCount - 1)
        
        if data.VelocityMult > 0 then --Extend
            for i = 0, #data.Points - 2 do
                local p1 = data.Points[#data.Points - i]
                local p2 = data.Points[#data.Points - (i + 1)]

                p1.Vel = p1.Vel + (data.TargetPosition - p1.Pos):Normalized()
                if p1.Pos:Distance(p2.Pos) > segmentLength then
                    p2.Vel = p2.Vel + (p1.Pos - p2.Pos):Normalized()
                end
                
                p1.Pos = p1.Pos + p1.Vel
                p1.Vel = p1.Vel * 0.95
            end

            for i = 1, #data.Points - 1 do
                local p1 = data.Points[i]
                local p2 = data.Points[i+1]
    
                local delta = p2.Pos - p1.Pos
                local distance = delta:Length()/2

                if distance > segmentLength then
                    p2.Pos = p2.Pos - delta * (distance - segmentLength) / distance * 0.05
                end
            end
        else --Retract
            for i = 1, #data.Points do
                local p1 = data.Points[i]
                local p2 = data.Points[i + 1]

                if p2 then
                    if p2.Pos:Distance(initPos) > 0 then
                        p2.Vel = p2.Vel + (initPos - p2.Pos):Normalized()
                    end
                end
                p1.Pos = p1.Pos + p1.Vel
                p1.Vel = p1.Vel * 0.95
            end
        
            for i = 1, #data.Points - 1 do
                local p1 = data.Points[i]
                local p2 = data.Points[i+1]
    
                local delta = p2.Pos - p1.Pos
                local distance = delta:Length()
    
                if distance > segmentLength then
                    p2.Pos = p2.Pos - delta * (distance - segmentLength) / distance * 0.25
                end
            end
        end

        if data.GrabbedEnemy then
            data.GrabbedEnemy.Entity.Position = data.Points[Tongue.PointCount].Pos
        end
    end

    for i = 1, #data.Points - 1 do
        local p1 = data.Points[i]
        local p2 = data.Points[i + 1]

        Tongue.Beam:Add(Isaac.WorldToScreen(p1.Pos), Tongue.PointLength * (i - 1))
        Tongue.Beam:Add(Isaac.WorldToScreen(p2.Pos), Tongue.PointLength * i)
    end
    Tongue.Beam:Render(true)

    if (data.Points[Tongue.PointCount].Pos:Distance(initPos) < Tongue.GrabRadius + 10 and data.VelocityMult < 0) then
        player:GetData().RESOULED__MONSTER_TONGUE = nil
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, newTongueRender)

---@param player EntityPlayer
local function tongueRender(_, player)
    local data = player:GetData().RESOULED__MONSTER_TONGUE
    if not data then return end

    local targetPos = Isaac.WorldToScreen(Input.GetMousePosition(true))
    local playerPos = Isaac.WorldToScreen(player.Position +
        Tongue.PlayerHeadOffset * player.SpriteScale.Y)

    local rotation = (playerPos - targetPos):GetAngleDegrees()

    local startPos = Vector(0, 100)
    local endPos = Vector((playerPos - targetPos):Rotated(-rotation).X, 1)

    if #data.Points == 0 then
        for _ = 1, Tongue.PointCount do
            table.insert(data.Points, {
                Pos = startPos,
                Vel = Vector.Zero
            })
        end
    end

    data.Points[1].Pos = startPos
    data.Points[Tongue.PointCount].Vel = (endPos - data.Points[Tongue.PointCount].Pos):Resized(data.Points
        [Tongue.PointCount].Pos:Distance(
            endPos) / 10)

    for i = 1, Tongue.PointCount do
        local point = data.Points[i]
        local otherPoint = data.Points[i + 1]
        if i ~= 1 and otherPoint then
            if point.Pos.Y > 0 then
                point.Vel = point.Vel - Vector(0, 1)
            end

            if point.Pos:Distance(otherPoint.Pos) > Tongue.PointLength then
                point.Vel = point.Vel + (otherPoint.Pos - point.Pos):Resized(point.Pos:Distance(otherPoint.Pos) / 2)
            end
        end

        point.Pos = point.Pos + point.Vel / 2
        point.Vel = point.Vel * 0.975
    end

    for i = 0, Tongue.PointCount - 1 do
        local point = data.Points[Tongue.PointCount - i]
        local otherPoint = data.Points[Tongue.PointCount - (i + 1)]
        if i ~= 0 and otherPoint then
            if point.Pos.Y > 0 then
                point.Vel = point.Vel - Vector(0, 1)
            end

            if point.Pos:Distance(otherPoint.Pos) > Tongue.PointLength then
                point.Vel = point.Vel + (otherPoint.Pos - point.Pos):Resized(point.Pos:Distance(otherPoint.Pos) / 2)
            end
        end

        point.Pos = point.Pos + point.Vel / 2
        point.Vel = point.Vel * 0.975
    end

    local yStep = playerPos - targetPos

    for i = 1, Tongue.PointCount - 1 do
        local point = data.Points[i]
        local otherPoint = data.Points[i + 1]

        Isaac.DrawLine(startPos + point.Pos, startPos + otherPoint.Pos, KColor(1, 0, 0, 1), KColor(1, 0, 0, 1), 1)

        local renderPos1 = Vector(Vector(point.Pos.X, 0):Rotated(rotation).X,
            -point.Pos.Y + yStep.Y * (i - 1) / Tongue.PointCount)
        local renderPos2 = Vector(Vector(otherPoint.Pos.X, 0):Rotated(rotation).X,
            -otherPoint.Pos.Y + yStep.Y * i / Tongue.PointCount)

        Tongue.Beam:Add(targetPos + renderPos1 + startPos, Tongue.PointLength * (i - 1))
        Tongue.Beam:Add(targetPos + renderPos2 + startPos, Tongue.PointLength * i)
    end

    Tongue.Beam:Render(true)
end
--Resouled:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, tongueRender)
