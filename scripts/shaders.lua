local x = 1
local maxAuraSize = 0 --75
local sides = math.random(3, 7)

Resouled:AddCallback(ModCallbacks.MC_GET_SHADER_PARAMS, function(_, shaderName)
    if shaderName == 'ResouledBlankCanvas' then
        if PauseMenu.GetState() ~= PauseMenuStates.CLOSED then
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

        local mouse = Isaac.WorldToScreen(Input.GetMousePosition(true))

        x = math.min(0.5 + x + x/2, maxAuraSize)

        for i = 1, sides do
            table.insert(points, Vector(x, 0):Rotated(360/sides * i))
        end

        return {
            AnchorPos = {
                mouse.X,
                mouse.Y
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