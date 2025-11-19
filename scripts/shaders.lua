local x = 0
local maxAuraSize = 0 --75
local r = 0
local sides = math.random(3, 7)

local function negativeOrPositive()
    ::Start::
    local num = math.random(-1, 1)
    if num == 0 then goto Start end
    return num
end

Resouled:AddPriorityCallback(ModCallbacks.MC_GET_SHADER_PARAMS, CallbackPriority.IMPORTANT, function(_, shaderName)
    if shaderName == 'ResouledBlankCanvas' then
        local points = {}

        x = math.min(x + (maxAuraSize - x)/(50 + x/50), maxAuraSize)

        for i = 1, sides do
            local shake = Vector(math.random() * 2.5 * negativeOrPositive(), math.random() * 2.5 * negativeOrPositive()) * (x/maxAuraSize)
            table.insert(points, shake + Vector(x, 0):Rotated(360/sides * i +  r))
        end

        return {
            AnchorPos = {
                0,
                0
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
local sides = 3

local checkPoints = {}

local pointCount = 250

for _ = 1, pointCount do
    table.insert(checkPoints, Vector(math.random() * math.random(-150, 150), math.random() * math.random(-150, 150)))
end

Resouled:AddCallback(ModCallbacks.MC_POST_RENDER, function()
    r = (r + 3)%360
end)