local COOP_BABY = Isaac.GetItemIdByName("Co-Op Baby")
local COOP_BABY_VARIANT = Isaac.GetEntityVariantByName("Coop Baby")
local COOP_BABY_SUBTYPE = Isaac.GetEntitySubTypeByName("Coop Baby")

local e = Resouled.EID

if EID then
    EID:addCollectible(COOP_BABY,
    "Spawns a co-op baby familiar that targets last damaged enemy")
end

local FIRE_DAMAGE = 2.5
local FIRE_COOLDOWN = 20
local BASE_ORBIT_SIZE = 20
local VELOCITY_MULTIPLIER = 0.85
local ORBIT_SPEED = 2
local TEAR_SPEED = 15
local ANIMATION_LENGTH = 16
local FOLLOW_SPEED = 2

Resouled.Familiar.FireRateHandler:RegisterFamiliar(COOP_BABY_VARIANT, COOP_BABY_SUBTYPE)

---@param velocity Vector
local function getAngleSprite(velocity)
    local angleDegrees = velocity:GetAngleDegrees() -- + 180

    if angleDegrees < 0 then
        angleDegrees = angleDegrees + 360
    end

    if angleDegrees >= 0 and angleDegrees < 22.5 or angleDegrees >= 337.5 and angleDegrees <= 360 then
        return "3"
    elseif angleDegrees >= 22.5 and angleDegrees < 67.5 then
        return "2"
    elseif angleDegrees >= 67.5 and angleDegrees < 112.5 then
        return "1"
    elseif angleDegrees >= 112.5 and angleDegrees < 157.5 then
        return "8"
    elseif angleDegrees >= 157.5 and angleDegrees < 202.5 then
        return "7"
    elseif angleDegrees >= 202.5 and angleDegrees < 247.5 then
        return "4"
    elseif angleDegrees >= 247.5 and angleDegrees < 292.5 then
        return "5"
    elseif angleDegrees >= 292.5 and angleDegrees < 337.5 then
        return "6"
    end
end

---@param player EntityPlayer
---@param cacheFlag CacheFlag
local function onCacheEval(_, player, cacheFlag)
    player:CheckFamiliar(COOP_BABY_VARIANT,
        player:GetCollectibleNum(COOP_BABY) + player:GetEffects():GetCollectibleEffectNum(COOP_BABY),
        player:GetCollectibleRNG(COOP_BABY), Isaac.GetItemConfig():GetCollectible(COOP_BABY), COOP_BABY_SUBTYPE)
end
Resouled:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, onCacheEval, CacheFlag.CACHE_FAMILIARS)

---@param familiar EntityFamiliar
local function onFamiliarUpdate(_, familiar)
    if familiar.SubType == COOP_BABY_SUBTYPE then
        local sprite = familiar:GetSprite()

        if sprite:GetFrame() < 0 then
            sprite:SetFrame(0)
        end

        if not familiar.Target then
            familiar:AddToFollowers()
            familiar:FollowParent()

            local targetAnim = getAngleSprite(familiar.Velocity)
            if sprite:GetAnimation() ~= targetAnim then
                sprite:SetAnimation(targetAnim, false)
            end
        else
            local target = familiar.Target
            local distanceFromTarget = familiar.Position:Distance(target.Position)
            local size = target.Size / 3
            if distanceFromTarget > BASE_ORBIT_SIZE * size + BASE_ORBIT_SIZE then
                familiar.Velocity = (familiar.Velocity + (target.Position - familiar.Position):Normalized() * FOLLOW_SPEED) *
                VELOCITY_MULTIPLIER
            end
            if distanceFromTarget <= (BASE_ORBIT_SIZE * size) - BASE_ORBIT_SIZE then
                familiar.Velocity = (familiar.Velocity + (familiar.Position - target.Position):Normalized() * FOLLOW_SPEED) *
                VELOCITY_MULTIPLIER
            end
            if Resouled.Familiar.FireRateHandler:TryShoot(familiar, (target.Position - familiar.Position), FIRE_COOLDOWN, FIRE_DAMAGE) then
                sprite:Play(sprite:GetAnimation() .. "Shoot", true)
            end

            if distanceFromTarget <= (BASE_ORBIT_SIZE * size) then
                familiar.Velocity = (familiar.Velocity + target.Velocity) / 2 +
                (target.Position - familiar.Position):Normalized():Rotated(90) * ORBIT_SPEED
            end

            local targetAnim = getAngleSprite(target.Position - familiar.Position)

            if sprite:GetAnimation() ~= targetAnim then
                sprite:SetAnimation(targetAnim, false)
            end
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, onFamiliarUpdate, COOP_BABY_VARIANT)

---@param entity Entity
---@param amount number
---@param flags DamageFlag
---@param source EntityRef
local function entityTakeDamage(_, entity, amount, flags, source)
    local player = Resouled:TryFindPlayerSpawner(source.Entity)
    if player and entity:IsEnemy() and entity:IsActiveEnemy() and entity:IsVulnerableEnemy() and entity.HitPoints - amount > 0 then
        ---@param familiar EntityFamiliar
        Resouled.Iterators:IterateOverRoomFamiliars(function(familiar)
            if familiar.Variant == COOP_BABY_VARIANT and familiar.SubType == COOP_BABY_SUBTYPE then
                local spawner = Resouled:TryFindPlayerSpawner(familiar)
                if spawner and spawner:GetPlayerIndex() == player:GetPlayerIndex() then
                    familiar.Target = entity
                end
            end
        end)
    end
end
Resouled:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, entityTakeDamage)
