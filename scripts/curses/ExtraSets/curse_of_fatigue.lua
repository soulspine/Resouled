local mapId = Resouled.CursesMapId[Resouled.Curses.CURSE_OF_FATIGUE]

MinimapAPI:AddMapFlag(
    mapId,
    function()
        return Resouled:CustomCursePresent(Resouled.Curses.CURSE_OF_FATIGUE)
    end,
    Resouled.CursesSprite,
    mapId,
    1
)

---@param player EntityPlayer
local function prePlayerUpdate(_, player)
    local FLOOR_SAVE_MANAGER = SAVE_MANAGER.GetFloorSave()
    if Resouled:CustomCursePresent(Resouled.Curses.CURSE_OF_FATIGUE) then

        if not FLOOR_SAVE_MANAGER.ResouledCurseOfFatigue then
            FLOOR_SAVE_MANAGER.ResouledCurseOfFatigue = 0
        end

        if not player:GetData().ResouledCurseOfFatigue then
            player:GetData().ResouledCurseOfFatigue = {}
        end

        if not player:GetData().ResouledCurseOfFatigue then
            player:GetData().ResouledCurseOfFatigue = {}
        end

        for i = 0, 3 do
            player:GetData().ResouledCurseOfFatigue[i] = player:GetActiveCharge(i)
        end
    else
        if FLOOR_SAVE_MANAGER.ResouledCurseOfFatigue then
            FLOOR_SAVE_MANAGER.ResouledCurseOfFatigue = nil
        end

        if player:GetData().ResouledCurseOfFatigue then
            player:GetData().ResouledCurseOfFatigue = nil
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_PLAYER_UPDATE, prePlayerUpdate)

local function preClearReward()
    if Resouled:CustomCursePresent(Resouled.Curses.CURSE_OF_FATIGUE) then
        local FLOOR_SAVE_MANAGER = SAVE_MANAGER.GetFloorSave()

        if FLOOR_SAVE_MANAGER.ResouledCurseOfFatigue == 1 then
            ---@param player EntityPlayer
            Resouled:IterateOverPlayers(function(player)
                for i = 0, 3 do
                    if player:GetActiveCharge(i) ~= player:GetData().ResouledCurseOfFatigue[i] then
                        player:SetActiveCharge(player:GetActiveCharge(i)-1, i)
                        if SFXManager():IsPlaying(SoundEffect.SOUND_BEEP) then
                            SFXManager():Stop(SoundEffect.SOUND_BEEP)
                        end
                        
                        if SFXManager():IsPlaying(SoundEffect.SOUND_BATTERYCHARGE) then
                            SFXManager():Stop(SoundEffect.SOUND_BATTERYCHARGE)
                        end

                        FLOOR_SAVE_MANAGER.ResouledCurseOfFatigue = 0
                    end
                end
            end)
        else
            FLOOR_SAVE_MANAGER.ResouledCurseOfFatigue = FLOOR_SAVE_MANAGER.ResouledCurseOfFatigue + 1
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, preClearReward)