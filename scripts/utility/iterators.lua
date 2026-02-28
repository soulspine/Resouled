---@class IteratorsModule
local iteratorsModule = {}

-- Iterates over all players in the game and calls the callback function with first argument being `player`.
-- Passes all additional arguments to the callback function in the same order as they were passed to this function.
---@param callback fun(player: EntityPlayer, ...: any)
function iteratorsModule:IterateOverPlayers(callback, ...)
    for i = 0, Game():GetNumPlayers() - 1 do
        local player = Isaac.GetPlayer(i)
        callback(player, ...)
    end
end

--- Iterates over all entities in the room and calls the callback function with first argument being `entity`.
--- Passes all additional arguments to the callback function in the same order as they were passed to this function.
--- @param callback fun(entity: Entity, ...: any)
function iteratorsModule:IterateOverRoomEntities(callback, ...)
    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        callback(entity, ...)
    end
end

--- Iterates over all npcs in the room and calls the callback function with first argument being `npc`.
--- Passes all additional arguments to the callback function in the same order as they were passed to this function.
--- @param callback fun(npc: EntityNPC, ...: any)
function iteratorsModule:IterateOverRoomNpcs(callback, ...)
    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        local npc = entity:ToNPC()
        if npc then
            callback(npc, ...)
        end
    end
end

--- Iterates over all effects in the room and calls the callback function with first argument being `effect`.
--- Passes all additional arguments to the callback function in the same order as they were passed to this function.
--- @param callback fun(effect: EntityEffect, ...: any)
function iteratorsModule:IterateOverRoomEffects(callback, ...)
    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        local effect = entity:ToEffect()
        if effect then
            callback(effect, ...)
        end
    end
end

--- Iterates over all tears in the room and calls the callback function with first argument being `tear`.
--- Passes all additional arguments to the callback function in the same order as they were passed to this function.
--- @param callback fun(tear: EntityTear, ...: any)
function iteratorsModule:IterateOverRoomTears(callback, ...)
    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        local tear = entity:ToTear()
        if tear then
            callback(tear, ...)
        end
    end
end

--- Iterates over all projectiles in the room and calls the callback function with first argument being `projectile`.
--- Passes all additional arguments to the callback function in the same order as they were passed to this function.
--- @param callback fun(projectile: EntityProjectile, ...: any)
function iteratorsModule:IterateOverRoomProjectiles(callback, ...)
    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        local projectile = entity:ToProjectile()
        if projectile then
            callback(projectile, ...)
        end
    end
end

--- Iterates over all lasers in the room and calls the callback function with first argument being `laser`.
--- Passes all additional arguments to the callback function in the same order as they were passed to this function.
--- @param callback fun(laser: EntityLaser, ...: any)
function iteratorsModule:IterateOverRoomLasers(callback, ...)
    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        local laser = entity:ToLaser()
        if laser then
            callback(laser, ...)
        end
    end
end

--- Iterates over all knives in the room and calls the callback function with first argument being `knife`.
--- Passes all additional arguments to the callback function in the same order as they were passed to this function.
--- @param callback fun(knife: EntityKnife, ...: any)
function iteratorsModule:IterateOverRoomKnives(callback, ...)
    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        local knife = entity:ToKnife()
        if knife then
            callback(knife, ...)
        end
    end
end

--- Iterates over all bombs in the room and calls the callback function with first argument being `bomb`.
--- Passes all additional arguments to the callback function in the same order as they were passed to this function.
--- @param callback fun(bomb: EntityBomb, ...: any)
function iteratorsModule:IterateOverRoomBombs(callback, ...)
    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        local bomb = entity:ToBomb()
        if bomb then
            callback(bomb, ...)
        end
    end
end

--- Iterates over all familiars in the room and calls the callback function with first argument being `familiar`.
--- Passes all additional arguments to the callback function in the same order as they were passed to this function.
--- @param callback fun(familiar: EntityFamiliar, ...: any)
function iteratorsModule:IterateOverRoomFamiliars(callback, ...)
    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        local familiar = entity:ToFamiliar()
        if familiar then
            callback(familiar, ...)
        end
    end
end

--- Iterates over all pickups in the room and calls the callback function with first argument being `pickup`.
--- Passes all additional arguments to the callback function in the same order as they were passed to this function.
--- @param callback fun(pickup: EntityPickup, ...: any)
function iteratorsModule:IterateOverRoomPickups(callback, ...)
    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        local pickup = entity:ToPickup()
        if pickup then
            callback(pickup, ...)
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

--- Iterates over all existing grid entities, empty spaces are skipped.
---@param callback fun(gridEntity: GridEntity, index: integer)
function iteratorsModule:IterateOverGridEntities(callback)
    local room = Game():GetRoom()
    for i = 0, room:GetGridSize() - 1 do
        local gridEntity = room:GetGridEntity(i)
        if gridEntity then
            callback(gridEntity, i)
        end
    end
end

--- Iterates over all grid positions. Check `gridEntity` for nil because empty spaces are included.
--- @param callback fun(gridEntity: GridEntity|nil, index: integer)
function iteratorsModule:IterateOverGrid(callback)
    local room = Game():GetRoom()
    for i = 0, room:GetGridSize() - 1 do
        callback(room:GetGridEntity(i), i)
    end
end

---@param pos Vector
---@param radius number
---@param callback fun(entity: Entity, ...: any)
function iteratorsModule:IterateOverEntitiesInArea(pos, radius, callback, ...)
    for _, en in ipairs(Isaac.FindInRadius(pos, radius)) do callback(en, ...) end
end

---@param pos Vector
---@param radius number
---@param callback fun(entity: EntityPlayer, ...: any)
function iteratorsModule:IterateOverPlayersInArea(pos, radius, callback, ...)
    for _, en in ipairs(Isaac.FindInRadius(pos, radius, EntityPartition.PLAYER)) do
        local en2 = en:ToPlayer()
        if en2 then callback(en2, ...) end
    end
end

---@param pos Vector
---@param radius number
---@param callback fun(entity: EntityNPC, ...: any)
function iteratorsModule:IterateOverNpcsInArea(pos, radius, callback, ...)
    for _, en in ipairs(Isaac.FindInRadius(pos, radius, EntityPartition.ENEMY)) do
        local en2 = en:ToNPC()
        if en2 then callback(en2, ...) end
    end
end

---@param pos Vector
---@param radius number
---@param callback fun(entity: EntityPickup, ...: any)
function iteratorsModule:IterateOverPickupsInArea(pos, radius, callback, ...)
    for _, en in ipairs(Isaac.FindInRadius(pos, radius, EntityPartition.PICKUP)) do
        local en2 = en:ToPickup()
        if en2 then callback(en2, ...) end
    end
end

---@param pos Vector
---@param radius number
---@param callback fun(entity: EntityTear, ...: any)
function iteratorsModule:IterateOverTearsInArea(pos, radius, callback, ...)
    for _, en in ipairs(Isaac.FindInRadius(pos, radius, EntityPartition.TEAR)) do
        local en2 = en:ToTear()
        if en2 then callback(en2, ...) end
    end
end

---@param pos Vector
---@param radius number
---@param callback fun(entity: EntityLaser, ...: any)
function iteratorsModule:IterateOverLasersInArea(pos, radius, callback, ...)
    for _, en in ipairs(Isaac.FindInRadius(pos, radius, EntityPartition.TEAR)) do
        local en2 = en:ToLaser()
        if en2 then callback(en2, ...) end
    end
end

---@param pos Vector
---@param radius number
---@param callback fun(entity: EntityKnife, ...: any)
function iteratorsModule:IterateOverKnivesInArea(pos, radius, callback, ...)
    for _, en in ipairs(Isaac.FindInRadius(pos, radius, EntityPartition.TEAR)) do
        local en2 = en:ToKnife()
        if en2 then callback(en2, ...) end
    end
end

---@param pos Vector
---@param radius number
---@param callback fun(entity: EntityBomb, ...: any)
function iteratorsModule:IterateOverBombsInArea(pos, radius, callback, ...)
    local x = ...
    iteratorsModule:IterateOverEntitiesInArea(pos, radius, function(en)
        local en2 = en:ToBomb()
        if en2 then callback(en2, x) end
    end)
end

---@param pos Vector
---@param radius number
---@param callback fun(entity: EntityEffect, ...: any)
function iteratorsModule:IterateOverEffectsInArea(pos, radius, callback, ...)
    for _, en in ipairs(Isaac.FindInRadius(pos, radius, EntityPartition.EFFECT)) do
        local en2 = en:ToEffect()
        if en2 then callback(en2, ...) end
    end
end

---@param pos Vector
---@param radius number
---@param callback fun(entity: EntityProjectile, ...: any)
function iteratorsModule:IterateOverProjectilesInArea(pos, radius, callback, ...)
    for _, en in ipairs(Isaac.FindInRadius(pos, radius, EntityPartition.BULLET)) do
        local en2 = en:ToProjectile()
        if en2 then callback(en2, ...) end
    end
end

return iteratorsModule
