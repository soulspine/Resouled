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