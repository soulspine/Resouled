Resouled.AfterlifeShop.Theme = Isaac.GetMusicIdByName("Goodbye Cruel World")

local function postNewLevel()
    if Resouled.AfterlifeShop:IsAfterlifeShop() then
        MusicManager():Fadein(Resouled.AfterlifeShop.Theme, 1)
    end
end
Resouled:AddPriorityCallback(ModCallbacks.MC_POST_NEW_LEVEL, CallbackPriority.LATE, postNewLevel)

local function onUpdate()
    if Resouled.AfterlifeShop:IsAfterlifeShop() then
        local music = MusicManager()
        if music:GetCurrentMusicID() ~= Resouled.AfterlifeShop.Theme then
            Resouled.AfterlifeShop.Goto.ReplaceMusic = true
            music:Play(Resouled.AfterlifeShop.Theme, 1)
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_UPDATE, onUpdate)

---@param id Music
local function preMusicPlay(_, id)
    if Resouled.AfterlifeShop.Goto.ReplaceMusic == true or (not Isaac.IsInGame() and MenuManager:GetActiveMenu() == MainMenuType.TITLE) then
        if id ~= Resouled.AfterlifeShop.Theme then
            return false
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_MUSIC_PLAY, preMusicPlay)

local function postGameEnd()
    if Resouled.AfterlifeShop.Goto.ReplaceMusic == true and Resouled.AfterlifeShop.Goto.Activate == false then
        Resouled.AfterlifeShop.Goto.ReplaceMusic = false
    end
end
Resouled:AddPriorityCallback(ModCallbacks.MC_POST_GAME_END, CallbackPriority.IMPORTANT, postGameEnd)

Resouled:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, postGameEnd)