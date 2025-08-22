local ITEM = Resouled.Enums.Items.FETAL_HAUNT
local FAMILIAR = Resouled.Enums.Familiars.FETAL_HAUNT

-- in updates
local ATTACK_COOLDOWN = 200
local ATTACK_DURATION = 200
local ATTACK_POSITION_FIND_RADIUS = 100 -- finds a position near a random vulnerable enemy within this margin
local ATTACK_POSITION_ACCEPTANCE_RADIUS = 25
local ATTACK_TEAR_FLAGS = TearFlags.TEAR_SPECTRAL | TearFlags.TEAR_PIERCING
local ATTACK_TEAR_FALLING_SPEED = -22
local ATTACK_TEAR_FALLING_ACCELERATION = 3
local ATTACK_TEAR_POSITION_ADJUSTMENT = Vector(0, 5)
local ATTACK_TEAR_POSITION_VARIANCE = Vector(7, 3)
local ATTACK_SPRITE_OFFSET_TARGET = 15
local ATTACK_SPRITE_OFFSET_STEP = 0.5
local ATTACK_CHANCE = 0.5

local ENTITY_COLLISION_CLASS = EntityCollisionClass.ENTCOLL_NONE
local GRID_COLLISION_CLASS = GridCollisionClass.COLLISION_NONE

local ANIMATION_IDLE = "Float"
local ANIMATION_ATTACK = "Cry"

---@param radius integer How far from an enemy can a valid position be found
---@return Vector | nil
local function getRandomPositionNearEnemy(radius)
    local validPositionCenters = {}
    Resouled.Iterators:IterateOverRoomEntities(function(entity)
        if entity:IsActiveEnemy() and entity:IsVulnerableEnemy() then
            table.insert(validPositionCenters, entity.Position)
        end
    end)

    if #validPositionCenters == 0 then return nil end

    ::reroll::
    local selectedCenter = validPositionCenters[math.random(#validPositionCenters)]
    local chosenPosition = selectedCenter + Vector(math.random(-radius, radius), math.random(-radius, radius))

    if not Game():GetRoom():IsPositionInRoom(chosenPosition, 0) then
        goto reroll
    end

    return chosenPosition
end

---@param player EntityPlayer
---@param cacheFlag CacheFlag
local function onCacheEval(_, player, cacheFlag)
    Resouled.Familiar:CheckFamiliar(player, ITEM, FAMILIAR.Variant, FAMILIAR.SubType)
end
Resouled:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, onCacheEval, CacheFlag.CACHE_FAMILIARS)

---@param familiar EntityFamiliar
local function onFamiliarInit(_, familiar)
    if familiar.SubType ~= FAMILIAR.SubType then return end
    familiar:AddToFollowers()
    familiar:GetData().RESOULED__FETAL_HAUNT_ATTACK_COOLDOWN = ATTACK_COOLDOWN
    familiar.EntityCollisionClass = ENTITY_COLLISION_CLASS
    familiar.GridCollisionClass = GRID_COLLISION_CLASS
end
Resouled:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, onFamiliarInit, FAMILIAR.Variant)

---@param familiar EntityFamiliar
local function onFamiliarUpdate(_, familiar)
    if familiar.SubType ~= FAMILIAR.SubType then return end

    local sprite = familiar:GetSprite()
    local data = familiar:GetData()

    sprite.FlipX = Resouled.Vector:IsFacingRight(familiar.Velocity)

    if data.RESOULED__FETAL_HAUNT_ATTACK_COOLDOWN then
        familiar:FollowParent()
        if data.RESOULED__FETAL_HAUNT_ATTACK_COOLDOWN > 0 then
            data.RESOULED__FETAL_HAUNT_ATTACK_COOLDOWN = data.RESOULED__FETAL_HAUNT_ATTACK_COOLDOWN - 1
        else
            data.RESOULED__FETAL_HAUNT_ATTACK_POSITION = getRandomPositionNearEnemy(ATTACK_POSITION_FIND_RADIUS)
            if data.RESOULED__FETAL_HAUNT_ATTACK_POSITION then
                data.RESOULED__FETAL_HAUNT_ATTACK_COOLDOWN = nil
                familiar:RemoveFromFollowers()
            end
        end
    end

    if data.RESOULED__FETAL_HAUNT_ATTACK_POSITION then
        if familiar.Position:Distance(data.RESOULED__FETAL_HAUNT_ATTACK_POSITION) > ATTACK_POSITION_ACCEPTANCE_RADIUS then
            familiar:FollowPosition(data.RESOULED__FETAL_HAUNT_ATTACK_POSITION)
        else
            familiar.Velocity = Vector.Zero
            if familiar.SpriteOffset.Y < ATTACK_SPRITE_OFFSET_TARGET then
                familiar.SpriteOffset = familiar.SpriteOffset + Vector(0, ATTACK_SPRITE_OFFSET_STEP)
            else
                sprite:Play(ANIMATION_ATTACK, true)
                data.RESOULED__FETAL_HAUNT_ATTACK_DURATION_LEFT = ATTACK_DURATION
                data.RESOULED__FETAL_HAUNT_ATTACK_POSITION = nil
            end
        end
    end

    if data.RESOULED__FETAL_HAUNT_ATTACK_DURATION_LEFT then
        if data.RESOULED__FETAL_HAUNT_ATTACK_DURATION_LEFT > 0 then
            data.RESOULED__FETAL_HAUNT_ATTACK_DURATION_LEFT = data.RESOULED__FETAL_HAUNT_ATTACK_DURATION_LEFT - 1

            -- SHOOTING TEARS
            if math.random() < ATTACK_CHANCE then
                local tear = familiar:FireProjectile(RandomVector():Normalized())
                tear.TearFlags = tear.TearFlags | ATTACK_TEAR_FLAGS
                tear.FallingAcceleration = ATTACK_TEAR_FALLING_ACCELERATION
                tear.FallingSpeed = ATTACK_TEAR_FALLING_SPEED
                tear.Position = tear.Position + ATTACK_TEAR_POSITION_ADJUSTMENT + familiar.SpriteOffset +
                    Vector(math.random(-ATTACK_TEAR_POSITION_VARIANCE.X, ATTACK_TEAR_POSITION_VARIANCE.X),
                        math.random(-ATTACK_TEAR_POSITION_VARIANCE.Y, ATTACK_TEAR_POSITION_VARIANCE.Y))
            end
        elseif familiar.SpriteOffset.Y ~= 0 then
            familiar.SpriteOffset = familiar.SpriteOffset - Vector(0, ATTACK_SPRITE_OFFSET_STEP)
        else
            data.RESOULED__FETAL_HAUNT_ATTACK_DURATION_LEFT = nil
            sprite:Play(ANIMATION_IDLE, true)
            data.RESOULED__FETAL_HAUNT_ATTACK_COOLDOWN = ATTACK_COOLDOWN
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, onFamiliarUpdate, FAMILIAR.Variant)
