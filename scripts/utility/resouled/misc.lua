function Resouled:Log(...)
    print("[Resouled]", ...)
end

function Resouled:LogError(...)
    print("[Resouled ERROR]", ...)
end

--- Spawns a random chaos pool item of the specified quality at specified position
---@param quality integer
---@param rng RNG
---@param position Vector
---@param spawner? Entity @Entity that spawned the item
function Resouled:SpawnChaosItemOfQuality(quality, rng, position, spawner)
    local itemConfig = Isaac.GetItemConfig()
    local itemPool = Game():GetItemPool()
    local validItems = {}
    
    for i = 1, #itemConfig:GetCollectibles() do
        local item = itemConfig:GetCollectible(i)
        if item and item.Quality == quality and not item.Hidden and item:IsAvailable() and not item:HasTags(ItemConfig.TAG_QUEST) then
            table.insert(validItems, i)
        end
    end
    
    ::reroll::

    if #validItems > 0 then
        local randomItem = validItems[rng:RandomInt(#validItems) + 1]
        
        if not itemPool:RemoveCollectible(randomItem) then
            --remove raindomItem from valiudItems
            for i = 1, #validItems do
                if validItems[i] == randomItem then
                    table.remove(validItems, i)
                    break
                end
            end
            goto reroll
        end

        local entity = Game():Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, Isaac.GetFreeNearPosition(position, 60), Vector.Zero, spawner, randomItem, rng:GetSeed())
        rng:Next()
        return entity

    end
    return nil
end

---@param pool ItemPoolType
---@param rng RNG
---@param position Vector
---@param spawner? Entity
---@param defaultItem? CollectibleType @Item that will spawn if pool is exhausted, defaults to CollectibleType.COLLECTIBLE_BREAKFAST
---@return EntityPickup | nil @Item that was spawned or `nil` if no item was spawned
function Resouled:SpawnItemFromPool(pool, rng, position, spawner, defaultItem)
    local game = Game()
    local DEFAULT_ITEM = defaultItem or CollectibleType.COLLECTIBLE_BREAKFAST
    local itemsFromTargetPool = Game():GetItemPool():GetCollectiblesFromPool(pool)
    local validItems = {}
    for i = 1, #itemsFromTargetPool do
        local id = itemsFromTargetPool[i].itemID
        if not Isaac.GetItemConfig():GetCollectible(id):HasTags(ItemConfig.TAG_QUEST) and Game():GetItemPool():CanSpawnCollectible(id, false) then
            table.insert(validItems, id)
        end
    end
    
    local itemID = #validItems > 0 and validItems[rng:RandomInt(#validItems) + 1] or DEFAULT_ITEM

    game:Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, position, Vector.Zero, spawner, 0, Resouled:NewSeed())
    game:GetItemPool():RemoveCollectible(itemID)
    local newItem = game:Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, position, Vector.Zero, spawner, itemID, rng:GetSeed())
    return newItem and newItem:ToPickup() or nil -- return pickup if spawned, nil otherwise
end

function Resouled:GetRoomPickupsValue()
    local roomValue = 0
    ---@param entity Entity
    Resouled.Iterators:IterateOverRoomEntities(function(entity)
        local pickup = entity:ToPickup()
        if pickup and pickup:IsShopItem() and pickup.Price > 0 then
            roomValue = roomValue + pickup.Price
        end
    end)
    return roomValue
end

--- Tries to morph an NPC into a different type, variant and subtype based on its drop RNG.
---@param npc EntityNPC
---@param morphChance number
---@param type EntityType
---@param variant integer
---@param subtype integer
function Resouled:TryEnemyMorph(npc, morphChance, type, variant, subtype)
    local rng = RNG()
    rng:SetSeed(npc:GetDropRNG():GetSeed(), 0)
    if npc.Type == type and npc:IsActiveEnemy() and rng:RandomFloat() < morphChance then
        npc:Morph(type, variant, subtype, npc:GetChampionColorIdx())
    end
end

---@param action ButtonAction
function Resouled:IsAnyonePressingAction(action)
    local isPressed = false
    ---@param player EntityPlayer
    Resouled.Iterators:IterateOverPlayers(function(player)
        if Input.IsActionPressed(action, player.ControllerIndex) then
            isPressed = true
        end
    end)
    return isPressed
end

---@param player EntityPlayer
---@return boolean
function Resouled:IsPlayingPickupAnimation(player)
    local sprite = player:GetSprite()
    local animationName = sprite:GetAnimation()
    return animationName == "PickupWalkUp"
    or animationName == "PickupWalkDown"
    or animationName == "PickupWalkLeft"
    or animationName == "PickupWalkRight"
end

---@return integer
function Resouled:NewSeed()
    local seed = 0
    while seed == 0 do
        seed = Random()
    end
    return seed
end

---@param position Vector
---@param velocity Vector
---@param spriteOffset? Vector
---@param spawner Entity
function Resouled:SpawnPaperTear(position, velocity, spriteOffset, spawner)
    local tear = Game():Spawn(Isaac.GetEntityTypeByName("Blank Canvas Tear"), Isaac.GetEntityVariantByName("Blank Canvas Tear"), position, velocity, spawner, Isaac.GetEntitySubTypeByName("Blank Canvas Tear"), spawner.InitSeed)
    if spriteOffset then
        tear.SpriteOffset = spriteOffset
    end
    return tear
end

---@param entity Entity
---@return EntityPlayer | nil
function Resouled:TryFindPlayerSpawner(entity)
    while entity ~= nil do
        if entity:ToPlayer() then
            return entity:ToPlayer()
        else
            entity = entity.SpawnerEntity
        end
    end

    return nil
end

---@param entity Entity
---@return EntityPlayer | nil
function Resouled:TryFindPlayerSpawnerIfEntityFamiliar(entity)
    local familiar = false
    while entity ~= nil do
        if entity:ToFamiliar() then
            familiar = true
        end
        if entity:ToPlayer() and familiar then
            return entity:ToPlayer()
        else
            entity = entity.SpawnerEntity
        end
    end

    return nil
end

---@param roomIndex1 integer
---@param roomIndex2 integer
function Resouled:GetGridRoomDistance(roomIndex1, roomIndex2)
    return math.abs(roomIndex1//13 - roomIndex2//13) + math.abs(roomIndex1%13 - roomIndex2%13)
end

---@param rng RNG
---@param pool? ItemPoolType
---@param defaultItem? CollectibleType @Item that will be chosen if pool is exhausted, defaults to CollectibleType.COLLECTIBLE_BREAKFAST
---@return CollectibleType
function Resouled:ChooseItemFromPool(rng, pool, defaultItem)
    local game = Game()
    local DEFAULT_ITEM = defaultItem or CollectibleType.COLLECTIBLE_BREAKFAST
    pool = pool or game:GetRoom():GetItemPool(game:GetRoom():GetAwardSeed())
    local itemsFromTargetPool = game:GetItemPool():GetCollectiblesFromPool(pool)
    local validItems = {}
    for i = 1, #itemsFromTargetPool do
        local id = itemsFromTargetPool[i].itemID
        if not Isaac.GetItemConfig():GetCollectible(id):HasTags(ItemConfig.TAG_QUEST) and game:GetItemPool():CanSpawnCollectible(id, false) then
            table.insert(validItems, id)
        end
    end
    
    local itemID = #validItems > 0 and validItems[rng:RandomInt(#validItems) + 1] or DEFAULT_ITEM

    return itemID -- return pickup if spawned, nil otherwise
end

---@param pool ItemPoolType
---@param rng RNG
---@param quality? integer
---@return integer
function Resouled:GetRandomItemFromPool(pool, rng, quality)
    local game = Game()
    local itemsFromTargetPool = Game():GetItemPool():GetCollectiblesFromPool(pool)
    local validItems = {}
    for i = 1, #itemsFromTargetPool do
        local id = itemsFromTargetPool[i].itemID
        if not Isaac.GetItemConfig():GetCollectible(id):HasTags(ItemConfig.TAG_QUEST) and Game():GetItemPool():CanSpawnCollectible(id, false) then
            if quality then
                if Isaac.GetItemConfig():GetCollectible(id).Quality == quality then
                    table.insert(validItems, id)
                else end
            else
                table.insert(validItems, id)
            end
        end
    end
    
    local itemID = #validItems > 0 and validItems[rng:RandomInt(#validItems) + 1]

    return itemID or CollectibleType.COLLECTIBLE_BREAKFAST
end

---@param gridCollisionClass GridCollisionClass
---@param position Vector
---@param amount integer
---@param startOffset number
---@param minOffsetLoss integer
---@param maxOffsetloss integer
---@param weight number
---@param bounciness number
---@param slipperiness number
---@param size number
---@param maxSizeVariety integer
---@param speed number
---@param rotation? integer
---@param maxSpread? integer
---@param straightPath boolean
---@param variant integer
---@param subType? integer
function Resouled:SpawnRealisticParticles(gridCollisionClass, position, amount, startOffset, minOffsetLoss, maxOffsetloss, weight, bounciness, slipperiness, size, maxSizeVariety, speed, rotation, maxSpread, straightPath, variant, subType)
    for i = 1, amount do
        local newSpeed = speed
        ---@type EntityEffect
        local particle = Game():Spawn(EntityType.ENTITY_EFFECT, variant, position, Vector.Zero, nil, subType or 0, Game():GetRoom():GetAwardSeed()):ToEffect()
        local data = particle:GetData()

        particle.GridCollisionClass = gridCollisionClass
        particle.DepthOffset = -1000 - i

        newSpeed = newSpeed * (math.random(20, 100)/100) * 1.5
        
        if rotation then
            if not maxSpread then
                particle.Velocity = (Vector(0, 1) * newSpeed):Rotated(rotation - 90)
            else
                particle.Velocity = (Vector(0, 1) * newSpeed):Rotated(rotation - 90 + math.random(-maxSpread, maxSpread))
            end
        else
            particle.Velocity = (Vector(0, 1) * newSpeed):Rotated(math.random(0, 360))
        end
        particle.Scale = (size | 1) * (1 + math.random(-maxSizeVariety, maxSizeVariety)/100)
        particle.Size = particle.Size * particle.Scale
            
        data.Resouled_RealisticParticle = {
            Weight = weight * particle.Scale,
            Bounciness = bounciness / particle.Scale,
            Slipperiness = slipperiness,
            RotationSpeed = newSpeed / particle.Scale,
            RotationDirection = math.random(2),
            Offset = startOffset,
            OffsetToLose = math.random(-minOffsetLoss, maxOffsetloss)/10,
            StraightPath = straightPath,
            BounceCount = 0,
        }
    end
end

---@param effect EntityEffect
Resouled:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, effect)
    local data = effect:GetData()
    if data.Resouled_RealisticParticle then
        if data.Resouled_RealisticParticle.Slipperiness > 1 then
            effect.Velocity = (effect.Velocity * data.Resouled_RealisticParticle.Slipperiness) * 0.85
        else
            effect.Velocity = (effect.Velocity) * 0.85
        end
    end
end)

---@param effect EntityEffect
Resouled:AddCallback(ModCallbacks.MC_PRE_EFFECT_RENDER, function(_, effect)
    local data = effect:GetData()
    if data.Resouled_RealisticParticle then
        if data.Resouled_RealisticParticle.Offset > 0 then
            if effect.Velocity:LengthSquared() > 0.001 then
                if data.Resouled_RealisticParticle.RotationDirection == 0 then
                    effect.SpriteRotation = (effect.SpriteRotation + data.Resouled_RealisticParticle.RotationSpeed)%360
                else
                    effect.SpriteRotation = (effect.SpriteRotation - data.Resouled_RealisticParticle.RotationSpeed)%360
                end
            end
                
            data.Resouled_RealisticParticle.Offset = data.Resouled_RealisticParticle.Offset - data.Resouled_RealisticParticle.OffsetToLose

            data.Resouled_RealisticParticle.OffsetToLose = data.Resouled_RealisticParticle.OffsetToLose + (data.Resouled_RealisticParticle.Weight/5)
        else
            data.Resouled_RealisticParticle.OffsetToLose = (-data.Resouled_RealisticParticle.OffsetToLose * data.Resouled_RealisticParticle.Bounciness) / (data.Resouled_RealisticParticle.BounceCount + 2)
            data.Resouled_RealisticParticle.BounceCount = data.Resouled_RealisticParticle.BounceCount + 1
            if data.Resouled_RealisticParticle.BounceCount > data.Resouled_RealisticParticle.Bounciness * 5 then
                data.Resouled_RealisticParticle.Offset = 0
            else
                data.Resouled_RealisticParticle.Offset = 0.0001
            end

            if not data.Resouled_RealisticParticle.StraightPath then
                effect.Velocity = effect.Velocity:Rotated(math.random(-30, 30))
            end

            if effect.Velocity:LengthSquared() > 0.001 then
                if data.Resouled_RealisticParticle.RotationDirection == 0 then
                    data.Resouled_RealisticParticle.RotationDirection = 1
                else
                    data.Resouled_RealisticParticle.RotationDirection = 0
                end
                
                data.Resouled_RealisticParticle.RotationSpeed = data.Resouled_RealisticParticle.RotationSpeed + math.random(-3, 3)
            end
        end

        return Vector(0, -data.Resouled_RealisticParticle.Offset)
    end
end)

---@param position Vector
---@param amount integer
function Resouled:SpawnPaperGore(position, amount)
    local weight = 1.2
    local bounciness = 0.25
    local slipperiness = 0.25
    Resouled:SpawnRealisticParticles(GridCollisionClass.COLLISION_SOLID, position, amount, 25, 30, 1, weight, bounciness, slipperiness, 1, 20, math.random(5, 15), nil, nil, false, Isaac.GetEntityVariantByName("Paper Gore Particle"), Isaac.GetEntitySubTypeByName("Paper Gore Particle"))
end

---@param bomb EntityBomb
function Resouled:GetEntitiesInBombBlastRadius(bomb)
    local entitiesInRadius = {}
    ---@param entity Entity
    Resouled.Iterators:IterateOverRoomEntities(function(entity)
        if entity.Position:Distance(bomb.Position) <= 87 * bomb.RadiusMultiplier then --87 is a constant for bomb radius
            table.insert(entitiesInRadius, entity)
        end
    end)
    return entitiesInRadius
end

---@param entity Entity
---@param bomb EntityBomb
function Resouled:IsInBombBlastRadius(entity, bomb)
    if entity.Position:Distance(bomb.Position) <= 87 * bomb.RadiusMultiplier then
        return true
    end
    return false
end

---@param entity1 Entity
---@param entity2 Entity
function Resouled:GetDistanceFromHitboxEdge(entity1, entity2)
    return entity1.Position:Distance(entity2.Position) - (entity1.Size + entity2.Size)
end