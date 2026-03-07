local g = Game()

local config = {
    Name = "ResouledAfterlifeFog",

    OriginalRadius = 150,

    CenterPos = Vector.Zero,
    Radius = 0,
    Time = 0,
    CameraPos = Vector.Zero,
    Active = true
}

Resouled:AddCallback(ModCallbacks.MC_GET_SHADER_PARAMS, function(_, shaderName)
    if shaderName ~= config.Name then return end
    if Resouled.AfterlifeShop.ShadowFight.Active then
        return {
            CenterPos = { config.CenterPos.X, config.CenterPos.Y },
            Radius = config.Radius,
            Time = config.Time,
            CameraPos = { config.CameraPos.X, config.CameraPos.Y },
            Active = config.Active and 1 or 0
        }
    else
        return {
            CenterPos = Vector.Zero,
            Radius = 0,
            Time = 0,
            CameraPos = Vector.Zero,
            Active = 0
        }
    end
end)

Resouled:AddCallback(ModCallbacks.MC_POST_RENDER, function()
    if config.Active then
        config.CenterPos = Isaac.WorldToScreen(g:GetRoom():GetCenterPos())
        config.Radius = math.max(config.OriginalRadius, 0)
        config.Time = g:GetFrameCount() / 30.0
        config.CameraPos = -Isaac.WorldToScreen(Vector.Zero)
    end
end)

--[[
Resouled:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
    local center = g:GetRoom():GetCenterPos()
    local radius = config.Radius * 1.5
    ---@param player EntityPlayer
    Resouled.Iterators:IterateOverPlayers(function(player)
        local distance = player.Position:Distance(center) - player.Size
        if distance > radius then
            player.Velocity = player.Velocity/1.5 + (center - player.Position):Resized(distance - radius)/2
        end
    end)
end)
]]--