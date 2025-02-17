---@type ModReference
MOD = RegisterMod("Resouled", 1)

include("scripts.items")

---@type SaveManager
SAVE_MANAGER = include("scripts.utility.save_manager")
SAVE_MANAGER.Init(MOD)

function GetMaxItemID()
    local itemConfig = Isaac.GetItemConfig()
    local maxItemId = CollectibleType.NUM_COLLECTIBLES

    while true do
        if itemConfig:GetCollectible(maxItemId) == nil then
            break
        end
        maxItemId = maxItemId + 1
    end

    return maxItemId - 1
end

---@param quality integer
---@param rng RNG
---@param position Vector
function SpawnItemOfQuality(quality, rng, position)
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
            print("Removing item from validItems - " .. randomItem)
            for i = 1, #validItems do
                if validItems[i] == randomItem then
                    table.remove(validItems, i)
                    break
                end
            end
            goto reroll
        end

        local entity = Game():Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, Isaac.GetFreeNearPosition(position, 60), Vector.Zero, nil, randomItem, rng:GetSeed())
        rng:Next()
        return entity

    end
    return nil
end

---@param callback function
-- Iterates over all players in the game and calls the callback function with 2 first arguments: `player` and `playerID`.
-- Passes all additional arguments to the callback function in the same order as they were passed to this function.
function IterateOverPlayers(callback, ...)
    for i = 0, Game():GetNumPlayers() - 1 do
        local player = Isaac.GetPlayer(i)
        callback(player, i, ...)
    end
end