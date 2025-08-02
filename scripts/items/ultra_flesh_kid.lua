local game = Game()

local ULTRA_FLESH_KID = Isaac.GetItemIdByName("Ultra Flesh Kid")

local FAMILIAR_VARIANT = Isaac.GetEntityVariantByName("Ultra Flesh Kid")
local FAMILIAR_SUBTYPE = Isaac.GetEntitySubTypeByName("Ultra Flesh Kid")

local VELOCITY_MULTIPLIER = 0.85

local DAMAGE = 8
local ATTACK_COOLDOWN = 20

if EID then
    EID:addCollectible(ULTRA_FLESH_KID,
    "Spawns a ultra flesh kid that crawls towards enemies # Ultra Flesh Kid deals "..tostring(DAMAGE).." every "..tostring(ATTACK_COOLDOWN).." updates")
end

local PLAYER_FOLLOW_ORBIT = 80

---@param player EntityPlayer
local function onCacheEval(_, player)
    player:CheckFamiliar(FAMILIAR_VARIANT, player:GetCollectibleNum(ULTRA_FLESH_KID),
        player:GetCollectibleRNG(ULTRA_FLESH_KID), nil, FAMILIAR_SUBTYPE)
end
Resouled:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, onCacheEval, CacheFlag.CACHE_FAMILIARS)

---@param familiar EntityFamiliar
local function onFamiliarInit(_, familiar)
    if familiar.SubType == FAMILIAR_SUBTYPE then
        familiar:GetSprite():Play("Idle", true)

        familiar.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
    end
end
Resouled:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, onFamiliarInit, FAMILIAR_VARIANT)

---@param familiar EntityFamiliar
local function onFamiliarUpdate(_, familiar)
    if familiar.SubType == FAMILIAR_SUBTYPE then
        local data = familiar:GetData()
        local familiarPos = familiar.Position
        local room = game:GetRoom()

        if not familiar.Target then
            local target = Resouled.Familiar.Targeting:SelectNearestEnemyTarget(familiar)

            if target then
                familiar.Target = target
            end

            local familiarParent = Resouled:TryFindPlayerSpawner(familiar)
            if familiarParent then
                if room:CheckLine(familiarPos, familiarParent.Position, LineCheckMode.ENTITY) then
                    if familiarPos:Distance(familiarParent.Position) > PLAYER_FOLLOW_ORBIT then
                        familiar.Velocity = (familiar.Velocity + (familiarParent.Position - familiar.Position):Normalized())
                    else
                        familiar.Velocity = familiar.Velocity * 0.75
                    end
                else
                    familiar:GetPathFinder():FindGridPath(familiarParent.Position, VELOCITY_MULTIPLIER, 1, false)
                end
            end
        else
            local target = Resouled.Familiar.Targeting:SelectNearestEnemyTarget(familiar)

            if target then
                familiar.Target = target
            end

            local targetPos = familiar.Target.Position

            if familiar.Target:IsDead() or not familiar.Target:IsActiveEnemy() or not familiar.Target:IsVulnerableEnemy() or not familiar:GetPathFinder():HasPathToPos(targetPos, false) then
                familiar.Target = nil
                return
            end

            if room:CheckLine(familiarPos, targetPos, LineCheckMode.ENTITY) then
                familiar.Velocity = familiar.Velocity + (targetPos - familiarPos):Normalized()

                if Resouled:GetDistanceFromHitboxEdge(familiar, familiar.Target) <= 0 and not data.Resouled_AttackCooldown then
                    familiar.Target:TakeDamage(DAMAGE, DamageFlag.DAMAGE_NO_MODIFIERS, EntityRef(familiar), 0)
                    data.Resouled_AttackCooldown = ATTACK_COOLDOWN
                end
            else
                familiar:GetPathFinder():FindGridPath(targetPos, VELOCITY_MULTIPLIER, 1, false)
            end
        end

        if data.Resouled_AttackCooldown then
            data.Resouled_AttackCooldown = data.Resouled_AttackCooldown - 1
            if data.Resouled_AttackCooldown <= 0 then
                data.Resouled_AttackCooldown = nil
            end
        end
        familiar.Velocity = familiar.Velocity * VELOCITY_MULTIPLIER
    end
end
Resouled:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, onFamiliarUpdate, FAMILIAR_VARIANT)
