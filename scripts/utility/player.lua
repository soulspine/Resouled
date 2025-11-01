---@class PlayerModule
local playerModule = {}

---@param player EntityPlayer
function playerModule:IsUsingGamepad(player)
    return player.ControllerIndex ~= 0
end

---@param player EntityPlayer
function playerModule:IsUsingKeyboard(player)
    return not playerModule:IsUsingGamepad(player)
end

return playerModule
