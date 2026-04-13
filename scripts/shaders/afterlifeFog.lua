local g = Resouled.Game

local config = {
    Name = "ResouledAfterlifeFog",

    OriginalRadius = 200,

    CenterPos = Vector.Zero,
    Radius = 0,
    Time = 0,
    CameraPos = Vector.Zero,
    Active = true,
    Intensity = 0.85,
    MinIntensity = 0.0,
    Color = Color(1, 1, 1),
    RadiusScale = Vector(1, 1),

    TargetPos = Vector.Zero
}

Resouled:AddCallback(ModCallbacks.MC_GET_SHADER_PARAMS, function(_, shaderName)
    if shaderName ~= config.Name then return end
    if Resouled.AfterlifeShop.ShadowFight.Active then
        local pos = Isaac.WorldToScreen(config.CenterPos)
        return {
            CenterPos = { pos.X, pos.Y },
            Radius = config.Radius,
            Time = config.Time,
            CameraPos = { config.CameraPos.X, config.CameraPos.Y },
            Active = config.Active and 1 or 0,
            Intensity = config.Intensity,
            MinIntensity = config.MinIntensity,
            FogColorR = config.Color.R,
            FogColorG = config.Color.G,
            FogColorB = config.Color.B,
            RadiusScale = { config.RadiusScale.X, config.RadiusScale.Y },
        }
    else
        return {
            CenterPos = Vector.Zero,
            Radius = 0,
            Time = 0,
            CameraPos = Vector.Zero,
            Active = 0,
            Intensity = 0,
            MinIntensity = 0,
            FogColorR = 0,
            FogColorG = 0,
            FogColorB = 0,
            RadiusScale = { 1, 1 },
        }
    end
end)

Resouled:AddCallback(ModCallbacks.MC_POST_RENDER, function()
    if not config.Active then return end

    config.Time = g:GetFrameCount() / 30.0
    config.Radius = math.max(config.OriginalRadius, 0)
    config.CameraPos = -Isaac.WorldToScreen(Vector.Zero)

    if Resouled.Game:IsPaused() then return end

    local x = config.TargetPos - config.CenterPos
    config.CenterPos = config.CenterPos + x:Resized(math.log(x:Length()/10))
end)

---@return Vector
function Resouled:GetFogCenterPos()
    return config.CenterPos
end

---@param pos Vector
function Resouled:SetFogPos(pos)
    config.CenterPos = pos
    config.TargetPos = pos
end

---@param pos Vector
function Resouled:SetFogTargetPos(pos)
    config.TargetPos = pos
end