local auraVisible = false
local x = 1
local maxAuraSize = 0 --75
local sides = 0
local auraPos = Vector.Zero
local rotation = 0

---@param pos Vector
function Resouled:CreatePaperAura(pos)
    auraVisible = true
    x = 1
    maxAuraSize = 75
    sides = math.random(3, 7)
    auraPos = Isaac.WorldToScreen(pos)
    rotation = math.random() * 360
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

---@param pos Vector
---@param inGamePos? boolean --Default: true | Whether position is treated as Game Coords, if false, it is treated Screen Coords
function Resouled:IsPosInsidePaperAura(pos, inGamePos)
    inGamePos = inGamePos or true
    if inGamePos then
        pos = Isaac.WorldToScreen(pos)
    end
    pos = pos - auraPos

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

function Resouled:HidePaperAura()
    auraVisible = false
    x = 1
    maxAuraSize = 0 --75
    sides = 0
    auraPos = Vector.Zero
    rotation = 0
end

Resouled:AddCallback(ModCallbacks.MC_GET_SHADER_PARAMS, function(_, shaderName)
    if shaderName == 'ResouledBlankCanvas' then
        if not auraVisible or PauseMenu.GetState() ~= PauseMenuStates.CLOSED then
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

        x = math.min(0.5 + x + x / 2, maxAuraSize)

        for i = 1, sides do
            table.insert(points, Vector(x, 0):Rotated(360 / sides * i + rotation))
        end

        return {
            AnchorPos = {
                auraPos.X,
                auraPos.Y
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
