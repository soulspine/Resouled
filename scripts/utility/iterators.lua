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

--- Iterates over all npcs in the room and calls the callback function with first argument being `npc`.
--- Passes all additional arguments to the callback function in the same order as they were passed to this function.
--- @param callback function
function iteratorsModule:IterateOverRoomNpcs(callback, ...)
    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        if entity:ToNPC() then
            callback(entity:ToNPC(), ...)
        end
    end
end

--- Iterates over all effects in the room and calls the callback function with first argument being `effect`.
--- Passes all additional arguments to the callback function in the same order as they were passed to this function.
--- @param callback function
function iteratorsModule:IterateOverRoomEffects(callback, ...)
    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        if entity:ToEffect() then
            callback(entity:ToEffect(), ...)
        end
    end
end

--- Iterates over all tears in the room and calls the callback function with first argument being `tear`.
--- Passes all additional arguments to the callback function in the same order as they were passed to this function.
--- @param callback function
function iteratorsModule:IterateOverRoomTears(callback, ...)
    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        if entity:ToTear() then
            callback(entity:ToTear(), ...)
        end
    end
end

--- Iterates over all projectiles in the room and calls the callback function with first argument being `projectile`.
--- Passes all additional arguments to the callback function in the same order as they were passed to this function.
--- @param callback function
function iteratorsModule:IterateOverRoomProjectiles(callback, ...)
    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        if entity:ToProjectile() then
            callback(entity:ToProjectile(), ...)
        end
    end
end

--- Iterates over all lasers in the room and calls the callback function with first argument being `laser`.
--- Passes all additional arguments to the callback function in the same order as they were passed to this function.
--- @param callback function
function iteratorsModule:IterateOverRoomLasers(callback, ...)
    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        if entity:ToLaser() then
            callback(entity:ToLaser(), ...)
        end
    end
end

--- Iterates over all knives in the room and calls the callback function with first argument being `knife`.
--- Passes all additional arguments to the callback function in the same order as they were passed to this function.
--- @param callback function
function iteratorsModule:IterateOverRoomKnives(callback, ...)
    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        if entity:ToKnife() then
            callback(entity:ToKnife(), ...)
        end
    end
end

--- Iterates over all bombs in the room and calls the callback function with first argument being `bomb`.
--- Passes all additional arguments to the callback function in the same order as they were passed to this function.
--- @param callback function
function iteratorsModule:IterateOverRoomBombs(callback, ...)
    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        if entity:ToBomb() then
            callback(entity:ToBomb(), ...)
        end
    end
end

--- Iterates over all familiars in the room and calls the callback function with first argument being `familiar`.
--- Passes all additional arguments to the callback function in the same order as they were passed to this function.
--- @param callback function
function iteratorsModule:IterateOverRoomFamiliars(callback, ...)
    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        if entity:ToFamiliar() then
            callback(entity:ToFamiliar(), ...)
        end
    end
end

--- Iterates over all pickups in the room and calls the callback function with first argument being `pickup`.
--- Passes all additional arguments to the callback function in the same order as they were passed to this function.
--- @param callback function
function iteratorsModule:IterateOverRoomPickups(callback, ...)
    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        if entity:ToPickup() then
            callback(entity:ToPickup(), ...)
        end
    end
end

---@param callback function
function iteratorsModule:IterateOverRooms(callback, ...)
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