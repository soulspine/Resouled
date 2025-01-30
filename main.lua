MOD = RegisterMod("Resouled", 1)

local game = Game()

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
---@param onlyUnlocks? boolean default true
function MOD:SpawnItemOfQuality(quality, rng, position, onlyUnlocks)
    onlyUnlocks = onlyUnlocks and true or false
    local itemConfig = Isaac.GetItemConfig()
    local validItems = {}
    
    for i = 1, #itemConfig:GetCollectibles() do
        local item = itemConfig:GetCollectible(i)
        if item and item.Quality == quality and not item.Hidden and (not onlyUnlocks or item:IsAvailable()) then
            table.insert(validItems, i)
        end
    end
    
    if #validItems > 0 then
        local randomItem = validItems[rng:RandomInt(#validItems) + 1]
        return Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, randomItem, Isaac.GetFreeNearPosition(position, 60), Vector.Zero, nil)
    end
    return nil
end

---@param callback function
-- Iterates over all players in the game and calls the callback function with 2 first arguments: `player` and `playerID`.
-- Passes all additional arguments to the callback function in the same order as they were passed to this function.
function IterateOverPlayers(callback, ...)
    for i = 0, game:GetNumPlayers() - 1 do
        local player = Isaac.GetPlayer(i)
        callback(player, i, ...)
    end
end

--import all item modules
include("custom_scripts.items")