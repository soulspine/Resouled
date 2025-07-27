Resouled.IsInMainMenu = false

local function postNewLevel()
    if Resouled.AfterlifeShop:IsAfterlifeShop() then
        MusicManager():Fadein(Resouled.AfterlifeShop.Themes.Main, 1)
    end
end
Resouled:AddPriorityCallback(ModCallbacks.MC_POST_NEW_LEVEL, CallbackPriority.LATE, postNewLevel)

local music = MusicManager()
local function onUpdate()
    if Resouled.AfterlifeShop:IsAfterlifeShop() then
        local currentTrack = music:GetCurrentMusicID()
        if currentTrack ~= Resouled.AfterlifeShop.Themes.Main and currentTrack ~= (Resouled.AfterlifeShop.Themes.Limbo or Resouled.AfterlifeShop.Themes.LimboTutorial) then
            Resouled.AfterlifeShop.Goto.ReplaceMusic = true
            music:Play(Resouled.AfterlifeShop.Themes.Main, 1)
        end

        if currentTrack == Music.MUSIC_NULL then
            Resouled.AfterlifeShop.Goto.ReplaceMusic = true
            music:Play(Resouled.AfterlifeShop.Themes.Main, 1)
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_UPDATE, onUpdate)

---@param id Music
local function preMusicPlay(_, id)
    if Resouled.AfterlifeShop.Goto.ReplaceMusic == true or (Resouled.IsInMainMenu and MenuManager:GetActiveMenu() == MainMenuType.TITLE) then
        if not Resouled.AfterlifeShop.Themes[id] then
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

Resouled:AddCallback(ModCallbacks.MC_POST_RENDER, function()
    if Resouled.IsInMainMenu == true then
        Resouled.IsInMainMenu = false
    end
end)

Resouled:AddCallback(ModCallbacks.MC_MAIN_MENU_RENDER, function()
    if Resouled.IsInMainMenu == false then
        Resouled.IsInMainMenu = true
    end
end)