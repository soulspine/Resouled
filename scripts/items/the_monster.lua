local ITEM = Resouled.Enums.Items.THE_MONSTER

local Monster = {
    Sprite = Sprite(),
    HeadDirToAnimTranslation = { [Direction.LEFT] = "Left", [Direction.UP] = "Up", [Direction.RIGHT] = "Right", [Direction.DOWN] = "Down" },
    OffsetPerMonster = 13,
    AlphaWhenItemPickup = 0.16,
    AlphaToSubtractPerMonster = 0, --Make dss option
    MaxMonsters = nil,             --Make dss option
    WobbleEnabled = true,
}

local Tongue = {
    Sprite = Sprite(),
    SpriteLayer = 0,
    MaxLength = 10,
    Animations = {
        Start = "Start",
        Part = "Part",
        End = "End",
    }
}

local Chargebar = {
    Sprite = Sprite(),
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

Monster.Sprite:Load("gfx/the_monster.anm2", true)
Tongue.Sprite:Load("gfx/the_monster_tongue.anm2", true)
Chargebar.Sprite:Load("gfx/chargebar.anm2", true)
Chargebar.Sprite:ReplaceSpritesheet(0, "gfx/ui/monster_chargebar.png", true)

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

        local pos = player.Position + player.SpriteOffset + player.PositionOffset + headLayer:GetPos()

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
local function tongueBeamsRender(_, player)
    local playerData = player:GetData()
    if not playerData.RESOULED__MONSTER_BEAMS then return end

    ---@type Beam[]
    local beamsContainer = playerData.RESOULED__MONSTER_BEAMS

    for i, beam in ipairs(beamsContainer) do
        ---@type Vector
        local mouthPos = playerData.RESOULED__MONSTER_MOUTH_POS[i]

        local pointsNum = math.ceil(beam:GetPoints() / 2)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, tongueBeamsRender)

---@param player EntityPlayer
local function chargebarPlayerUpdate(_, player)
    local itemCount = player:GetCollectibleNum(ITEM)

    if itemCount == 0 then return end

    local data = player:GetData()
    local playerAnimation = player:GetSprite():GetAnimation()

    -- shoot or reset on release
    if player:GetShootingInput():Length() == 0 or playerAnimation:find("Item") or playerAnimation:find("Pickup") then
        if data.RESOULED__MONSTER_CHARGEBAR and data.RESOULED__MONSTER_CHARGEBAR.Remaining == 0 then
            -- shoot here
            data.RESOULED__MONSTER_BEAMS = {
                Beams = {}
            }

            for _, _ in ipairs(data.RESOULED__MONSTER_MOUTH_POS) do
                local beam = Beam(Tongue.Sprite, Tongue.SpriteLayer, false, false)
                table.insert(data.RESOULED__MONSTER_BEAMS.Beams, beam)
            end
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
