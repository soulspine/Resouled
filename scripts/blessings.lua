---@enum ResouledBlessing
Resouled.Blessings = {
    Samson = 1,
    Maggy = 2,
    Isaac = 4,
}
-- next blessings have to have id being a binary shift: eg. 1, 2, 4, 8, 6, 32, 64, 128 ... 

local SFX_GRANT_VOLUME = 0.7

---@param player EntityPlayer
local function createPlayerBlessingsContainer(_, player)
    local playerRunSave = SAVE_MANAGER.GetRunSave(player)
    if not playerRunSave.Blessings then
        playerRunSave.Blessings = {
            Obtained = 0
        }
    end 
end
Resouled:AddPriorityCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, CallbackPriority.IMPORTANT, createPlayerBlessingsContainer)



--- Checks if the player has a specific blessing.
---@param player EntityPlayer
---@param blessing ResouledBlessing
---@return boolean
function Resouled:HasBlessing(player, blessing)
    local playerRunSave = SAVE_MANAGER.GetRunSave(player)

    if not playerRunSave.Blessings then
        return false
    end

    return playerRunSave.Blessings.Obtained & blessing == blessing
end



--- Grants a blessing to the player if they don't have it yet.
---@param player EntityPlayer
---@param blessing ResouledBlessing
function Resouled:GrantBlessing(player, blessing)
    if not Resouled:HasBlessing(player, blessing) then

        --TODO REPLACE THIS PLACEHOLDER DISPLAY
        for blesser, id in pairs(Resouled.Blessings) do
            if id == blessing then
                Game():GetHUD():ShowFortuneText("You've been blessed", "by " .. blesser)
                SFXManager():Play(SoundEffect.SOUND_SUPERHOLY, SFX_GRANT_VOLUME)
                break
            end
        end

        local playerRunSave = SAVE_MANAGER.GetRunSave(player)
        playerRunSave.Blessings.Obtained = playerRunSave.Blessings.Obtained | blessing
    end
end



function Resouled:RemoveBlessing(player, blessing)
    if Resouled:HasBlessing(player, blessing) then
        local playerRunSave = SAVE_MANAGER.GetRunSave(player)
        playerRunSave.Blessings.Obtained = playerRunSave.Blessings.Obtained & ~blessing
    end
end

-- Base Game V2
-- Four Souls V2
-- Requiem
include("scripts.blessings.Requiem.isaac")
include("scripts.blessings.Requiem.maggy")
include("scripts.blessings.Requiem.samson")
-- Summer Of Isaac
-- Promotional Sets