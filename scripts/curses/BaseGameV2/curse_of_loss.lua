local function onNewFloor()
    if Resouled:CustomCursePresent(Resouled.Curses.CURSE_OF_LOSS) then
        ---@param player EntityPlayer
        Resouled:IterateOverPlayers(function(player)
            local roomSave = SAVE_MANAGER.GetRoomSave()
            local runSave = SAVE_MANAGER.GetRunSave()

            if runSave.Souls == nil then
                return
            end

            local canChoose = false
            for _ = 1, 4 do
                if runSave.Souls[_] ~= nil then
                    canChoose = true
                end
            end
            if canChoose then
                if not roomSave.ChoosingSoul then 
                    roomSave.ChoosingSoul = false
                end
    
                roomSave.ChoosingSoul = true
    
                if not roomSave.ChosenSoul then
                    roomSave.ChosenSoul = 1
                end
            end
        end)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, onNewFloor)

local function onUpdate()
    if Resouled:CustomCursePresent(Resouled.Curses.CURSE_OF_LOSS) then
        ---@param player EntityPlayer
        Resouled:IterateOverPlayers(function(player)
            local roomSave = SAVE_MANAGER.GetRoomSave()
            local runSave = SAVE_MANAGER.GetRunSave()
            if roomSave.ChoosingSoul then
                player:AddControlsCooldown(2)

                if not roomSave.ChooseCooldown then
                    roomSave.ChooseCooldown = 0
                end

                local input = 0
                if Input.IsActionPressed(ButtonAction.ACTION_UP, 0) and roomSave.ChooseCooldown == 0 then
                    input = -1
                elseif Input.IsActionPressed(ButtonAction.ACTION_DOWN, 0) and roomSave.ChooseCooldown == 0 then
                    input = 1
                end

                local chosen = 0
                if Input.IsActionPressed(ButtonAction.ACTION_ITEM, 0) then
                    chosen = 1
                end

                if chosen == 1 and runSave.Souls[roomSave.ChosenSoul] ~= nil then
                    runSave.Souls[roomSave.ChosenSoul] = nil
                    for _ = 1, 4 do
                        print(runSave.Souls[_])
                    end
                    roomSave.ChoosingSoul = false
                end

                roomSave.ChosenSoul = roomSave.ChosenSoul + input

                if roomSave.ChosenSoul < 1 then
                    roomSave.ChosenSoul = #runSave.Souls
                elseif roomSave.ChosenSoul > #runSave.Souls then
                    roomSave.ChosenSoul = 1
                end

                if input ~= 0 then
                    roomSave.ChooseCooldown = 8
                end

                if roomSave.ChooseCooldown ~= 0 then
                    roomSave.ChooseCooldown = roomSave.ChooseCooldown - 1
                end
            end
        end)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_UPDATE, onUpdate)

local function onRender()
    if Resouled:CustomCursePresent(Resouled.Curses.CURSE_OF_LOSS) then
        local roomSave = SAVE_MANAGER.GetRoomSave()
        local runSave = SAVE_MANAGER.GetRunSave()
        local font = Font()
        if roomSave.ChoosingSoul then
            if not font:IsLoaded() then
                font:Load("font/terminus.fnt")
            end

            if roomSave.ChosenSoul then
                local string1 = roomSave.ChosenSoul - 1
                local string2 = roomSave.ChosenSoul
                local string3 = roomSave.ChosenSoul + 1
                if string1 < 1 then
                    string1 = #runSave.Souls
                end

                if string2 > #runSave.Souls then
                    string2 = 1
                end

                if string3 > #runSave.Souls then
                    string3 = 1
                end

                font:DrawStringScaled("Press Active Item use button to confirm", Isaac.GetScreenWidth()/2, Isaac.GetScreenHeight()/2 - 30, 0.75, 0.75, KColor(1,1,0,0.25), 1, true)
                if runSave.Souls[string1] ~= nil then
                    font:DrawStringScaled(runSave.Souls[string1], Isaac.GetScreenWidth()/2, Isaac.GetScreenHeight()/2 - 15, 0.75, 0.75, KColor(0,0,0,0.5), 1, true)
                end
                if runSave.Souls[string2] ~= nil then
                    font:DrawString("Delete soul: "..runSave.Souls[string2], Isaac.GetScreenWidth()/2, Isaac.GetScreenHeight()/2, KColor(1,0,0,1), 1, true)
                end
                if runSave.Souls[string3] ~= nil then
                    font:DrawStringScaled(runSave.Souls[string3], Isaac.GetScreenWidth()/2, Isaac.GetScreenHeight()/2 + 15, 0.75, 0.75, KColor(0,0,0,0.5), 1, true)
                end
            end
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_RENDER, onRender)