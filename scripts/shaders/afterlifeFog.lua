local g = Game()

local config = {
    Name = "ResouledAfterlifeFog",

    OriginalRadius = 20,

    CenterPos = Vector.Zero,
    Radius = 0,
    Time = 0,
    Intensity = 1.0,
    CameraPos = Vector.Zero,
}

Resouled:AddCallback(ModCallbacks.MC_GET_SHADER_PARAMS, function(_, shaderName)
    if shaderName ~= config.Name then return end
    return {
        CenterPos = { config.CenterPos.X, config.CenterPos.Y },
        Radius = config.Radius,
        Time = config.Time,
        Intensity = config.Intensity,
        CameraPos = { config.CameraPos.X, config.CameraPos.Y }
    }
end)

Resouled:AddCallback(ModCallbacks.MC_POST_RENDER, function()
    local player = Isaac.GetPlayer()
    config.CenterPos = Isaac.WorldToScreen(player.Position) + Vector(0, -10)
    config.Radius = math.max(config.OriginalRadius, 0)
    config.Time = g:GetFrameCount() / 30.0
    config.CameraPos = -Isaac.WorldToScreen(Vector.Zero)
end)
