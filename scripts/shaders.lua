local x = 0
local maxAuraSize = 0 --20

Resouled:AddCallback(ModCallbacks.MC_GET_SHADER_PARAMS, function(_, shaderName)
    if shaderName == 'ResouledBlankCanvas' then
        local player = Isaac.GetPlayer()
        local position = Isaac.WorldToScreen(player.Position + Vector(0, -player.Size * 1.5))
        x = math.min(x + 1, (maxAuraSize + x)/2)
        return {
            PointPos = {
                position.X,
                position.Y
            },
            AreaSize = math.log(x) * x
        }
    end
end)