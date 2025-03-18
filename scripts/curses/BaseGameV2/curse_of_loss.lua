local SFX_LEFT = SoundEffect.SOUND_CHARACTER_SELECT_LEFT
local SFX_RIGHT = SoundEffect.SOUND_CHARACTER_SELECT_RIGHT

local CURSE_MESSAGE=  "Curse of Loss - Choose a soul to lose"

local TEXT_GAP = 20
local TEXT_COLOR = KColor(1, 1, 1, 1)
local TEXT_SCALE = Vector(0.5, 0.5)

local render = false
local soulString
local font = Font()
font:Load("font/upheaval.fnt")

local function onNewFloor()
    if Resouled:CustomCursePresent(Resouled.Curses.CURSE_OF_LOSS) then
        local roomSave = SAVE_MANAGER.GetRoomSave()
        if Resouled:GetPossessedSoulsNum() > 0 then

            Resouled:SelectCard(Resouled:GetLowestPossesedSoulIndex())
            soulString = Resouled:GetSelectedCardName()
            print(Resouled:GetSelectedCardIndex())
            roomSave.CurseOfLoss = {
                ChoosingSoul = true,
                SelectionChangeCooldown = 0,
            }
        end
        Resouled:ForceShutDoors()
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, onNewFloor)

local function onUpdate()
    local roomSave = SAVE_MANAGER.GetRoomSave()
    local sfx = SFXManager()
    if Resouled:CustomCursePresent(Resouled.Curses.CURSE_OF_LOSS) and roomSave.CurseOfLoss then
        render = true
        ---@param player EntityPlayer
        Resouled:IterateOverPlayers(function(player)
            player:AddControlsCooldown(2)
        end)
        
        
        if roomSave.CurseOfLoss.SelectionChangeCooldown > 0 then 
            roomSave.CurseOfLoss.SelectionChangeCooldown = roomSave.CurseOfLoss.SelectionChangeCooldown - 1
        end

        local pressingLeft = Resouled:IsAnyonePressingAction(ButtonAction.ACTION_LEFT)
        local pressingRight = Resouled:IsAnyonePressingAction(ButtonAction.ACTION_RIGHT)

        if roomSave.CurseOfLoss.SelectionChangeCooldown == 0 and (pressingLeft or pressingRight) then
            if pressingLeft then
                Resouled:SelectPreviousCard()
                sfx:Play(SFX_LEFT)
            elseif pressingRight then
                Resouled:SelectNextCard()
                sfx:Play(SFX_RIGHT)
            end
            soulString = Resouled:GetSelectedCardName()
            roomSave.CurseOfLoss.SelectionChangeCooldown = 4
        end

        if Resouled:IsAnyonePressingAction(ButtonAction.ACTION_ITEM) then
            local selectedIndex = Resouled:GetSelectedCardIndex()
            if selectedIndex then
                Resouled:TryRemoveSoulFromPossessed(selectedIndex)
                Resouled:ResetCardSelection()
                roomSave.CurseOfLoss = nil
                Resouled:ForceOpenDoors()
            end
        end
    else render = false
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_UPDATE, onUpdate)

local function onRender()
    if render then
        local screenDimensions = Resouled:GetScreenDimensions()
        font:DrawStringScaledUTF8(CURSE_MESSAGE, screenDimensions.X / 2, (screenDimensions.Y - TEXT_GAP) / 2, TEXT_SCALE.X, TEXT_SCALE.Y, TEXT_COLOR, 5, true)
        if soulString then
            font:DrawStringScaledUTF8(soulString, screenDimensions.X / 2, (screenDimensions.Y + TEXT_GAP) / 2, TEXT_SCALE.X, TEXT_SCALE.Y, TEXT_COLOR, 5, true)
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_RENDER, onRender)