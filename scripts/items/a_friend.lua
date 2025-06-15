local A_FRIEND = Isaac.GetItemIdByName("A Friend")

local FRIEND_VARIANT = Isaac.GetEntityVariantByName("A Friend")
local FRIEND_SUBTYPE = Isaac.GetEntitySubTypeByName("A Friend")

local HEAD_IDLE = "HeadIdle"
local HEAD_UP = "HeadUp"
local HEAD_DOWN = "HeadDown"
local HEAD_RIGHT = "HeadRight"
local HEAD_LEFT = "HeadLeft"

local BODY_IDLE = "WalkIdle"
local BODY_UP = "WalkUp"
local BODY_DOWN = "WalkDown"
local BODY_RIGHT = "WalkRight"
local BODY_LEFT = "WalkLeft"

local SHOOT = "Shoot"

local WALK_SPEED = 1
local START_WANDERING_AROUND_CHANCE = 0.025

local FOLLOW_ORBIT = 100

local AVOID_SPEED = 0.5

local SHOOT_COOLDOWN = 15
local TEAR_SPEED = 13

local PROJECTILE_AVOID_RANGE = 75
local PROJECTILE_AVOID_SPEED = 0.5

local BOMB_AVOID_RANGE = 100
local BOMB_AVOID_SPEED = 1.5

local GRID_AVOID_RANGE = 40
local GRID_AVOID_SPEED = 1.5

local POOP_BREAK_ACTION_CHANCE = 0.075

local OTHER_FRIEND_AVOID_RANGE = 20
local OTHER_FRIEND_AVOID_SPEED = 2

local PUSH_POWER = 0.9
local VELOCITY_LOSS_PER_UPDATE = 0.975

local PICKUP_PICK_UP_RANGE = 22

local BOMB_PLACEMENT_RANGE = 15
local BOMB_COOLDOWN = 600

local FRIEND_PICKUP_DISTANCE = 25

---@param type CollectibleType
---@param player EntityPlayer
local function postAddCollectible(_, type, player)
    if type == A_FRIEND then
        Game():Spawn(EntityType.ENTITY_FAMILIAR, FRIEND_VARIANT, Isaac.GetPlayer(player).Position, Vector.Zero, Isaac.GetPlayer(player), FRIEND_SUBTYPE, Isaac.GetPlayer(player).InitSeed)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, postAddCollectible)

---@param familiar EntityFamiliar
local function postFamiliarInit(_, familiar)
    if familiar.SubType == FRIEND_SUBTYPE then
        familiar.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
        familiar.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
    end
end
Resouled:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, postFamiliarInit, FRIEND_VARIANT)

---@param familiar EntityFamiliar
---@param collider Entity
local function postFamiliarCollision(_, familiar, collider)
    if familiar.SubType == FRIEND_SUBTYPE and collider:ToPlayer() or collider:ToNPC() and collider:ToNPC():IsEnemy() and collider:ToNPC():IsActiveEnemy() then
        familiar.Velocity = (familiar.Velocity + (familiar.Position - collider.Position):Normalized() * 3.5) * PUSH_POWER
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_FAMILIAR_COLLISION, postFamiliarCollision, FRIEND_VARIANT)

---@param familiar EntityFamiliar
local function familiarUpdate(_, familiar)
    if familiar.SubType == FRIEND_SUBTYPE then
        local sprite = familiar:GetSprite()
        local data = familiar:GetData()
        local pathfinder = familiar:GetPathFinder()
        local squaredLength = familiar.Velocity:LengthSquared()
        local room = Game():GetRoom()

        if familiar.EntityCollisionClass ~= EntityCollisionClass.ENTCOLL_ALL then
            familiar.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
        end

        if familiar.GridCollisionClass ~= EntityGridCollisionClass.GRIDCOLL_GROUND then
            familiar.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
        end
        
        --IDLE ANIMATIONS START
        if squaredLength < 0.01 and not sprite:IsPlaying(BODY_IDLE) then
            sprite:Play(BODY_IDLE, true)
        end
        if squaredLength < 0.01 and not sprite:IsOverlayPlaying(HEAD_IDLE) then
            sprite:PlayOverlay(HEAD_IDLE, true)
        end
        --IDLE ANIMATIONS END

        --WALKING ANIMATION HANDLING START

        local normalizedVelocity = familiar.Velocity:Normalized()

        if squaredLength >= 0.01 or data.Resouled_Target or data.Resouled_GridTarget then
            if normalizedVelocity.X < 0.75 and normalizedVelocity.X > -0.75 and normalizedVelocity.Y < 0 then
                if not sprite:IsPlaying(BODY_UP) then
                    sprite:Play(BODY_UP, true)
                end
                if not data.Resouled_Target and not data.Resouled_GridTarget then
                    if not sprite:IsOverlayPlaying(HEAD_UP) then
                        sprite:PlayOverlay(HEAD_UP)
                    end
                end
            elseif normalizedVelocity.Y > -0.75 and normalizedVelocity.Y < 0.75 and normalizedVelocity.X < 0 then
                if not sprite:IsPlaying(BODY_LEFT) then
                    sprite:Play(BODY_LEFT, true)
                end
                if not data.Resouled_Target and not data.Resouled_GridTarget then
                    if not sprite:IsOverlayPlaying(HEAD_LEFT) then
                        sprite:PlayOverlay(HEAD_LEFT)
                    end
                end
            elseif normalizedVelocity.X < 0.75 and normalizedVelocity.X > -0.75 and normalizedVelocity.Y > 0 then
                if not sprite:IsPlaying(BODY_DOWN) then
                    sprite:Play(BODY_DOWN, true)
                end
                if not data.Resouled_Target and not data.Resouled_GridTarget then
                    if not sprite:IsOverlayPlaying(HEAD_DOWN) then
                        sprite:PlayOverlay(HEAD_DOWN)
                    end
                end
            elseif normalizedVelocity.Y > -0.75 and normalizedVelocity.Y < 0.75 and normalizedVelocity.X > 0 then
                if not sprite:IsPlaying(BODY_RIGHT) then
                    sprite:Play(BODY_RIGHT, true)
                end
                if not data.Resouled_Target and not data.Resouled_GridTarget then
                    if not sprite:IsOverlayPlaying(HEAD_RIGHT) then
                        sprite:PlayOverlay(HEAD_RIGHT)
                    end
                end
            end

            if data.Resouled_Target or data.Resouled_GridTarget then
                local distanceFromTarget = nil
                if data.Resouled_Target then
                    distanceFromTarget = familiar.Position:Distance(data.Resouled_Target.Position)
                elseif not data.Resouled_Target and data.Resouled_GridTarget then
                    distanceFromTarget = familiar.Position:Distance(data.Resouled_GridTarget.Position)
                end
                if distanceFromTarget <= FOLLOW_ORBIT + (FOLLOW_ORBIT/10) then
                    local vectorTargetToEnemyNormalized = Vector.Zero
                    if data.Resouled_Target then
                        vectorTargetToEnemyNormalized = (data.Resouled_Target.Position - familiar.Position):Normalized()
                    elseif not data.Resouled_Target and data.Resouled_GridTarget then
                        vectorTargetToEnemyNormalized = (data.Resouled_GridTarget.Position - familiar.Position):Normalized()
                    end
                    if vectorTargetToEnemyNormalized.X < 0.75 and vectorTargetToEnemyNormalized.X > -0.75 and vectorTargetToEnemyNormalized.Y < 0 and not sprite:IsOverlayPlaying(HEAD_UP..SHOOT) then
                        if not sprite:IsOverlayPlaying(HEAD_UP) then
                            sprite:PlayOverlay(HEAD_UP)
                        end
                    elseif vectorTargetToEnemyNormalized.Y > -0.75 and vectorTargetToEnemyNormalized.Y < 0.75 and vectorTargetToEnemyNormalized.X < 0 and not sprite:IsOverlayPlaying(HEAD_LEFT..SHOOT) then
                        if not sprite:IsOverlayPlaying(HEAD_LEFT) then
                            sprite:PlayOverlay(HEAD_LEFT)
                        end
                    elseif vectorTargetToEnemyNormalized.X < 0.75 and vectorTargetToEnemyNormalized.X > -0.75 and vectorTargetToEnemyNormalized.Y > 0 and not sprite:IsOverlayPlaying(HEAD_DOWN..SHOOT) then
                        if not sprite:IsOverlayPlaying(HEAD_DOWN) then
                            sprite:PlayOverlay(HEAD_DOWN)
                        end
                    elseif vectorTargetToEnemyNormalized.Y > -0.75 and vectorTargetToEnemyNormalized.Y < 0.75 and vectorTargetToEnemyNormalized.X > 0 and not sprite:IsOverlayPlaying(HEAD_RIGHT..SHOOT) then
                        if not sprite:IsOverlayPlaying(HEAD_RIGHT) then
                            sprite:PlayOverlay(HEAD_RIGHT)
                        end
                    end
                else
                    if normalizedVelocity.X < 0.75 and normalizedVelocity.X > -0.75 and normalizedVelocity.Y < 0 then
                        if not sprite:IsOverlayPlaying(HEAD_UP) then
                            sprite:PlayOverlay(HEAD_UP)
                        end
                    elseif normalizedVelocity.Y > -0.75 and normalizedVelocity.Y < 0.75 and normalizedVelocity.X < 0 then
                        if not sprite:IsOverlayPlaying(HEAD_LEFT) then
                            sprite:PlayOverlay(HEAD_LEFT)
                        end
                    elseif normalizedVelocity.X < 0.75 and normalizedVelocity.X > -0.75 and normalizedVelocity.Y > 0 then
                        if not sprite:IsOverlayPlaying(HEAD_DOWN) then
                            sprite:PlayOverlay(HEAD_DOWN)
                        end
                    elseif normalizedVelocity.Y > -0.75 and normalizedVelocity.Y < 0.75 and normalizedVelocity.X > 0 then
                        if not sprite:IsOverlayPlaying(HEAD_RIGHT) then
                            sprite:PlayOverlay(HEAD_RIGHT)
                        end
                    end
                end
            end
        end

        --WALKING ANIMATION HANDLING END

        local enemyPresent = false
        ---@type EntityRef | nil
        local closestPickup = nil
        ---@type EntityNPC | nil
        local closestEnemy = nil
        ---@param entity Entity
        Resouled.Iterators:IterateOverRoomEntities(function(entity)
            local player = Resouled:TryFindPlayerSpawner(familiar)
            local npc = entity:ToNPC()
            if npc and npc:IsEnemy() and npc:IsActiveEnemy() and npc:IsVulnerableEnemy() then
                enemyPresent = true
                if not closestEnemy then
                    closestEnemy = npc
                elseif npc.Position:Distance(familiar.Position) < closestEnemy.Position:Distance(familiar.Position) then
                    closestEnemy = npc
                end
            end
            
            if entity.Type == EntityType.ENTITY_FAMILIAR and entity.Variant == FRIEND_VARIANT and entity.SubType == FRIEND_SUBTYPE and entity.Position:Distance(familiar.Position) < OTHER_FRIEND_AVOID_RANGE then
                familiar.Velocity = familiar.Velocity + (familiar.Position - entity.Position):Normalized() * OTHER_FRIEND_AVOID_SPEED
            end
            
            local closestProjectile = nil
            local projectile = entity:ToProjectile()
            if projectile then
                local projectileToFamiliarDistance = projectile.Position:Distance(familiar.Position)
                if projectileToFamiliarDistance < PROJECTILE_AVOID_RANGE then
                    if closestProjectile == nil then
                        closestProjectile = projectile
                    elseif projectileToFamiliarDistance < closestProjectile.Position:Distance(familiar.Position) then
                        closestProjectile = projectile
                    end
                end
            end
            
            if closestProjectile then
                familiar.Velocity = familiar.Velocity + (familiar.Position - closestProjectile.Position):Normalized() * PROJECTILE_AVOID_SPEED
            end
            
            local bomb = entity:ToBomb()
            if bomb then
                if bomb.Position:Distance(familiar.Position) <= BOMB_AVOID_RANGE then
                    if not data.Resouled_AvoidBomb then
                        data.Resouled_AvoidBomb = bomb
                    elseif data.Resouled_AvoidBomb and bomb.Position:Distance(familiar.Position) < data.Resouled_AvoidBomb.Position:Distance(familiar.Position) then
                        data.Resouled_AvoidBomb = bomb
                    end
                end
            end
            
            local pickup = entity:ToPickup()
            if pickup then
                if player and player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
                    local pickupData = pickup:GetData()
                    if not pickupData.Resouled_RemoveAfterAnim then
                        if pathfinder:HasPathToPos(pickup.Position, true) then
                            local variant = pickup.Variant
                            local subType = pickup.SubType
                            if not pickup:IsShopItem() then
                                if (variant == PickupVariant.PICKUP_BOMB and subType ~= (BombSubType.BOMB_GIGA or BombSubType.BOMB_GOLDENTROLL or BombSubType.BOMB_SUPERTROLL or BombSubType.BOMB_TROLL) and player:GetNumBombs() < player:GetMaxBombs()) or
                                (variant == PickupVariant.PICKUP_COIN and subType ~= (CoinSubType.COIN_STICKYNICKEL or CoinSubType.COIN_LUCKYPENNY) and player:GetNumCoins() < player:GetMaxCoins()) or
                                (variant == PickupVariant.PICKUP_KEY and subType ~= KeySubType.KEY_CHARGED and player:GetNumKeys() < player:GetMaxKeys()) or
                                (variant == PickupVariant.PICKUP_CHEST and subType ~= (ChestSubType.CHEST_OPENED)) then
                                    if not closestPickup then
                                        closestPickup = EntityRef(pickup)
                                    elseif closestPickup and pickup.Position:Distance(familiar.Position) < closestPickup.Position:Distance(familiar.Position) then
                                        closestPickup = EntityRef(pickup)
                                    end
                                end
                            end
                        end
                    end
                end

                if familiar.Position:Distance(pickup.Position) < PICKUP_PICK_UP_RANGE then
                    pickup.Velocity = (pickup.Velocity + (pickup.Position - familiar.Position):Normalized() * 1.5) * PUSH_POWER
                end
            end
        end)
            
        --RANDOM WALKING IF NOT ENEMIES START
        if not enemyPresent and not data.Resouled_TargetPos and not data.Resouled_GridTarget and not data.Resouled_PickupTarget and not data.Resouled_BombTarget then
            familiar.Velocity = familiar.Velocity/1.5
            local randomFloat = math.random()
            if randomFloat < START_WANDERING_AROUND_CHANCE then
                data.Resouled_TargetPos = Isaac.GetFreeNearPosition(Isaac.GetRandomPosition(), 0)
            end
        end
        
        if data.Resouled_TargetPos then
            pathfinder:FindGridPath(data.Resouled_TargetPos, WALK_SPEED, 1, true)

            if familiar.Position:Distance(data.Resouled_TargetPos) < 10 then
                data.Resouled_TargetPos = nil
            end
        end
        --RANDOM WALKING IF NOT ENEMIES END

        --WALKING IF ENEMIES PRESENT START
        if enemyPresent then
            if not data.Resouled_Target then
                if closestEnemy then
                    data.Resouled_Target = closestEnemy
                end
            end

            if closestEnemy then
                if closestEnemy.Position:Distance(familiar.Position) < data.Resouled_Target.Position:Distance(familiar.Position) then
                    data.Resouled_Target = closestEnemy
                end
            end
        end

        if data.Resouled_Target then
            if data.Resouled_TargetPos then
                data.Resouled_TargetPos = nil
            end
            local pathfinderCheck = room:CheckLine(familiar.Position, data.Resouled_Target.Position + (familiar.Position - data.Resouled_Target.Position):Normalized() * 10, LineCheckMode.PROJECTILE)
            local distanceFromTarget = familiar.Position:Distance(data.Resouled_Target.Position)
            if distanceFromTarget >= FOLLOW_ORBIT then
                pathfinder:FindGridPath(data.Resouled_Target.Position, WALK_SPEED, 1, true)
            elseif distanceFromTarget < FOLLOW_ORBIT and pathfinderCheck then
                familiar.Velocity = familiar.Velocity + ((familiar.Position - data.Resouled_Target.Position):Normalized() * AVOID_SPEED)
            end
            
            if distanceFromTarget <= FOLLOW_ORBIT + (FOLLOW_ORBIT/10) then
                if not data.Resouled_FireCooldown then
                    if pathfinderCheck then
                        ---@type EntityTear
                        local tear = Game():Spawn(EntityType.ENTITY_TEAR, TearVariant.METALLIC, familiar.Position, (data.Resouled_Target.Position - familiar.Position):Normalized() * TEAR_SPEED, familiar, 0, familiar.InitSeed)
                        local player = Resouled:TryFindPlayerSpawner(familiar)
                        if player and player:HasTrinket(TrinketType.TRINKET_BABY_BENDER) then
                            tear:AddTearFlags(TearFlags.TEAR_HOMING)
                        end
                        tear:SetColor(Color(0.1, 0.1, 0.1), 99999, 1, false, false)
                        data.Resouled_FireCooldown = SHOOT_COOLDOWN
                        sprite:PlayOverlay(sprite:GetOverlayAnimation()..SHOOT, true)
                    else
                        pathfinder:FindGridPath(data.Resouled_Target.Position, WALK_SPEED, 1, true)
                    end
                end
            end

            if not data.Resouled_Target:IsVulnerableEnemy() then
                data.Resouled_Target = nil
            end
            
            if data.Resouled_Target and data.Resouled_Target.HitPoints <= 0 then
                data.Resouled_Target = nil
            end
        end


        local randomFloat = math.random()
        if not data.Resouled_Target and not data.Resouled_GridTarget and randomFloat < POOP_BREAK_ACTION_CHANCE then
            ---@type GridEntity | nil
            local closestPoop = nil
            ---@type GridEntity | nil
            local closestTintedRock = nil
            ---@param gridEntity GridEntity
            Resouled.Iterators:IterateOverGrid(function(gridEntity)
                if pathfinder:HasPathToPos(gridEntity.Position, false) then
                    if gridEntity:GetType() == GridEntityType.GRID_POOP then
                        if gridEntity.State ~= 1000 then
                            if not closestPoop then
                                closestPoop = gridEntity
                            elseif gridEntity.Position:Distance(familiar.Position) < closestPoop.Position:Distance(familiar.Position) then
                                closestPoop = gridEntity
                            end
                        end
                    end

                    local player = Resouled:TryFindPlayerSpawner(familiar)

                    if player and player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) and gridEntity:GetType() == GridEntityType.GRID_ROCKT and gridEntity.State == 1 then
                        if not closestTintedRock then
                            closestTintedRock = gridEntity
                        elseif gridEntity.Position:Distance(familiar.Position) < closestTintedRock.Position:Distance(familiar.Position) then
                            closestTintedRock = gridEntity
                        end
                    end
                end
            end)
            
            if closestPoop then
                data.Resouled_GridTarget = closestPoop
            end

            if closestTintedRock and not closestPoop and not data.Resouled_BombCooldown then
                data.Resouled_BombTarget = closestTintedRock
            end
        end


        if data.Resouled_GridTarget and not data.Resouled_Target then
            if data.Resouled_TargetPos then
                data.Resouled_TargetPos = nil
            end
            local distanceFromTarget = familiar.Position:Distance(data.Resouled_GridTarget.Position)
            local pos = Isaac.GetFreeNearPosition(data.Resouled_GridTarget.Position, 0)
            if data.Resouled_GridTarget.State ~= 1000 then
                if pathfinder:HasPathToPos(pos, true) then
                    pathfinder:FindGridPath(pos, WALK_SPEED, 1, true)
                    if distanceFromTarget <= FOLLOW_ORBIT + (FOLLOW_ORBIT/10) then
                        if not data.Resouled_FireCooldown then
                            if room:CheckLine(familiar.Position, data.Resouled_GridTarget.Position + (familiar.Position - data.Resouled_GridTarget.Position):Normalized() * 35, LineCheckMode.PROJECTILE) then
                                ---@type EntityTear
                                local tear = Game():Spawn(EntityType.ENTITY_TEAR, TearVariant.METALLIC, familiar.Position, (data.Resouled_GridTarget.Position - familiar.Position):Normalized() * TEAR_SPEED, familiar, 0, familiar.InitSeed)
                                local player = Resouled:TryFindPlayerSpawner(familiar)
                                if player and player:HasTrinket(TrinketType.TRINKET_BABY_BENDER) then
                                    tear:AddTearFlags(TearFlags.TEAR_HOMING)
                                end
                                tear:SetColor(Color(0.1, 0.1, 0.1), 99999, 1, false, false)
                                data.Resouled_FireCooldown = SHOOT_COOLDOWN
                                sprite:PlayOverlay(sprite:GetOverlayAnimation()..SHOOT, true)
                            else
                                pathfinder:FindGridPath(pos, WALK_SPEED, 1, true)
                            end
                        end
                    end
                else
                    data.Resouled_GridTarget = nil
                end
            else
                data.Resouled_GridTarget = nil
            end
        end

        if closestPickup and not data.Resouled_GridTarget and not data.Resouled_Target then
            data.Resouled_PickupTarget = closestPickup
        end

        if data.Resouled_PickupTarget and not data.Resouled_BombTarget then
            if data.Resouled_TargetPos then
                data.Resouled_TargetPos = nil
            end

            if data.Resouled_PickupTarget.Entity then
                
                ---@type EntityPickup
                local pickup = data.Resouled_PickupTarget.Entity:ToPickup()
                
                if pickup:GetSprite():GetAnimation() == "Idle" then
                    
                    pathfinder:FindGridPath(pickup.Position, WALK_SPEED, 1, false)
                    
                    if familiar.Position:Distance(pickup.Position) < PICKUP_PICK_UP_RANGE then
                        local player = Resouled:TryFindPlayerSpawner(familiar)
                        if player then
                            local variant = pickup.Variant
                            local subType = pickup.SubType
                            if variant ~= PickupVariant.PICKUP_CHEST then
                                if variant == PickupVariant.PICKUP_COIN then
                                    local value = pickup:GetCoinValue()
                                    player:AddCoins(value)
                                end
                                if variant == PickupVariant.PICKUP_BOMB then
                                    if subType == BombSubType.BOMB_NORMAL then
                                        player:AddBombs(1)
                                    elseif subType == BombSubType.BOMB_DOUBLEPACK then
                                        player:AddBombs(2)
                                    elseif subType == BombSubType.BOMB_GOLDEN then
                                        player:AddGoldenBomb()
                                    end
                                end
                                if variant == PickupVariant.PICKUP_KEY then
                                    if subType == KeySubType.KEY_NORMAL then
                                        player:AddKeys(1)
                                    elseif subType == KeySubType.KEY_DOUBLEPACK then
                                        player:AddKeys(2)
                                    elseif subType == KeySubType.KEY_GOLDEN then
                                        player:AddGoldenKey()
                                    end
                                end
                                pickup:PlayPickupSound()
                                pickup:GetSprite():Play("Collect", true)
                                pickup:GetData().Resouled_RemoveAfterAnim = true
                                data.Resouled_PickupTarget = nil
                            else
                                pickup:TryOpenChest()
                                data.Resouled_PickupTarget = nil
                            end
                        end
                    end
                end

                if pickup:CanReroll() == false then
                    data.Resouled_PickupTarget = nil
                end

                if data.Resouled_PickupTarget then
                    if pickup.Variant == PickupVariant.PICKUP_CHEST and pickup:GetLootList()[0] == nil then
                        data.Resouled_PickupTarget = nil
                    end
                end
            else
                data.Resouled_PickupTarget = nil
            end
        end

        if data.Resouled_BombTarget and not data.Resouled_GridTarget and not data.Resouled_Target then
            if data.Resouled_TargetPos then
                data.Resouled_TargetPos = nil
            end
            local bombPos = Isaac.GetFreeNearPosition(data.Resouled_BombTarget.Position, 0)
            if pathfinder:HasPathToPos(bombPos, true) then
                pathfinder:FindGridPath(bombPos, WALK_SPEED, 1, true)
                if familiar.Position:Distance(bombPos) < BOMB_PLACEMENT_RANGE then
                    Game():Spawn(EntityType.ENTITY_BOMB, BombVariant.BOMB_NORMAL, bombPos, Vector.Zero, familiar, 0, familiar.InitSeed)
                    SFXManager():Play(SoundEffect.SOUND_FETUS_LAND)
                    data.Resouled_BombTarget = nil
                    data.Resouled_BombCooldown = BOMB_COOLDOWN
                end
            else
                data.Resouled_BombTarget = nil
            end
        end

        if data.Resouled_AvoidBomb then
            data.Resouled_TargetPos = nil
            data.Resouled_Target = nil
            data.Resouled_GridTarget = nil
            data.Resouled_PickupTarget = nil
            data.Resouled_BombTarget = nil

            familiar.Velocity = familiar.Velocity + (familiar.Position - data.Resouled_AvoidBomb.Position):Normalized() * BOMB_AVOID_SPEED

            if data.Resouled_AvoidBomb.Position:Distance(familiar.Position) > BOMB_AVOID_RANGE then
                data.Resouled_AvoidBomb = nil
            end
        end

        --WALKING IF ENEMIES PRESENT END

        if data.Resouled_FireCooldown then
            data.Resouled_FireCooldown = data.Resouled_FireCooldown - 1
    
            if data.Resouled_FireCooldown == 0 then
                data.Resouled_FireCooldown = nil
            end
        end

        if data.Resouled_BombCooldown then
            data.Resouled_BombCooldown = data.Resouled_BombCooldown - 1
            if data.Resouled_BombCooldown <= 0 then
                data.Resouled_BombCooldown = nil
            end
        end

        familiar.Velocity = familiar.Velocity * VELOCITY_LOSS_PER_UPDATE
    end
end
Resouled:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, familiarUpdate, FRIEND_VARIANT)

---@param npc EntityNPC
local function postNpcDeath(_, npc)
    ---@param entity Entity
    Resouled.Iterators:IterateOverRoomEntities(function(entity)
        local familiar = entity:ToFamiliar()
        if familiar then
            if familiar.Variant == FRIEND_VARIANT and familiar.SubType == FRIEND_SUBTYPE then
                local data = familiar:GetData()
                if data.Resouled_Target then
                    if data.Resouled_Target.Index == npc.Index then
                        data.Resouled_Target = nil
                    end
                end
            end
        end
    end)
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, postNpcDeath)

---@param spikes GridEntitySpikes
local function gridSpikesUpdate(_, spikes)
    ---@param entity Entity
    Resouled.Iterators:IterateOverRoomEntities(function(entity)
        local familiar = entity:ToFamiliar()
        if familiar and familiar.Variant == FRIEND_VARIANT and familiar.SubType == FRIEND_SUBTYPE and familiar.Position:Distance(spikes.Position) < GRID_AVOID_RANGE then
            familiar.Velocity = familiar.Velocity + (familiar.Position - spikes.Position):Normalized() * GRID_AVOID_SPEED
        end
    end)
end
Resouled:AddCallback(ModCallbacks.MC_POST_GRID_ENTITY_SPIKES_UPDATE, gridSpikesUpdate)

---@param fire GridEntityFire
local function gridFireplaceUpdate(_, fire)
    ---@param entity Entity
    Resouled.Iterators:IterateOverRoomEntities(function(entity)
        local familiar = entity:ToFamiliar()
        if familiar and familiar.Variant == FRIEND_VARIANT and familiar.SubType == FRIEND_SUBTYPE and familiar.Position:Distance(fire.Position) < GRID_AVOID_RANGE then
            familiar.Velocity = familiar.Velocity + (familiar.Position - fire.Position):Normalized() * GRID_AVOID_SPEED
        end
    end)
end
Resouled:AddCallback(ModCallbacks.MC_POST_GRID_ENTITY_FIRE_UPDATE, gridFireplaceUpdate)

local function postNewRoom()
    ---@param entity Entity
    Resouled.Iterators:IterateOverRoomEntities(function(entity)
        local familiar = entity:ToFamiliar()
        if familiar and familiar.Variant == FRIEND_VARIANT and familiar.SubType == FRIEND_SUBTYPE then
            local data = familiar:GetData()
            if data.Resouled_Target then
                data.Resouled_Target = nil
            end
            if data.Resouled_GridTarget then
                data.Resouled_GridTarget = nil
            end
            if data.Resouled_TargetPos then
                data.Resouled_TargetPos = nil
            end
            if data.Resouled_PickupTarget then
                data.Resouled_PickupTarget = nil
            end
            if data.Resouled_BombTarget then
                data.Resouled_BombTarget = nil
            end
            if data.Resouled_AvoidBomb then
                data.Resouled_AvoidBomb = nil
            end
            data.Resouled_TargetPos = Isaac.GetFreeNearPosition(Isaac.GetRandomPosition(), 0)
        end
    end)
end
Resouled:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, postNewRoom)

---@param poop GridEntityPoop
local function postPoopUpdate(_, poop)
    if poop.State == 1000 then
        ---@param entity Entity
        Resouled.Iterators:IterateOverRoomEntities(function(entity)
            local familiar = entity:ToFamiliar()
            if familiar and familiar.Variant == FRIEND_VARIANT and familiar.SubType == FRIEND_SUBTYPE then
                local data = familiar:GetData()
                if data.Resouled_GridTarget then
                    if data.Resouled_GridTarget.Position.X == poop.Position.X and data.Resouled_GridTarget.Position.Y == poop.Position.Y then
                        data.Resouled_GridTarget = nil
                    end
                end
            end
        end)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_GRID_ENTITY_POOP_UPDATE, postPoopUpdate)

---@param pickup EntityPickup
local function prePickupUpdate(_, pickup)
    local data = pickup:GetData()
    if data.Resouled_RemoveAfterAnim then
        local sprite = pickup:GetSprite()
        if sprite:IsFinished("Collect") then
            pickup:Remove()
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_PICKUP_UPDATE, prePickupUpdate)