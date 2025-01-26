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
include("custom_scripts.EID")