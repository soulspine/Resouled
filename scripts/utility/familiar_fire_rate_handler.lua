---@class FamiliarFireRateHandlerModule
-- Module handling custom familiar firing with proper cooldown handling.
local familiarFireRateHandler = {}

-- PUT MOD HERE 
local MOD = Resouled

local registeredFamiliars = {}

local function makeKey(variant, subtype)
    return string.format("%d_%d", variant, subtype)
end

-- Registers a familiar for automatic cooldown handling.
---@param variant integer
---@param subtype integer
function familiarFireRateHandler:RegisterFamiliar(variant, subtype)
    registeredFamiliars[makeKey(variant, subtype)] = true
end

--- Unregisters a familiar from automatic cooldown handling.
---@param variant integer
---@param subtype integer
function familiarFireRateHandler:UnregisterFamiliar(variant, subtype)
    registeredFamiliars[makeKey(variant, subtype)] = nil
end

--- Checks if a familiar is registered for automatic cooldown handling.
---@param variant integer
---@param subtype integer
function familiarFireRateHandler:IsFamiliarRegistered(variant, subtype)
    return registeredFamiliars[makeKey(variant, subtype)] == true
end

--- Clears all registered familiars.
function familiarFireRateHandler:ClearRegisteredFamiliars()
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
function familiarFireRateHandler:TryShoot(familiar, direction, cooldown, damage, inheritVelocity)
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
        local spawnerData =  spawner:GetData()
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

return familiarFireRateHandler