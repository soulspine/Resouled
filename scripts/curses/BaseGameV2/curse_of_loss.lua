local CARD_EXTEND_DURATION = 100

local function onNewFloor()
    if Resouled:CustomCursePresent(Resouled.Curses.CURSE_OF_LOSS) then
        local roomSave = SAVE_MANAGER.GetRoomSave()
        if Resouled:GetPossessedSoulsNum() > 0 then
            roomSave.ChoosingSoul = true
            roomSave.ChosenSoul = Resouled:GetLowestPossesedSoulIndex()
            roomSave.ChooseCooldown = 0
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, onNewFloor)

local function onUpdate()
    local runSave = SAVE_MANAGER.GetRunSave()
    local roomSave = SAVE_MANAGER.GetRoomSave()
    local sfx = SFXManager()
    if Resouled:CustomCursePresent(Resouled.Curses.CURSE_OF_LOSS) and roomSave.ChoosingSoul then
        Resouled:MakeCardsExpandForDuration(CARD_EXTEND_DURATION)
        ---@param player EntityPlayer
        Resouled:IterateOverPlayers(function(player)
            if roomSave.ChoosingSoul then 
                player:AddControlsCooldown(2)
            end
        end)
        
        if roomSave.ChooseCooldown > 0 then 
            roomSave.ChooseCooldown = roomSave.ChooseCooldown - 1
        end

        if Resouled:IsAnyonePressingAction(ButtonAction.ACTION_LEFT) and roomSave.ChooseCooldown == 0 then
            roomSave.ChosenSoul = roomSave.ChosenSoul - 1
            roomSave.ChooseCooldown = 6
            if Resouled:GetPossessedSouls()[roomSave.ChosenSoul] == nil then
                roomSave.ChosenSoul = roomSave.ChosenSoul - 1
                if Resouled:GetPossessedSouls()[roomSave.ChosenSoul] == nil then
                    roomSave.ChosenSoul = roomSave.ChosenSoul - 1
                    if Resouled:GetPossessedSouls()[roomSave.ChosenSoul] == nil then
                        roomSave.ChosenSoul = Resouled:GetLowestPossesedSoulIndex()
                    end
                end
            end
            if roomSave.ChosenSoul < Resouled:GetLowestPossesedSoulIndex() then
                roomSave.ChosenSoul = Resouled:GetLowestPossesedSoulIndex()
            else
                sfx:Play(SoundEffect.SOUND_CHARACTER_SELECT_LEFT)
            end
        elseif Resouled:IsAnyonePressingAction(ButtonAction.ACTION_RIGHT) and roomSave.ChooseCooldown == 0 then
            roomSave.ChosenSoul = roomSave.ChosenSoul + 1
            roomSave.ChooseCooldown = 6
            if Resouled:GetPossessedSouls()[roomSave.ChosenSoul] == nil then
                roomSave.ChosenSoul = roomSave.ChosenSoul + 1
                if Resouled:GetPossessedSouls()[roomSave.ChosenSoul] == nil then
                    roomSave.ChosenSoul = roomSave.ChosenSoul + 1
                    if Resouled:GetPossessedSouls()[roomSave.ChosenSoul] == nil then
                        roomSave.ChosenSoul = Resouled:GetHighestPossesedSoulIndex()
                    end
                end
            end
            if roomSave.ChosenSoul > Resouled:GetHighestPossesedSoulIndex() then
                roomSave.ChosenSoul = Resouled:GetHighestPossesedSoulIndex()
            else 
                sfx:Play(SoundEffect.SOUND_CHARACTER_SELECT_RIGHT)
            end
        end

        if Resouled:IsAnyonePressingAction(ButtonAction.ACTION_ITEM) then
            if Resouled:GetPossessedSouls()[roomSave.ChosenSoul] == nil then
                sfx:Play(SoundEffect.SOUND_DOGMA_GODHEAD)
            else
                Resouled:TryRemoveSoulFromPossessed(roomSave.ChosenSoul)
                roomSave.ChoosingSoul = nil
                sfx:Play(SoundEffect.SOUND_BEAST_GHOST_DASH, 1.2)
            end
        end

        print(roomSave.ChosenSoul)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_UPDATE, onUpdate)