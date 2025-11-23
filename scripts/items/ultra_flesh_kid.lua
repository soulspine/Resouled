local game = Game()

local ULTRA_FLESH_KID = Resouled.Enums.Items.ULTRA_FLESH_KID

local FAMILIAR_VARIANT = Isaac.GetEntityVariantByName("Ultra Flesh Kid")
local FAMILIAR_SUBTYPE = Isaac.GetEntitySubTypeByName("Ultra Flesh Kid")

local VELOCITY_MULTIPLIER = 0.85

local ATTACK_DISTANCE = 25
local DAMAGE = 8
local DAMAGE_AREA_MULTIPLIER = 2.5

local PLAYER_FOLLOW_ORBIT = 80

local animations = {
    HeadIdle = "HeadIdle",
    Bite = "HeadBite",
    BodyIdle = "BodyIdle"
}

---@param player EntityPlayer
local function onCacheEval(_, player)
    player:CheckFamiliar(FAMILIAR_VARIANT, player:GetCollectibleNum(ULTRA_FLESH_KID),
        player:GetCollectibleRNG(ULTRA_FLESH_KID), nil, FAMILIAR_SUBTYPE)
end
Resouled:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, onCacheEval, CacheFlag.CACHE_FAMILIARS)

---@param familiar EntityFamiliar
local function onFamiliarInit(_, familiar)
    if familiar.SubType == FAMILIAR_SUBTYPE then
        local sprite = familiar:GetSprite()
        sprite:Play(animations.BodyIdle, true)
        sprite:PlayOverlay(animations.HeadIdle, true)

        familiar.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
    end
end
Resouled:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, onFamiliarInit, FAMILIAR_VARIANT)

---@param familiar EntityFamiliar
local function onFamiliarUpdate(_, familiar)
    if familiar.SubType == FAMILIAR_SUBTYPE then
        local sprite = familiar:GetSprite()
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
                local distance = Resouled:GetDistanceFromHitboxEdge(familiar, familiar.Target)

                if distance > 0 then
                    familiar.Velocity = familiar.Velocity + (targetPos - familiarPos):Normalized()
                end

                if distance <= ATTACK_DISTANCE then
                    
                    if not sprite:IsOverlayPlaying(animations.Bite) then sprite:PlayOverlay(animations.Bite, true) end

                end

                if sprite:IsOverlayEventTriggered("Bite") then

                    local damage = DAMAGE
                    local player = Resouled:TryFindPlayerSpawner(familiar)
                    if player then
                        damage = damage * (player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) and 2 or 1)
                    end

                    ---@param entity Entity
                    for _, entity in pairs(Isaac.FindInRadius(familiar.Position + (familiar.Target.Position - familiar.Position):Resized(familiar.Size * DAMAGE_AREA_MULTIPLIER)/2, familiar.Size * DAMAGE_AREA_MULTIPLIER, EntityPartition.ENEMY)) do
                        local npc = entity:ToNPC()
                        if npc then
                            if Resouled:IsValidEnemy(npc) then
                                npc:TakeDamage(damage, DamageFlag.DAMAGE_NO_MODIFIERS, EntityRef(familiar), 0)
                            end
                        end
                    end
                end
            else
                familiar:GetPathFinder():FindGridPath(targetPos, VELOCITY_MULTIPLIER, 1, false)
            end
        end

        if sprite:IsOverlayFinished(animations.Bite) then sprite:PlayOverlay(animations.HeadIdle, true) end

        familiar.Velocity = familiar.Velocity * VELOCITY_MULTIPLIER

        sprite.FlipX = familiar.Velocity.X < 0
    end
end
Resouled:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, onFamiliarUpdate, FAMILIAR_VARIANT)
