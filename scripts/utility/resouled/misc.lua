function Resouled:Log(...)
    print("[Resouled]", ...)
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