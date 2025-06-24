local GFUEL = Isaac.GetItemIdByName("Red GFUEL")

local GFUEL_SPRITE = Sprite()
GFUEL_SPRITE:Load("gfx/red_gfuel.anm2", true)
GFUEL_SPRITE:Play("Idle", true)

local UP_BRIMSTONE_OFFSET = Vector(0, -80)
local DOWN_LASER_START_POSITION = Vector(0, -1000)

local LASER_VARIANT = LaserVariant.THICKER_RED

local RED_GFUEL_TIMEOUT = 300

---@param item CollectibleType
---@param rng RNG
---@param player EntityPlayer
local function onActveUse(_, item, rng, player)
    player:AnimatePickup(GFUEL_SPRITE, nil, "LiftItem")
    local data = player:GetData()
    if not data.Resouled_RedGfuel then
            data.Resouled_RedGfuel = {
                UP = Game():Spawn(EntityType.ENTITY_LASER, LASER_VARIANT, player.Position, Vector.Zero, player, 0, player.InitSeed):ToLaser(),
                DOWN = Game():Spawn(EntityType.ENTITY_LASER, LASER_VARIANT, player.Position + DOWN_LASER_START_POSITION, Vector.Zero, player, 0, player.InitSeed):ToLaser(),
                TIMEOUT = RED_GFUEL_TIMEOUT,
            }
            data.Resouled_RedGfuel.UP:SetActiveRotation(0, 270, 999999, false)
            data.Resouled_RedGfuel.UP.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
            data.Resouled_RedGfuel.UP.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
            data.Resouled_RedGfuel.UP.DepthOffset = 1000
            data.Resouled_RedGfuel.UP:GetData().Resouled_RedGfuelUp = true

            data.Resouled_RedGfuel.DOWN:SetActiveRotation(0, 90, 999999, false)
            data.Resouled_RedGfuel.DOWN.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
            data.Resouled_RedGfuel.DOWN.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
            data.Resouled_RedGfuel.DOWN:GetData().Resouled_RedGfuelDown = true
            data.Resouled_RedGfuel.DOWN.DepthOffset = 1000
        end
end
Resouled:AddCallback(ModCallbacks.MC_USE_ITEM, onActveUse, GFUEL)

---@param player EntityPlayer
local function onPlayerUpdate(_, player)
    local data = player:GetData()
    if player:GetHeldSprite():GetFilename() == GFUEL_SPRITE:GetFilename() and data.Resouled_RedGfuel then
        if data.Resouled_RedGfuel.UP then
            data.Resouled_RedGfuel.UP.Position = player.Position + player.SpriteOffset + UP_BRIMSTONE_OFFSET - data.Resouled_RedGfuel.UP.Velocity
            data.Resouled_RedGfuel.UP.Velocity = player.Velocity
        end
            
        if data.Resouled_RedGfuel.DOWN then
            data.Resouled_RedGfuel.DOWN.Velocity = data.Resouled_RedGfuel.DOWN.Velocity + player:GetShootingInput() * 1.5
            data.Resouled_RedGfuel.DOWN.Velocity = data.Resouled_RedGfuel.DOWN.Velocity * 0.85
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
    elseif player:GetHeldSprite():GetFilename() ~= GFUEL_SPRITE:GetFilename() and data.Resouled_RedGfuel then
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
        ---@param entity Entity
        Resouled.Iterators:IterateOverRoomEntities(function(entity)
            local npc = entity:ToNPC()
            if npc and npc.Position:Distance(laser.Position - DOWN_LASER_START_POSITION) - npc.Size <= laser.Size * 1.25 and npc:IsActiveEnemy() and npc:IsVulnerableEnemy() then
                npc:TakeDamage(player.Damage, DamageFlag.DAMAGE_LASER, EntityRef(player), 0)
            end
        end)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, onLaserUpdate)