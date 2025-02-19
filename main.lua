---@class ModReference
Resouled = RegisterMod("Resouled", 1)

---@type SaveManager
SAVE_MANAGER = include("scripts.utility.save_manager")
SAVE_MANAGER.Init(Resouled)

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
function Resouled:SpawnItemOfQuality(quality, rng, position)
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
function Resouled:IterateOverPlayers(callback, ...)
    for i = 0, Game():GetNumPlayers() - 1 do
        local player = Isaac.GetPlayer(i)
        callback(player, i, ...)
    end
end

---@param player EntityPlayer
function Resouled:GrantGuppyTransformation(player)
    if not player:HasPlayerForm(PlayerForm.PLAYERFORM_GUPPY)
    then
        for _ = 1, 4 do
            player:AddTrinket(TrinketType.TRINKET_KIDS_DRAWING, true)
        end

        player:TryRemoveTrinket(TrinketType.TRINKET_KIDS_DRAWING)
        player:TryRemoveTrinket(TrinketType.TRINKET_KIDS_DRAWING)
    end
end

---@param player EntityPlayer
function Resouled:GetEffectiveHP(player)
    -- TODO
    local red = player:GetHearts()
    local soul = player:GetSoulHearts() -- black hearts are counted in
    local bone = player:GetBoneHearts()
    local rotten = player:GetRottenHearts()
    local eternal = player:GetEternalHearts()
    return red + soul + bone - rotten + eternal
end

---@param player EntityPlayer
function Resouled:GetEffectiveRedHP(player)
    return player:GetHearts() - 2*player:GetRottenHearts()
end

---@param player EntityPlayer
function Resouled:GetEffectiveSoulHP(player)
    return math.max(player:GetSoulHearts() - 2*player:GetBlackHearts(), 0)
end

---@param player EntityPlayer
function Resouled:GetEffectiveBlackHP(player)
    return player:GetSoulHearts() - Resouled:GetEffectiveSoulHP(player)
end

include("scripts.items")
include("scripts.pocketitems")
include("scripts.curses")
include("scripts.blessings")