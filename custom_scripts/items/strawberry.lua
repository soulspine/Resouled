local STRAWBERRY = Isaac.GetItemIdByName("Strawberry")

local POSITION_OFFSET = Vector(0,-30)
local CONSUME_SPEED_THRESHOLD = 0.01

if EID then
    EID:addCollectible(STRAWBERRY, "Not implemented yet", "Strawberry")
end

local STRAWBERRY_VARIANT = Isaac.GetEntityVariantByName("Regular Strawberry Pickup")
local STRAWBERRY_REGULAR_SUBTYPE = 0

local berryJustPickedUp = false
local berryJustConsumed = false

---@param player EntityPlayer
---@return integer
local function countRegularBerries(player)
    return Isaac.CountEntities(player, EntityType.ENTITY_FAMILIAR, STRAWBERRY_VARIANT, STRAWBERRY_REGULAR_SUBTYPE)
end

---@param player EntityPlayer
---@param cacheFlags CacheFlag
local function onCacheEval(_, player, cacheFlags)
    if player:HasCollectible(STRAWBERRY) and cacheFlags & CacheFlag.CACHE_SPEED == CacheFlag.CACHE_SPEED then
        local berryCount = countRegularBerries(player) + (berryJustPickedUp and 1 or 0) - (berryJustConsumed and 1 or 0)
        print("Upper berry count: " .. berryCount)
        player.MoveSpeed = player.MoveSpeed + 0.1 * berryCount
    end
end

---@param pickup EntityPickup
local function onBerryPickupInit(_, pickup)
    local sprite = pickup:GetSprite()
    sprite:Play("Idle", true)
    pickup.PositionOffset = POSITION_OFFSET
    pickup.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
    berryJustPickedUp = true
end

---@param familiar EntityFamiliar
local function onBerryFamiliarInit(_, familiar)
    familiar.PositionOffset = POSITION_OFFSET
    familiar:GetSprite():SetFrame(math.random(0,15))
    familiar:AddToFollowers()
    local player = familiar.SpawnerEntity:ToPlayer()

    if player == nil then
        return
    end

    --player:AddCacheFlags(CacheFlag.CACHE_SPEED)
    --player:EvaluateItems()

end

---@param familiar EntityFamiliar
local function onBerryFamiliarUpdate(_, familiar)
    --print("Familiar update")
    familiar:FollowParent()
end

---@param pickup EntityPickup
---@param collider Entity
---@param low boolean
local function onBerryPickupCollision(_, pickup, collider, low)
    --print(collider.Type)
    if collider.Type == EntityType.ENTITY_PLAYER then
        local player = collider:ToPlayer()

        if player == nil then
            return
        end

        if player:HasCollectible(STRAWBERRY) then
            pickup:Remove()
            Isaac.Spawn(EntityType.ENTITY_FAMILIAR, STRAWBERRY_VARIANT, pickup.SubType, pickup.Position, Vector.Zero, player)
        end
    end
end

---@param player EntityPlayer
---@param playerID any
local function onUpdate(player, playerID)
    local berryCount = countRegularBerries(player)
    if player:HasCollectible(STRAWBERRY) and berryCount > 0 and player:GetVelocityBeforeUpdate():Length() < CONSUME_SPEED_THRESHOLD then
        while berryCount > 0 do
            -- TODO CONSUME BERRIES AND ANIMATE SCORE
            berryCount = berryCount - 1
            player:CheckFamiliar(STRAWBERRY_VARIANT, berryCount, RNG(), nil, STRAWBERRY_REGULAR_SUBTYPE)
        end
        --print("Lower berry count: " .. berryCount)
        --berryJustConsumed = true
        --player:AddCacheFlags(CacheFlag.CACHE_SPEED)
        --player:EvaluateItems()
    end
end

MOD:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, onBerryPickupInit, STRAWBERRY_VARIANT)
MOD:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, onBerryPickupCollision, STRAWBERRY_VARIANT)
MOD:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, onBerryFamiliarInit, STRAWBERRY_VARIANT)
MOD:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, onBerryFamiliarUpdate, STRAWBERRY_VARIANT)
MOD:AddCallback(ModCallbacks.MC_POST_UPDATE, function() IterateOverPlayers(onUpdate) end)
-- TODO FIX SPEED
--MOD:AddPriorityCallback(ModCallbacks.MC_EVALUATE_CACHE, CallbackPriority.LATE, onCacheEval)