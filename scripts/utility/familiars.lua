-- PUT MOD HERE
local MOD = Resouled

---@class FamiliarModule
local familiarModule = {}

--- CheckFamiliar wrapper that autimatically handles all counting and RNG.
---@param player EntityPlayer
---@param itemId CollectibleType
---@param variant integer | FamiliarVariant
---@param subtype? integer
function familiarModule:CheckFamiliar(player, itemId, variant, subtype)
    local targetCount = player:GetCollectibleNum(itemId) + player:GetEffects():GetCollectibleEffectNum(itemId)
    local rng = player:GetCollectibleRNG(itemId)
    local itemConfigItem = Isaac.GetItemConfig():GetCollectible(itemId)

    player:CheckFamiliar(variant,
        targetCount,
        rng,
        itemConfigItem,
        subtype)
end

-----------------------
--     Targeting     --
-----------------------
familiarModule.Targeting = {}

--- Sets target of the familiar to a random enemy in the room. It is stored in its data as an `EntityRef`. \
--- Returns `true` if a target was found, `false` otherwise
---@param familiar EntityFamiliar
---@return boolean
function familiarModule.Targeting:SelectRandomEnemyTarget(familiar)
    local data = familiar:GetData()

    local validEnemies = {}

    ---@param npc EntityNPC
    Resouled.Iterators:IterateOverRoomNpcs(function(npc)
        if Resouled:IsValidEnemy(npc) then
            table.insert(validEnemies, EntityRef(npc))
        end
    end)
    if #validEnemies <= 0 then
        return false
    else
        ---@type EntityRef
        data.familiarTargetingTarget = validEnemies[math.random(#validEnemies)]
        return true
    end
end

--- Returns the target of the familiar. If the target is not set, returns `nil`
--- @param familiar EntityFamiliar
--- @return EntityNPC | nil
function familiarModule.Targeting:GetEnemyTarget(familiar)
    local data = familiar:GetData()
    if data.familiarTargetingTarget then
        ---@type EntityNPC
        local npc = data.familiarTargetingTarget.Entity:ToNPC()

        if npc and Resouled:IsValidEnemy(npc) and not npc:IsDead() then
            return npc
        else
            data.familiarTargetingTarget = nil
        end
    end
end

---@param familiar EntityFamiliar
function familiarModule.Targeting:ClearEnemyTarget(familiar)
    familiar:GetData().familiarTargetingTarget = nil
end

---@param familiar EntityFamiliar
function familiarModule.Targeting:SelectNearestEnemyTarget(familiar)
    ---@type nil | EntityNPC
    local nearestEnemy = Resouled:TryFindNearestEnemyByFindInRadius(familiar, 10)

    return nearestEnemy
end

-----------------------
-- Fire Rate Handler --
-----------------------
familiarModule.FireRateHandler = {}

local registeredFamiliars = {}

local function makeKey(variant, subtype)
    return string.format("%d_%d", variant, subtype)
end

-- Registers a familiar for automatic cooldown handling.
---@param variant integer
---@param subtype integer
function familiarModule.FireRateHandler:RegisterFamiliar(variant, subtype)
    registeredFamiliars[makeKey(variant, subtype)] = true
end

--- Unregisters a familiar from automatic cooldown handling.
---@param variant integer
---@param subtype integer
function familiarModule.FireRateHandler:UnregisterFamiliar(variant, subtype)
    registeredFamiliars[makeKey(variant, subtype)] = nil
end

--- Checks if a familiar is registered for automatic cooldown handling.
---@param variant integer
---@param subtype integer
function familiarModule.FireRateHandler:IsFamiliarRegistered(variant, subtype)
    return registeredFamiliars[makeKey(variant, subtype)] == true
end

--- Clears all registered familiars.
function familiarModule.FireRateHandler:ClearRegisteredFamiliars()
    registeredFamiliars = {}
end

--- Tries to shoot a tear in specified direction while ensuring cooldown works properly.
--- Returns the created tear entity or `nil` if it couldn't shoot.
---@param familiar EntityFamiliar
---@param direction Vector Will get normalized.
---@param cooldown integer Cooldown value to set for the familiar.
---@param inheritVelocity? boolean default `false`
---@param damage? integer Optional damage value to set for the tear
---@return EntityTear|nil
function familiarModule.FireRateHandler:TryShoot(familiar, direction, cooldown, damage, inheritVelocity)
    inheritVelocity = inheritVelocity or false
    if familiar.FireCooldown <= 1 then
        familiar:GetData().FAMILIAR_FIRE_RATE___________________________NEXT_TEAR_IS_REAL = true
        local tear = familiar:FireProjectile(direction:Normalized())
        if damage then
            tear.CollisionDamage = (tear.BaseDamage * damage) / 3.5
        end
        if not inheritVelocity then
            local player = Resouled:TryFindPlayerSpawner(familiar)
            if player then
                tear.Velocity = tear.Velocity - player:GetTearMovementInheritance(direction:Normalized())
            end
        end
        familiar.FireCooldown = cooldown + familiar.FireCooldown
        return tear
    end
    return nil
end

---@param tear EntityTear
local function onTearInit(_, tear)
    local spawner = tear.SpawnerEntity
    if spawner and spawner.Type == EntityType.ENTITY_FAMILIAR
        and registeredFamiliars[makeKey(spawner.Variant, spawner.SubType)]
    then
        local spawnerData = spawner:GetData()
        if spawnerData.FAMILIAR_FIRE_RATE___________________________NEXT_TEAR_IS_REAL then
            spawnerData.FAMILIAR_FIRE_RATE___________________________NEXT_TEAR_IS_REAL = nil
        else
            tear.Visible = false
            tear:GetData().FAMILIAR_FIRE_RATE___________________________STOP_SFX = true
            tear:Remove()
        end
    end
end
MOD:AddCallback(ModCallbacks.MC_POST_TEAR_INIT, onTearInit)

---@param familiar EntityFamiliar
local function onFamiliarUpdate(_, familiar)
    if registeredFamiliars[makeKey(familiar.Variant, familiar.SubType)] then
        if familiar.FireCooldown > 0 then
            local sprite = familiar:GetSprite()
            local preFlip = sprite.FlipX
            familiar:Shoot()
            sprite.FlipX = preFlip -- Ensure sprite flip state is preserved
        end
    end
end
MOD:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, onFamiliarUpdate)

return familiarModule
