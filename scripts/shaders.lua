local auraVisible = false
local x = 1
local maxAuraSize = 0 --75
local sides = 0
local auraPos = function() return Vector.Zero end
local rotation = 0
local auraTimeout = 0

local MIN_AURA_SIDES = 4
local MAX_AURA_SIDES = 7

---@param pos function
---@param timeout integer
---@param size integer Recommended: 75
function Resouled:CreatePaperAura(pos, timeout, size)
    auraVisible = true
    x = 1
    maxAuraSize = size
    sides = math.random(MIN_AURA_SIDES, MAX_AURA_SIDES)
    auraPos = pos
    rotation = math.random() * 360
    auraTimeout = timeout
end

---@return Vector[] | nil
function Resouled:GetPaperAuraPoints()
    if auraVisible then
        local points = {}
        for i = 1, sides do
            table.insert(points, Vector(x, 0):Rotated(360 / sides * i + rotation))
        end
        return points
    end
    return nil
end

---@return boolean
function Resouled:IsPaperAuraVisible()
    return auraVisible
end

---@return Vector | nil
function Resouled:GetPaperAuraPosition()
    return auraPos and auraPos() or nil
end

---@param pos Vector
---@param inGamePos? boolean --Default: true | Whether position is treated as Game Coords, if false, it is treated Screen Coords
function Resouled:IsPosInsidePaperAura(pos, inGamePos)
    inGamePos = inGamePos or true
    if inGamePos == true then
        pos = Isaac.WorldToScreen(pos)
    end
    pos = pos - Isaac.WorldToScreen(auraPos())

    local points = Resouled:GetPaperAuraPoints()
    if not points then return false end

    local isInside = true

    for i = 1, sides do
        local sidePos = points[i]
        local lastIdx = i - 1
        if lastIdx == 0 then lastIdx = sides end
        local lastPos = points[lastIdx]
        local nextPos = points[i % sides + 1]
        local anchorToSidePos = sidePos:GetAngleDegrees()

        local lastPosDegrees = ((lastPos - sidePos):Rotated(-anchorToSidePos)):GetAngleDegrees()
        local nextPosDegrees = ((nextPos - sidePos):Rotated(-anchorToSidePos)):GetAngleDegrees()
        local toPointDegrees = ((pos - sidePos):Rotated(-anchorToSidePos)):GetAngleDegrees()

        if toPointDegrees < nextPosDegrees and toPointDegrees > lastPosDegrees then
            isInside = false
            break
        end
    end

    return isInside
end

---@param hideAnimation? boolean Default: True
function Resouled:HidePaperAura(hideAnimation)
    hideAnimation = hideAnimation or true

    auraTimeout = 0
    if not hideAnimation then
        auraVisible = false
        x = 1
        maxAuraSize = 0
        sides = 0
        auraPos = function() return Vector.Zero end
        rotation = 0
    end
end

Resouled:AddCallback(ModCallbacks.MC_GET_SHADER_PARAMS, function(_, shaderName)
    if shaderName == 'ResouledBlankCanvas' then
        if not auraVisible or x == 0 or PauseMenu.GetState() ~= PauseMenuStates.CLOSED then
            return {
                AnchorPos = {
                    0,
                    0
                },
                Point1 = {
                    0,
                    0,
                },
                Point2 = {
                    0,
                    0,
                },
                Point3 = {
                    0,
                    0,
                },
                Point4 = {
                    0,
                    0,
                },
                Point5 = {
                    0,
                    0,
                },
                Point6 = {
                    0,
                    0,
                },
                Point7 = {
                    0,
                    0,
                }
            }
        end

        local points = {}

        x = math.max(math.min(x + (0.35 + x/3) * (auraTimeout > 0 and 1 or -1), maxAuraSize), 0)

        for i = 1, sides do
            table.insert(points, Vector(x, 0):Rotated(360 / sides * i + rotation))
        end

        local pos = Isaac.WorldToScreen(auraPos())

        if not Game():IsPaused() then
            auraTimeout = math.max(auraTimeout - 1, 0)
        end
        auraVisible = x > 0

        return {
            AnchorPos = {
                pos.X,
                pos.Y
            },
            Point1 = {
                points[1] and points[1].X or 0,
                points[1] and points[1].Y or 0,
            },
            Point2 = {
                points[2] and points[2].X or 0,
                points[2] and points[2].Y or 0,
            },
            Point3 = {
                points[3] and points[3].X or 0,
                points[3] and points[3].Y or 0,
            },
            Point4 = {
                points[4] and points[4].X or 0,
                points[4] and points[4].Y or 0,
            },
            Point5 = {
                points[5] and points[5].X or 0,
                points[5] and points[5].Y or 0,
            },
            Point6 = {
                points[6] and points[6].X or 0,
                points[6] and points[6].Y or 0,
            },
            Point7 = {
                points[7] and points[7].X or 0,
                points[7] and points[7].Y or 0,
            }
        }
    end
end)
