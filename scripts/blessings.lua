---@enum ResouledBlessing
Resouled.Blessings = {
    SAMSON = 1,
}
-- next blessings have to have id being a binary shift: eg. 1, 2, 4, 8, 6, 32, 64, 128 ... 



---@param player EntityPlayer
local function createPlayerBlessingsContainer(_, player)
    local playerRunSave = SAVE_MANAGER.GetRunSave(player)
    playerRunSave.Blessings = {
        Obtained = 0
    }
end
Resouled:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, createPlayerBlessingsContainer)



--- Checks if the player has a specific blessing.
---@param player EntityPlayer
---@param blessing ResouledBlessing
---@return boolean
function Resouled:HasBlessing(player, blessing)
    local playerRunSave = SAVE_MANAGER.GetRunSave(player)
    return playerRunSave.Blessings.Obtained & blessing == blessing
end



--- Grants a blessing to the player if they don't have it yet.
---@param player EntityPlayer
---@param blessing ResouledBlessing
function Resouled:GrantBlessing(player, blessing)
    if not Resouled:HasBlessing(player, blessing) then

        --TODO REPLACE THIS PLACEHOLDER DISPLAY
        Game():GetHUD():ShowFortuneText("Blessing granted", tostring(blessing))

        local playerRunSave = SAVE_MANAGER.GetRunSave(player)
        playerRunSave.Blessings.Obtained = playerRunSave.Blessings.Obtained | blessing

        local globalRunSave = SAVE_MANAGER.GetRunSave()
        if globalRunSave.Blessings then
            if globalRunSave.Blessings[blessing] then
                table.insert(globalRunSave.Blessings[blessing], EntityRef(player))
            else
                globalRunSave.Blessings[blessing] = {EntityRef(player)}
            end
        else
            globalRunSave.Blessings = {
                [blessing] = {EntityRef(player)}
            }
        end
    end
end



function Resouled:RemoveBlessing(player, blessing)
    if Resouled:HasBlessing(player, blessing) then
        local playerRunSave = SAVE_MANAGER.GetRunSave(player)
        playerRunSave.Blessings.Obtained = playerRunSave.Blessings.Obtained & ~blessing
    
        local globalRunSave = SAVE_MANAGER.GetRunSave()
        if globalRunSave.Blessings then
            if globalRunSave.Blessings[blessing] then
                for i, playerRef in ipairs(globalRunSave.Blessings[blessing]) do
                    if playerRef:ToPlayer() == player then
                        table.remove(globalRunSave.Blessings[blessing], i)
                        break
                    end
                end
            end
        end

    end
end

include("scripts.blessings.samson")