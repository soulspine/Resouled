local CursedDople = {
    Id = Isaac.GetEntityTypeByName("Cursed Dople"),
    Variant = Isaac.GetEntityVariantByName("Cursed Dople"),
    SubType = Isaac.GetEntitySubTypeByName("Cursed Dople"),

    MoveSpeed = 2,
    TearSpeed = 10,
    BaseTearDamage = 3.5,
    TearDamagePerStage = 0.15,
    VelocityMultiplier = 0.8
}

local SHOOT = "Shoot"

---@param en EntityNPC
local function bindPlayer(en, data)
    for i = 0, Game():GetNumPlayers() - 1 do
        local player = Game():GetPlayer(i)
        if player then
            local playerData = player:GetData()
            if not playerData.Resouled_CursedDopleBind then
                playerData.Resouled_CursedDopleBind = EntityRef(en)

                data.Resouled_CursedDopleBind = EntityRef(player)
                return
            end
        end
    end
end

---@param en EntityNPC
local function unbindPlayer(en)
    local data = en:GetData()
    if data.Resouled_CursedDopleBind then
        local player = data.Resouled_CursedDopleBind.Entity
        player:GetData().Resouled_CursedDopleBind = nil
        data.Resouled_CursedDopleBind = nil
    end
end

---@param data table
local function freezeBindedPlayer(data)
    ---@type EntityPlayer
    local player = data.Resouled_CursedDopleBind.Entity:ToPlayer()

    if player then
        player:AddControlsCooldown(2)
        player:SetShootingCooldown(2)
    end
end

---@param en EntityNPC
---@param data table
local function getBindedPlayerInput(en, data)
    ---@type EntityPlayer
    local player = data.Resouled_CursedDopleBind.Entity:ToPlayer()

    return {
        Movement = player and -player:GetMovementInput() or Vector(0, 0),
        Shooting = player and -player:GetShootingInput() or Vector(0, 0)
    }
end

---@param en EntityNPC
---@param input Vector
local function move(en, input)
    en.Velocity = en.Velocity + input:Normalized() * CursedDople.MoveSpeed
end

---@param dir integer
---@return string
local function getHeadShootAnimFromDir(dir)
    if dir == 0 then
        return "HeadRightShoot"
    elseif dir == 1 then
        return "HeadDownShoot"
    elseif dir == 2 then
        return "HeadLeftShoot"
    elseif dir == 3 then
        return "HeadUpShoot"
    elseif dir == 4 then
        return "HeadRightShoot"
    end
    return ""
end

---@param input Vector
---@return string
local function getShootAnimationFromInput(input)
    if input:LengthSquared() <= 0.2 then return getHeadShootAnimFromDir(1) end

    local angle = input:GetAngleDegrees()%360

    angle = angle - angle%90

    for i = 0, 4 do
        local add = 90 * i
        if angle > -45 + add and angle < 45 + add then
            return getHeadShootAnimFromDir(i)
        end
    end

    return ""
end

---@param en EntityNPC
---@param input Vector
---@param data table
---@param sprite Sprite
local function shoot(en, input, data, sprite)
    if input.X == 0 and input.Y == 0 then return end

    if not sprite:GetOverlayAnimation():find(SHOOT) then
        local tear = Game():Spawn(EntityType.ENTITY_TEAR, TearVariant.BLOOD, en.Position, Vector.Zero, data.Resouled_CursedDopleBind.Entity, 0, Random()):ToTear()
        if not tear then return end
        
        local angle = input:GetAngleDegrees()%360
        tear.Velocity = Vector(1, 0):Rotated(angle + angle%90) * CursedDople.TearSpeed

        sprite:PlayOverlay(getShootAnimationFromInput(input), true)
    end
end

---@param dir integer
---@return string
local function getBodyAnimDir(dir)
    if dir == 0 then
        return "WalkHori"
    elseif dir == 1 then
        return "WalkVert"
    elseif dir == 2 then
        return "WalkHori"
    elseif dir == 3 then
        return "WalkVert"
    elseif dir == 4 then
        return "WalkHori"
    end
    return ""
end

---@param vel Vector
---@return string
local function getBodyAnimFromVelocity(vel)
    local angle = math.floor(vel:GetAngleDegrees()%360)

    if vel:LengthSquared() <= 0.2 then angle = 90 end

    for i = 0, 4 do
        local add = 90 * i
        if angle >= -45 + add and angle <= 45 + add then
            return getBodyAnimDir(i)
        end
    end

    return ""
end

---@param en EntityNPC
---@param sprite Sprite
---@param input Vector
local function setCorrectAnimations(en, sprite, input)
    local animation = sprite:GetAnimation()

    local animationOverlay = sprite:GetOverlayAnimation()
    if animationOverlay:find(SHOOT) then
        if sprite:GetOverlayFrame() == sprite:GetOverlayAnimationData():GetLength() - 1 then
            local anim = getShootAnimationFromInput(input)
            sprite:PlayOverlay(anim:sub(1, anim:len() - SHOOT:len()), true)
        end
    else
        local anim = getShootAnimationFromInput(en.Velocity:Rotated(45))
        sprite:PlayOverlay(anim:sub(1, anim:len() - SHOOT:len()), true)
    end

    local bodyAnim = getBodyAnimFromVelocity(en.Velocity)
    if en.Velocity:LengthSquared() > 0.2 then
        if animation ~= bodyAnim or sprite:GetFrame() == 0 then
            sprite:Play(bodyAnim, true)
        end
    else
        sprite:SetFrame("WalkVert", 0)
    end

    local body = sprite:GetLayer("Body")
    if body then
        body:SetFlipX(en.Velocity.X < 0)
    end
end

---@param en EntityNPC
local function die(en)
    unbindPlayer(en)
    en:Die()
end

---@param en EntityNPC
---@param data table
---@param room Room
local function focusCamera(en, data, room)
    ---@type EntityPlayer
    local player = data.Resouled_CursedDopleBind.Entity:ToPlayer()
    if player and player:GetPlayerIndex() == 0 then
        room:GetCamera():SetFocusPosition(en.Position)
    end
end

---@param en EntityNPC
local function onNpcInit(_, en)
    if en.Variant == CursedDople.Variant and en.SubType == CursedDople.SubType then
        local data = en:GetData()
        bindPlayer(en, data)


        en.CanShutDoors = false

        en:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_INIT, onNpcInit, CursedDople.Id)

---@param en EntityNPC
local function preNpcUpdate(_, en)
    if en.Variant == CursedDople.Variant and en.SubType == CursedDople.SubType then

        local data = en:GetData()

        if not data.Resouled_CursedDopleBind then
            bindPlayer(en)
            if not data.Resouled_CursedDopleBind then
                die(en)
                return
            end
        end

        local sprite = en:GetSprite()
        
        freezeBindedPlayer(data)

        local input = getBindedPlayerInput(en, data)

        move(en, input.Movement)

        shoot(en, input.Shooting, data, sprite)

        setCorrectAnimations(en, sprite, input.Shooting)

        en.Velocity = en.Velocity * CursedDople.VelocityMultiplier

        local room = Game():GetRoom()
        if room:IsClear() then
            die(en)
            return
        end

        focusCamera(en, data, room)

        return true
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, preNpcUpdate, CursedDople.Id)

---@param en Entity
local function preCollision(_, _, en)
    if en.Type == CursedDople.Id and en.Variant == CursedDople.Variant and en.SubType == CursedDople.SubType then
        return true
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, preCollision)
Resouled:AddCallback(ModCallbacks.MC_PRE_LASER_COLLISION, preCollision)
Resouled:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, preCollision)

---@param en Entity
---@param damage number
local function entityTakeDMG(_, en, damage)
    ---@diagnostic disable-next-line
    en = en:ToNPC()
    if en and en.HitPoints - damage <= 0 and en.Type == CursedDople.Id and en.Variant == CursedDople.Variant and en.SubType == CursedDople.SubType then
        die(en)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, entityTakeDMG)

---@param player EntityPlayer
local function prePlayerTakeDMG(_, player)
    if player:GetData().Resouled_CursedDopleBind then
        return false
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_PLAYER_TAKE_DMG, prePlayerTakeDMG)

---@param player EntityPlayer
local function onPlayerUpdate(_, player)
    local data = player:GetData()
    if data.Resouled_CursedDopleBind then
        ---@type EntityNPC
        local en = data.Resouled_CursedDopleBind.Entity:ToNPC()

        if en and not en:Exists() then
            data.Resouled_CursedDopleBind = nil
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, onPlayerUpdate)

Resouled:RegisterCursedEnemyMorph(EntityType.ENTITY_DOPLE, 0, 0, CursedDople.Id, CursedDople.Variant, CursedDople.SubType)