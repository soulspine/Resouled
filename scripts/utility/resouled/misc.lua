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

---@param item CollectibleType
---@param position Vector
function Resouled:SpawnItemDisappearEffect(item, position)
    local effect = Game():Spawn(EntityType.ENTITY_EFFECT, Isaac.GetEntityVariantByName("Disappear"), position, Vector.Zero, nil, Isaac.GetEntitySubTypeByName("Disappear"), Game():GetRoom():GetAwardSeed())
    effect:GetSprite():ReplaceSpritesheet(0, Isaac.GetItemConfig():GetCollectible(item).GfxFileName, true)
end

---@param entity Entity
---@param searchedType integer
---@param searchedVariant? integer
---@param searchedSubType? integer
function Resouled:TryFindSpecificSpawner(entity, searchedType, searchedVariant, searchedSubType)
    if searchedType and not searchedVariant and not searchedSubType then
        while entity ~= nil do
            if entity.Type == searchedType then
                return entity
            else
                entity = entity.SpawnerEntity
            end
        end
    elseif searchedType and searchedVariant and not searchedSubType then
        while entity ~= nil do
            if entity.Type == searchedType and entity.Variant == searchedVariant then
                return entity
            else
                entity = entity.SpawnerEntity
            end
        end
    elseif searchedType and searchedVariant and searchedSubType then
        while entity ~= nil do
            if entity.Type == searchedType and entity.Variant == searchedVariant and entity.SubType == searchedSubType then
                return entity
            else
                entity = entity.SpawnerEntity
            end
        end
    end
    return nil
end

---@param entity Entity
---@param step? integer
---@return EntityNPC | nil
function Resouled:TryFindNearestEnemyByFindInRadius(entity, step) -- Tries to find the nearest enemy by using Isaac.FindInRadius() (less accurate than Resouled:TryFindNearestEnemyByIteration(), more optimized)
    local STEP
    if step then
        if step <= 0 then
            return nil
        end
        STEP = step
    else
        STEP = 45
    end
    local x = 0
    local nearestEnemy = nil
    local bottomRightPos = Game():GetRoom():GetBottomRightPos()
    local highestX = math.abs(bottomRightPos.X) + math.abs(bottomRightPos.Y)

    while x <= highestX and not nearestEnemy do
        ---@type EntityNPC[]
        local entities = Isaac.FindInRadius(entity.Position, x, EntityPartition.ENEMY)
        ---@param npc EntityNPC
        for _, npc in ipairs(entities) do
            if npc and Resouled:IsValidEnemy(npc) then
                if not nearestEnemy then
                    nearestEnemy = npc
                else
                    if nearestEnemy.Position:Distance(entity.Position) > npc.Position:Distance(entity.Position) then
                        nearestEnemy = npc
                    end
                end
            end
        end
        x = x + STEP
    end

    return nearestEnemy
end

---@param entity Entity
---@return EntityNPC | nil
function Resouled:TryFindNearestEnemyByIteration(entity) -- Tries to find the nearest enemy by iteration (more accurate than Resouled:TryFindNearestEnemyByFindInRadius(), less optimized)
    local nearestEnemy = nil

    ---@param npc EntityNPC
    Resouled.Iterators:IterateOverRoomNpcs(function(npc)
        if npc.Index ~= entity.Index and Resouled:IsValidEnemy(npc) then
            if not nearestEnemy then
                nearestEnemy = npc
            else
                if nearestEnemy.Position:Distance(entity.Position) > npc.Position:Distance(entity.Position) then
                    nearestEnemy = npc
                end
            end
        end
    end)

    return nearestEnemy
end

---@param variant integer
---@param subtype? integer
---@param speed number
---@param speedUpwards number
---@param maxRotationDownwards integer
---@param maxRotationUpwards integer
---@param position Vector
---@param height number
---@param direction? integer
---@param maxSpread? integer
---@param weight number
---@param bounciness number
---@param friction number
---@param gridCollision GridCollisionClass
---@return EntityEffect
function Resouled:SpawnPrettyParticles(variant, subtype, speed, speedUpwards, maxRotationDownwards, maxRotationUpwards, position, height, direction, maxSpread, weight, bounciness, friction, gridCollision)
    ---@type EntityEffect
    ---@diagnostic disable-next-line: assign-type-mismatch
    local particle = Game():Spawn(EntityType.ENTITY_EFFECT, variant, position, Vector.Zero, nil, subtype or 0, Game():GetRoom():GetAwardSeed()):ToEffect()
    local data = particle:GetData()

    particle.GridCollisionClass = gridCollision
    particle.DepthOffset = -1000

    if maxRotationDownwards > 90 then maxRotationDownwards = 90 end
    if maxRotationUpwards > 90 then maxRotationUpwards = 90 end
    
    local rotation
    if direction then
        rotation = direction
        if maxSpread then
            rotation = rotation + math.random(-maxSpread, maxSpread)
        end
    else
        rotation = math.random(360)
    end
    
    local rotationUp = math.random(-maxRotationDownwards, maxRotationUpwards)
    local multiplierUp = Vector(1, 0):Rotated(rotationUp).X
    local newSpeed = Vector(speed * multiplierUp, 0):Rotated(rotation)
    particle.Velocity = newSpeed
    data.Resouled_SpecialParticle = {
        RotationUp = rotationUp,
        FallSpeed = (weight * (rotationUp/90)) * speedUpwards,
        Weight = weight,
        Height = height,
        Bounciness = bounciness,
        Friction = friction,
        RotationSpeed = speed * (1 - newSpeed.X)
    }
    return particle
end

---@param effect EntityEffect
Resouled:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, effect)
    local data = effect:GetData()
    if data.Resouled_SpecialParticle then
        if data.Resouled_SpecialParticle.Height <= 1 then
            effect.Velocity = effect.Velocity * (1 - data.Resouled_SpecialParticle.Friction)
        end
        effect.Velocity = effect.Velocity * (1 - data.Resouled_SpecialParticle.Friction/10)
    end
end)

---@param effect EntityEffect
Resouled:AddCallback(ModCallbacks.MC_PRE_EFFECT_RENDER, function(_, effect)
    local data = effect:GetData()
    if data.Resouled_SpecialParticle then
        local height = data.Resouled_SpecialParticle.Height
        local fallSpeed = data.Resouled_SpecialParticle.FallSpeed
        
        if not Game():IsPaused() then
            if height > 0 then
                height = height + fallSpeed
                
                fallSpeed = fallSpeed - data.Resouled_SpecialParticle.Weight/2
                
                effect.SpriteRotation = (effect.SpriteRotation + data.Resouled_SpecialParticle.RotationSpeed)%360
            else
                local bounciness = data.Resouled_SpecialParticle.Bounciness
                fallSpeed = -fallSpeed * bounciness
                height = height + fallSpeed
                
                data.Resouled_SpecialParticle.RotationSpeed = -data.Resouled_SpecialParticle.RotationSpeed * bounciness
            end
            
            data.Resouled_SpecialParticle.FallSpeed = fallSpeed
            data.Resouled_SpecialParticle.Height = height
            
        end
        return Vector(0, -data.Resouled_SpecialParticle.Height)
    end
end)

local weight = 0.75
local bounciness = 0.35
local friction = 0.35
---@param position Vector
---@param amount integer
function Resouled:SpawnPaperGore(position, amount)
    for _ = 1, amount do
        Resouled:SpawnPrettyParticles(Isaac.GetEntityVariantByName("Paper Gore Particle"), Isaac.GetEntitySubTypeByName("Paper Gore Particle"), math.random(7, 15), math.random(8, 12), 15, 90, position, 15, nil, nil, weight, bounciness, friction, GridCollisionClass.COLLISION_SOLID)
    end
end

---@param player EntityPlayer
---@return Vector | nil
function Resouled:IsShooting(player)
    local input = player:GetShootingInput()
    if (input.X ~= 0 or input.Y ~= 0) or (input == Vector(0, 0) and player:AreOpposingShootDirectionsPressed()) then
        return input
    end
    return nil
end

---@param position Vector
---@param velocity Vector
---@param maxSpread integer
---@param spriteOffset Vector
function Resouled:SpawnSparkleEffect(position, velocity, maxSpread, spriteOffset)
    local sparkle = Game():Spawn(EntityType.ENTITY_EFFECT, Isaac.GetEntityVariantByName("Ball Sparkle"), position, Vector.Zero, nil, Isaac.GetEntitySubTypeByName("Ball Sparkle"), Game():GetRoom():GetAwardSeed())
    sparkle.Velocity = velocity:Rotated(math.random(-maxSpread, maxSpread))
    sparkle.SpriteOffset = spriteOffset
end

---@param sprite Sprite
---@return Sprite
function Resouled:MakeSpriteFrameSave(sprite) -- Returns a frozen current frame of the provided sprite
    local frame = Sprite()
    frame:Load(sprite:GetFilename())
    frame:Play(sprite:GetAnimation(), true)
    frame:PlayOverlay(sprite:GetOverlayAnimation(), true)
    frame:SetFrame(sprite:GetFrame())
    frame:SetOverlayFrame(sprite:GetOverlayFrame())
    frame:SetRenderFlags(sprite:GetRenderFlags())

    frame.Color = sprite.Color
    frame.FlipX = sprite.FlipX
    frame.FlipY = sprite.FlipY
    frame.Offset = sprite.Offset
    frame.Rotation = sprite.Rotation
    frame.Scale = sprite.Scale

    for i = 0, sprite:GetLayerCount() - 1 do
        local layer = sprite:GetLayer(i)
        local fLayer = frame:GetLayer(i)

        if layer:IsVisible() then
            if fLayer:GetSpritesheetPath() ~= layer:GetSpritesheetPath() then
                frame:ReplaceSpritesheet(fLayer:GetLayerID(), layer:GetSpritesheetPath(), false)
            end
            
            fLayer:SetColor(layer:GetColor())
            fLayer:SetPos(layer:GetPos())
            fLayer:SetCropOffset(layer:GetCropOffset())
            fLayer:SetRenderFlags(layer:GetRenderFlags())
            fLayer:SetFlipX(layer:GetFlipX())
            fLayer:SetFlipY(layer:GetFlipY())
            fLayer:SetRotation(layer:GetRotation())
            fLayer:SetSize(layer:GetSize())
            fLayer:SetWrapSMode(layer:GetWrapSMode())
            fLayer:SetWrapTMode(layer:GetWrapTMode())
        else
            fLayer:SetVisible(layer:IsVisible())
        end
    end

    frame:LoadGraphics()

    return frame
end

---@param npc EntityNPC
---@return boolean
function Resouled:IsValidEnemy(npc) -- Returns true if the npc is a active and vulnerable enemy
    if npc:IsEnemy() and npc:IsActiveEnemy() and npc:IsVulnerableEnemy() then
        return true
    end
    return false
end

---@param idx integer
---@return Vector
function Resouled:GetRoomColumnAndRowFromIdx(idx)
    return Vector(idx%13, idx//13)
end

-- returns a table with a Direction and RoomIndex
---@param position Vector
---@return table | nil
function Resouled:GetNearestRoomIndexAndDirectionFromPos(position)
    local ColRow = Resouled:GetRoomColumnAndRowFromIdx(Game():GetLevel():GetCurrentRoomIndex())

    local room = Game():GetRoom()
    local centerPos = room:GetCenterPos()
    local topLeftPos = room:GetTopLeftPos()
    local bottomRightPos = room:GetBottomRightPos()

    local centerToPositionNormalized = (centerPos - position):Normalized()
    local centerToTopLeftNormalized = (centerPos - topLeftPos):Normalized()
    local centerToBottomRightNormalized = (centerPos - bottomRightPos):Normalized()
    local centerToTopRightNormalized = (centerPos - Vector(bottomRightPos.X, topLeftPos.Y)):Normalized()
    local centerToBottomLeftNormalized = (centerPos - Vector(topLeftPos.X, bottomRightPos.Y)):Normalized()

    local direction = Direction.NO_DIRECTION

    local x = centerToPositionNormalized.X
    local y = centerToPositionNormalized.Y

    if x < centerToTopLeftNormalized.X and x > centerToTopRightNormalized.X and y > centerToTopLeftNormalized.Y then
        ColRow = ColRow - Vector(0, 1)
        direction = Direction.UP
    elseif x < centerToBottomLeftNormalized.X and x > centerToBottomRightNormalized.X and y < centerToBottomLeftNormalized.Y then
        ColRow = ColRow + Vector(0, 1)
        direction = Direction.DOWN
    elseif y > centerToBottomLeftNormalized.Y and y < centerToTopLeftNormalized.Y and x > centerToTopLeftNormalized.X then
        ColRow = ColRow - Vector(1, 0)
        direction = Direction.LEFT
    elseif y > centerToBottomRightNormalized.Y and y < centerToTopRightNormalized.Y and x < centerToTopRightNormalized.X then
        ColRow = ColRow + Vector(1, 0)
        direction = Direction.RIGHT
    end


    if ColRow.X < 0 or ColRow.X > 12 or ColRow.Y < 0 or ColRow.Y > 12 then
        return nil
    else
        local table = {
            Direction = direction,
            RoomIndex = 13 * ColRow.Y + ColRow.X
        }
        return table
    end
end

---@param direction Direction
---@param currentIndex integer
---@return integer | nil
function Resouled:GetRoomIdxFromDir(direction, currentIndex)
    local ColRow = Resouled:GetRoomColumnAndRowFromIdx(currentIndex)

    if direction == Direction.UP then
        ColRow = ColRow - Vector(0, 1)
    elseif direction == Direction.DOWN then
        ColRow = ColRow + Vector(0, 1)
    elseif direction == Direction.LEFT then
        ColRow = ColRow - Vector(1, 0)
    elseif direction == Direction.RIGHT then
        ColRow = ColRow + Vector(1, 0)
    end

    if ColRow.X < 0 or ColRow.X > 12 or ColRow.Y < 0 or ColRow.Y > 12 then
        return nil
    else
        return 13 * ColRow.Y + ColRow.X
    end
end

---@param entity Entity
function Resouled:CanBeChampion(entity)
    return EntityConfig.GetEntity(entity.Type, entity.Variant, entity.SubType):CanBeChampion()
end

local CornerFlashSprite = Sprite()
local CornerFlashFadeSpeed = 0
CornerFlashSprite:Load("gfx/misc/screen_flash_limbo.anm2", true)
CornerFlashSprite:Play("Idle", true)
CornerFlashSprite.Color = Color(0, 0, 0, 0)

---@param color Color
---@param fadeSpeed number
function Resouled:FlashCornerOverlay(color, fadeSpeed)
    CornerFlashSprite.Color = color
    CornerFlashFadeSpeed = fadeSpeed
end

Resouled:AddCallback(ModCallbacks.MC_POST_RENDER, function()
    if CornerFlashSprite.Color.A > 0 then

        local screen = Vector(Isaac.GetScreenWidth(), Isaac.GetScreenHeight())
        CornerFlashSprite.Scale = screen/1000 -- Sprite Size

        CornerFlashSprite:Render(screen/2)

        CornerFlashSprite.Color.A = CornerFlashSprite.Color.A - CornerFlashFadeSpeed
    end
end)

local WhiteOverlaySprite = Sprite()
local WhiteOverlayFadeSpeed = 0
WhiteOverlaySprite:Load("gfx/effects/white_overlay.anm2", true)
WhiteOverlaySprite:Play("Idle", true)
WhiteOverlaySprite.Color = Color(0, 0, 0, 0)

---@param color Color
---@param fadeSpeed number
function Resouled:WhiteOverlay(color, fadeSpeed)
    WhiteOverlaySprite.Color = color
    WhiteOverlayFadeSpeed = fadeSpeed
end

Resouled:AddCallback(ModCallbacks.MC_POST_RENDER, function()
    if WhiteOverlaySprite.Color.A > 0 then

        local screen = Vector(Isaac.GetScreenWidth(), Isaac.GetScreenHeight())/2
        WhiteOverlaySprite.Scale = screen

        WhiteOverlaySprite:Render(screen)

        WhiteOverlaySprite.Color.A = WhiteOverlaySprite.Color.A - WhiteOverlayFadeSpeed
    end
end)