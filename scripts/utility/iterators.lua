---@class IteratorsModule
local iteratorsModule = {}

-- Iterates over all players in the game and calls the callback function with first argument being `player`.
-- Passes all additional arguments to the callback function in the same order as they were passed to this function.
---@param callback function
function iteratorsModule:IterateOverPlayers(callback, ...)
    for i = 0, Game():GetNumPlayers() - 1 do
        local player = Isaac.GetPlayer(i)
        callback(player, ...)
    end
end

--- Iterates over all entities in the room and calls the callback function with first argument being `entity`.
--- Passes all additional arguments to the callback function in the same order as they were passed to this function.
--- @param callback function
function iteratorsModule:IterateOverRoomEntities(callback, ...)
    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        callback(entity, ...)
    end
end

---@param callback function
function iteratorsModule:IterateOverRooms(callback, ...)
    local level = Game():GetLevel()
    for i = 1, 13 * 13 do
        local roomIndex = i
        callback(roomIndex, ...)
    end
end

---@param callback function
function iteratorsModule:IterateOverGrid(callback, ...)
    local room = Game():GetRoom()
    for i = 0, room:GetGridSize() - 1 do
        local gridEntity = room:GetGridEntity(i)
        if gridEntity then
            callback(gridEntity, ...)
        end
    end
end



return iteratorsModule