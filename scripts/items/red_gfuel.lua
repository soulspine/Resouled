local GFUEL = Isaac.GetItemIdByName("Red GFUEL")

local GFUEL_SPRITE = Sprite()
GFUEL_SPRITE:Load("gfx/red_gfuel.anm2", true)
GFUEL_SPRITE:Play("Idle", true)

local UP_BRIMSTONE_OFFSET = Vector(0, -80)
local DOWN_LASER_START_POSITION = Vector(0, -1000)

local LASER_VARIANT = LaserVariant.THICKER_RED
local STATIC_SHOCK_BRIMSTONE = LaserVariant.GIANT_BRIM_TECH

local RED_GFUEL_TIMEOUT = 300

local FLAT_DAMAGE = 1
local DAMAGE_MULTIPLIER = 0.125

---@param item CollectibleType
---@param rng RNG
---@param player EntityPlayer
local function onActveUse(_, item, rng, player)
    player:AnimatePickup(GFUEL_SPRITE, nil, "LiftItem")
    local data = player:GetData()
    if not data.Resouled_RedGfuel and player:GetHeldSprite():GetFilename() == GFUEL_SPRITE:GetFilename() then
        local laserVariant = LASER_VARIANT
        if Resouled:RoomEventPresent(Resouled.RoomEvents.STATIC_SHOCK) then
            laserVariant = STATIC_SHOCK_BRIMSTONE
        end
        data.Resouled_RedGfuel = {
            UP = Game():Spawn(EntityType.ENTITY_LASER, laserVariant, player.Position, Vector.Zero, player, 0, player.InitSeed):ToLaser(),
            DOWN = Game():Spawn(EntityType.ENTITY_LASER, laserVariant, player.Position + DOWN_LASER_START_POSITION, Vector.Zero, player, 0, player.InitSeed):ToLaser(),
            TIMEOUT = RED_GFUEL_TIMEOUT,
        }

        local playerTearEffects = player.TearFlags

        if player:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY) then
            data.Resouled_RedGfuel.TIMEOUT = data.Resouled_RedGfuel.TIMEOUT * 2
        end

        data.Resouled_RedGfuel.UP:SetActiveRotation(0, 270, 999999, false)
        data.Resouled_RedGfuel.UP.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
        data.Resouled_RedGfuel.UP.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        data.Resouled_RedGfuel.UP.DepthOffset = 1000
        data.Resouled_RedGfuel.UP:GetData().Resouled_RedGfuelUp = true
        data.Resouled_RedGfuel.UP:AddTearFlags(playerTearEffects)

        data.Resouled_RedGfuel.DOWN:SetActiveRotation(0, 90, 999999, false)
        data.Resouled_RedGfuel.DOWN.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
        data.Resouled_RedGfuel.DOWN.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        data.Resouled_RedGfuel.DOWN:GetData().Resouled_RedGfuelDown = true
        data.Resouled_RedGfuel.DOWN.DepthOffset = 1000
        data.Resouled_RedGfuel.DOWN:AddTearFlags(playerTearEffects)
    else
        if data.Resouled_RedGfuel.TIMEOUT then
            data.Resouled_RedGfuel.TIMEOUT = data.Resouled_RedGfuel.TIMEOUT + RED_GFUEL_TIMEOUT
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_USE_ITEM, onActveUse, GFUEL)

---@param player EntityPlayer
local function onPlayerUpdate(_, player)
    local data = player:GetData()
    if player:GetHeldSprite():GetFilename() == GFUEL_SPRITE:GetFilename() and data.Resouled_RedGfuel and data.Resouled_RedGfuel.DOWN:Exists() and data.Resouled_RedGfuel.UP:Exists() then
        Game():ShakeScreen(3)
        if data.Resouled_RedGfuel.UP then
            data.Resouled_RedGfuel.UP.Position = player.Position + player.SpriteOffset + UP_BRIMSTONE_OFFSET - data.Resouled_RedGfuel.UP.Velocity
            data.Resouled_RedGfuel.UP.Velocity = player.Velocity
        end
            
        if data.Resouled_RedGfuel.DOWN then
            data.Resouled_RedGfuel.DOWN.Velocity = data.Resouled_RedGfuel.DOWN.Velocity + player:GetShootingInput() * 1.5
            data.Resouled_RedGfuel.DOWN.Velocity = data.Resouled_RedGfuel.DOWN.Velocity * 0.85

            local topLeft = Game():GetRoom():GetTopLeftPos()
            local bottomRight = Game():GetRoom():GetBottomRightPos()

            local laserPos = data.Resouled_RedGfuel.DOWN.Position - DOWN_LASER_START_POSITION
            local laserVelocity = data.Resouled_RedGfuel.DOWN.Velocity

            if laserPos.X + laserVelocity.X < topLeft.X or laserPos.X + laserVelocity.X > bottomRight.X or laserPos.Y + laserVelocity.Y < topLeft.Y or laserPos.Y + laserVelocity.Y > bottomRight.Y then
                data.Resouled_RedGfuel.DOWN.Velocity = Vector.Zero
            end
        end

        if data.Resouled_RedGfuel.TIMEOUT then
            data.Resouled_RedGfuel.TIMEOUT = data.Resouled_RedGfuel.TIMEOUT - 1
            if data.Resouled_RedGfuel.TIMEOUT == 15 then
                data.Resouled_RedGfuel.UP:SetTimeout(1)
                data.Resouled_RedGfuel.DOWN:SetTimeout(1)
            end
            if data.Resouled_RedGfuel.TIMEOUT <= 0 then
                player:AnimatePickup(GFUEL_SPRITE, nil, "HideItem")
                data.Resouled_RedGfuel.TIMEOUT = nil
            end
        end
    elseif player:GetHeldSprite():GetFilename() == GFUEL_SPRITE:GetFilename() and data.Resouled_RedGfuel and not data.Resouled_RedGfuel.UP:Exists() and not data.Resouled_RedGfuel.DOWN:Exists() then
        player:AnimatePickup(GFUEL_SPRITE, nil, "HideItem")
        data.Resouled_RedGfuel = nil
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, onPlayerUpdate)

---@param player EntityPlayer
local function playerTakeDamage(_, player)
    local data = player:GetData()
    if data.Resouled_RedGfuel then
        data.Resouled_RedGfuel.UP:SetTimeout(1)
        data.Resouled_RedGfuel.DOWN:SetTimeout(1)
        data.Resouled_RedGfuel = nil
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_PLAYER_TAKE_DMG, playerTakeDamage)

local function postNewRoom()
    ---@param player EntityPlayer
    Resouled.Iterators:IterateOverPlayers(function(player)
        local data = player:GetData()
        if data.Resouled_RedGfuel then
            data.Resouled_RedGfuel = nil
        end
    end)
end
Resouled:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, postNewRoom)

---@param laser EntityLaser
local function preLaserCollision(_, laser)
    local data = laser:GetData()
    if data.Resouled_RedGfuelUp or data.Resouled_RedGfuelDown then
        return true
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_LASER_COLLISION, preLaserCollision)

---@param laser EntityLaser
local function onLaserUpdate(_, laser)
    local data = laser:GetData()
    if data.Resouled_RedGfuelDown then
        local player = Resouled:TryFindPlayerSpawner(laser)
        if not player then return end
        ---@param npc EntityNPC
        Resouled.Iterators:IterateOverRoomNpcs(function(npc)
            if npc.Position:Distance(laser.Position - DOWN_LASER_START_POSITION) - npc.Size <= laser.Size * 1.25 and npc:IsActiveEnemy() and npc:IsVulnerableEnemy() then
                npc:TakeDamage(FLAT_DAMAGE + (player.Damage * DAMAGE_MULTIPLIER), DamageFlag.DAMAGE_LASER, EntityRef(player), 0)
            end
        end)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, onLaserUpdate)