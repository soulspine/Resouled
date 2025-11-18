local x = 0
local maxAuraSize = 0 --20

Resouled:AddPriorityCallback(ModCallbacks.MC_GET_SHADER_PARAMS, CallbackPriority.IMPORTANT, function(_, shaderName)
    local player = Isaac.GetPlayer()
    local position = Isaac.WorldToScreen(player.Position + Vector(0, -player.Size * 1.5))
    if shaderName == 'ResouledBlankCanvas' then
        x = math.min(x + 1, (maxAuraSize + x)/2)
        return {
            PointPos = {
                position.X,
                position.Y
            },
            AreaSize = math.log(x) * x,
            Smoothing = 3
        }
    end
    if shaderName == 'ResouledBlankCanvasPolygon' then

        local points = {}
        local sides = math.random(7, 7)
        for i = 1, sides do
            table.insert(points, Vector(75, 0):Rotated(360/sides * i))
        end

        return {
            AnchorPos = {
                Isaac.GetScreenWidth()/2,
                Isaac.GetScreenHeight()/2
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
            },
            Size = 75.0
        }
    end
end)

local function negativeOrPositive()
    ::Start::
    local num = math.random(-1, 1)
    if num == 0 then goto Start end
    return num
end

local r = 0
local sides = 7

local checkPoints = {}

local pointCount = 250

for _ = 1, pointCount do
    table.insert(checkPoints, Vector(math.random() * math.random(-150, 150), math.random() * math.random(-150, 150)))
end

Resouled:AddCallback(ModCallbacks.MC_POST_RENDER, function()
    if true then return end
    local points = {}
    local screenEnd = Isaac.GetScreenWidth()
    local anchorPoint = Vector(screenEnd/2, Isaac.GetScreenHeight()/2)

    local mouse = Isaac.WorldToScreen(Input.GetMousePosition(true))

    local size = anchorPoint:Distance(mouse)
    for i = 1, sides do
        local shake = Vector(math.random() * 2.5 * negativeOrPositive(), math.random() * 2.5 * negativeOrPositive()) * math.min(size/20, 1)
        table.insert(points, Vector(size, 0):Rotated(360/sides * i + (anchorPoint - mouse):GetAngleDegrees() - 360/sides * 6))
    end
    
    local lastPoint
    
    for i = 1, sides do
        lastPoint = points[i]
        local idx = 1 + i%sides
        local point = points[idx]

        Isaac.DrawLine(anchorPoint + lastPoint, anchorPoint + point, KColor(1, 1, 1, 1), KColor(1, 1, 1, 1), 1)
        
        lastPoint = point
    end

    for i, point in ipairs(checkPoints) do
        if i <= pointCount then
            local thickness = 3
            local pos = point
            
            local color = KColor(1, 0, 0, 1)
            
            local cutCount = 0

            for j = 1, sides do
                local pos1 = points[j]
                local pos2 = points[1 + j%sides]

                local y1 = math.max(pos1.Y, pos2.Y)
                local y2 = math.min(pos1.Y, pos2.Y)

                Isaac.DrawLine(pos1 + anchorPoint, pos2 + anchorPoint, KColor(1, 0, 0, 1), KColor(1, 0, 0, 1), 1)
                    
                if pos.Y <= y1 and pos.Y >= y2 then

                    local rotation = -(pos1:GetAngleDegrees() + pos2:GetAngleDegrees())/2

                    if pos1:Rotated(rotation):GetAngleDegrees() > 0 or pos2:Rotated(rotation):GetAngleDegrees() < 0 then rotation = rotation - 180 end

                    local newPointX = pos:Rotated(rotation).X
                    local newLineX = pos1:Rotated(rotation).X

                    if newPointX <= newLineX then
                        cutCount = cutCount + 1
                    end

                    if anchorPoint.Y + y1 > anchorPoint.Y or anchorPoint.Y + y2 < anchorPoint.Y then
                        cutCount = cutCount + 1
                    end
                end
            end
            
            if cutCount > 0 and cutCount%2 == 0 then
                color.Green = 1
            end
            
            pos = pos + anchorPoint
            
            Isaac.DrawLine(pos - Vector(thickness/2, 0), pos + Vector(thickness/2, 0), color, color, thickness)
            --Isaac.DrawLine(pos, Vector(screenEnd, pos.Y), color, color, 1)
        end
    end

    r = (r + 0.5)%360
end)