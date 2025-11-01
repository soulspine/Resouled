---@class VectorModule
local vectorModule = {}

---@return Vector
function vectorModule:GetScreenDimensions()
    return Vector(Isaac.GetScreenWidth(), Isaac.GetScreenHeight())
end

local DISTANCE_FROM_GRID_ENTITY_CENTER = 25

---@param vector Vector
---@param entity1Pos Vector
---@param entity2Pos Vector
function vectorModule:GetBounceOffGridElementVector(vector, entity1Pos, entity2Pos)
    local dirHelper = entity2Pos - entity1Pos
    if dirHelper.X > 0 and dirHelper.Y >= -DISTANCE_FROM_GRID_ENTITY_CENTER and dirHelper.Y <= DISTANCE_FROM_GRID_ENTITY_CENTER then
        vector.X = -vector.X
    elseif dirHelper.X < 0 and dirHelper.Y >= -DISTANCE_FROM_GRID_ENTITY_CENTER and dirHelper.Y <= DISTANCE_FROM_GRID_ENTITY_CENTER then
        vector.X = -vector.X
    end
    if dirHelper.Y > 0 and dirHelper.X >= -DISTANCE_FROM_GRID_ENTITY_CENTER and dirHelper.X <= DISTANCE_FROM_GRID_ENTITY_CENTER then
        vector.Y = -vector.Y
    elseif dirHelper.Y < 0 and dirHelper.X >= -DISTANCE_FROM_GRID_ENTITY_CENTER and dirHelper.X <= DISTANCE_FROM_GRID_ENTITY_CENTER then
        vector.Y = -vector.Y
    end
    return vector
end

---@param vector Vector
---@return Vector
function vectorModule:SnapDirectionToAxis(vector)
    if vector:Length() == 0 then
        return Vector(0, 0)
    end

    local angle = vector:GetAngleDegrees()
    local snappedAngle = math.floor((angle + 45) / 90) * 90 % 360

    if snappedAngle == 0 then return Vector(1, 0) end
    if snappedAngle == 90 then return Vector(0, 1) end
    if snappedAngle == 180 then return Vector(-1, 0) end
    if snappedAngle == 270 then return Vector(0, -1) end

    return Vector(0, 0) -- fallback
end

---@param vector Vector
---@return boolean
function vectorModule:IsFacingLeft(vector)
    return vector.X < 0
end

---@param vector Vector
---@return boolean
function vectorModule:IsFacingRight(vector)
    return vector.X > 0
end

---@param vector Vector
---@return boolean
function vectorModule:IsFacingUp(vector)
    return vector.Y < 0
end

---@param vector Vector
---@return boolean
function vectorModule:IsFacingDown(vector)
    return vector.Y > 0
end

return vectorModule
