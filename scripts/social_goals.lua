local colors = {
    NotComplete = KColor(1, 0, 0, 1),
    InProgress = KColor(1, 1, 0, 1),
    Complete = KColor(0, 1, 0, 1),
    ConditionMet = KColor(0, 1, 1, 1)
}

Resouled:AddSocialGoal(
    {
        DisplayText = "Don't deal damage to the boss the first 10 seconds",
        Tasks = {
            {
                Callback = ModCallbacks.MC_POST_UPDATE,
                Func = function()
                    if Game():GetRoom():GetType() == RoomType.ROOM_BOSS then
                        local save = Resouled.SaveManager.GetFloorSave()["Social Goals Saves"]
                        if not save then save = {} end
 
                        if not save["Dont deal damage to the boss the first 10 seconds"] then
                            save["Dont deal damage to the boss the first 10 seconds"] = 0
                            
                        end

                        if save["Dont deal damage to the boss the first 10 seconds"] > -1 then
                            save["Dont deal damage to the boss the first 10 seconds"] = math.min(save["Dont deal damage to the boss the first 10 seconds"] + 1, 300)
                        end
                    end
                end
            },
            {
                Callback = ModCallbacks.MC_POST_ENTITY_TAKE_DMG,
                Func = function(_, en, _, _, source)
                    if not Game():GetRoom():GetType() == RoomType.ROOM_BOSS then return end
                    ---@type EntityNPC | nil
                    local npc = en:ToNPC()
                    if npc and npc:IsBoss() and source and source.Entity and Resouled:TryFindPlayerSpawner(source.Entity) then
                        local save = Resouled.SaveManager.GetFloorSave()["Social Goals Saves"]
                        if not save then save = {} end

                        if save["Dont deal damage to the boss the first 10 seconds"] and save["Dont deal damage to the boss the first 10 seconds"] < 300 then
                            save["Dont deal damage to the boss the first 10 seconds"] = -1
                        end
                    end
                end
            }
        },
        Goal = function()
            local save = Resouled.SaveManager.GetFloorSave()["Social Goals Saves"]["Dont deal damage to the boss the first 10 seconds"] or 0
            return (save > -1 and save < 300) and
            {Text = tostring(math.floor(save/3)).."%", Color = (save == 0 and colors.NotComplete) or (save == 300 and colors.Complete) or colors.InProgress}
            or (save == 300) and {Text = "Completed", Color = colors.Complete}
            or {Text = "Failed", Color = colors.NotComplete}
        end
    }
)
---
---
---
---
---
Resouled:AddSocialGoal(
    {
        DisplayText = "Don't enter treasure room and shop",
        Tasks = {
            {
                Callback = ModCallbacks.MC_POST_NEW_ROOM,
                Func = function()
                    local roomType = Game():GetRoom():GetType()

                    if roomType == RoomType.ROOM_SHOP or roomType == RoomType.ROOM_TREASURE then
                        local save = Resouled.SaveManager.GetFloorSave()["Social Goals Saves"]
                        if not save then save = {} end

                        if not save["Don't enter treasure room and shop"] then
                            save["Don't enter treasure room and shop"] = true
                        end
                    end
                end
            }
        },
        Goal = function()
            local x = Resouled.SaveManager.GetFloorSave()["Social Goals Saves"]["Don't enter treasure room and shop"] == nil and "Condition Met" or "Failed"
            return {Text = x, Color = x == "Condition Met" and colors.ConditionMet or colors.NotComplete}
        end
    }
)
---
---
---
---
---
Resouled:AddSocialGoal(
    {
        DisplayText = "Leave a visited room uncleared",
        Tasks = {
            {
                Callback = ModCallbacks.MC_PRE_ROOM_EXIT,
                Func = function()
                    local room = Game():GetRoom()
                    local roomDesc = Game():GetLevel():GetCurrentRoomDesc()
                    local save = Resouled.SaveManager.GetFloorSave()["Social Goals Saves"]
                    if not save then save = {} end
 
                    if not save["Leave a visited room uncleared"] then
                        save["Leave a visited room uncleared"] = {}
                    end

                    save["Leave a visited room uncleared"][tostring(roomDesc.SafeGridIndex)] = not room:IsClear()
                end
            }
        },
        Goal = function()
            local save = Resouled.SaveManager.GetFloorSave()["Social Goals Saves"]["Leave a visited room uncleared"] or {}
            for _, condition in pairs(save) do
                if condition == true then
                    return {Text = "Condition Met", Color = colors.ConditionMet}
                end
            end
            return {Text = "Condition not Met", Color = colors.NotComplete}
        end
    }
)
---
---
---
---
---
Resouled:AddSocialGoal(
    {
        DisplayText = "Clear a room without firing",
        Tasks = {
            {
                Callback = ModCallbacks.MC_POST_NEW_ROOM,
                Func = function()
                    local save = Resouled.SaveManager.GetFloorSave()["Social Goals Saves"]
                    if not save then save = {} end

                    if not save["Clear a room without firing"] then
                        save["Clear a room without firing"] = false
                        
                    end

                    local room = Game():GetRoom()

                    ---@param player EntityPlayer
                    Resouled.Iterators:IterateOverPlayers(function(player)
                        player:GetData().Resouled_NotFiredTearThisRoom = not room:IsClear()
                    end)
                end
            },
            {
                Callback = ModCallbacks.MC_POST_FIRE_TEAR,
                Func = function(_, tear)
                    local player = Resouled:TryFindPlayerSpawner(tear)
                    if player then
                        player:GetData().Resouled_NotFiredTearThisRoom = false
                    end
                end
            },
            {
                Callback = ModCallbacks.MC_POST_FIRE_BRIMSTONE,
                Func = function(_, tear)
                    local player = Resouled:TryFindPlayerSpawner(tear)
                    if player then
                        player:GetData().Resouled_NotFiredTearThisRoom = false
                    end
                end
            },
            {
                Callback = ModCallbacks.MC_POST_FIRE_KNIFE,
                Func = function(_, tear)
                    local player = Resouled:TryFindPlayerSpawner(tear)
                    if player then
                        player:GetData().Resouled_NotFiredTearThisRoom = false
                    end
                end
            },
            {
                Callback = ModCallbacks.MC_POST_FIRE_SWORD,
                Func = function(_, tear)
                    local player = Resouled:TryFindPlayerSpawner(tear)
                    if player then
                        player:GetData().Resouled_NotFiredTearThisRoom = false
                    end
                end
            },
            {
                Callback = ModCallbacks.MC_POST_ROOM_TRIGGER_CLEAR,
                Func = function()
                    ---@param player EntityPlayer
                    Resouled.Iterators:IterateOverPlayers(function(player)
                        local data = player:GetData()
                        if data.Resouled_NotFiredTearThisRoom and data.Resouled_NotFiredTearThisRoom == true then
                            Resouled.SaveManager.GetFloorSave()["Social Goals Saves"]["Clear a room without firing"] = true
                        end
                    end)
                end
            }
        },
        Goal = function()
            local x = (Resouled.SaveManager.GetFloorSave()["Social Goals Saves"]["Clear a room without firing"] or false) and "Completed" or "Condition not Met"
            return {Text = x, Color = x == "Condition not Met" and colors.NotComplete or colors.Complete}
        end
    }
)
---
---
---
---
---
Resouled:AddSocialGoal(
    {
        DisplayText = "Kill 2 enemies at the same time",
        Tasks = {
            {
                Callback = ModCallbacks.MC_POST_ENTITY_KILL,
                Func = function(_, en)
                    ---@type EntityNPC | nil
                    local npc = en:ToNPC()
                    if npc and npc:IsEnemy() and npc:IsActiveEnemy(true) then
                        
                        local save = Resouled.SaveManager.GetFloorSave()["Social Goals Saves"]
                        if not save then save = {} end

                        local frameCount = Game():GetFrameCount()
                        if not save["Kill 2 enemies at the same time"] then
                            save["Kill 2 enemies at the same time"] = {
                                ["Last Kill"] = 0,
                                ["Complete"] = false
                            }
                            
                        end
                        
                        if frameCount - save["Kill 2 enemies at the same time"]["Last Kill"] < 5 then
                            save["Kill 2 enemies at the same time"]["Complete"] = true
                        end
                        
                        save["Kill 2 enemies at the same time"]["Last Kill"] = frameCount
                    end
                end
            }
        },
        Goal = function()
            local save = Resouled.SaveManager.GetFloorSave()["Social Goals Saves"]["Kill 2 enemies at the same time"]
            if save then
                local x = save["Complete"] == true and "Completed" or "Not Completed"
                return {Text = x, Color = x == "Completed" and colors.Complete or colors.NotComplete}
            end
            return {Text = "Not Completed", Color = colors.NotComplete}
        end
    }
)
---
---
---
---
---
Resouled:AddSocialGoal(
    {
        DisplayText = "Don't enter a deal room",
        Tasks = {
            {
                Callback = ModCallbacks.MC_POST_NEW_ROOM,
                Func = function()
                    local roomType = Game():GetRoom():GetType()

                    if roomType == RoomType.ROOM_ANGEL or roomType == RoomType.ROOM_DEVIL then
                        local save = Resouled.SaveManager.GetFloorSave()["Social Goals Saves"]
                        if not save then save = {} end

                        if not save["Dont enter a deal"] then
                            save["Dont enter a deal"] = true
                        end
                    end
                end
            }
        },
        Goal = function()
            local x = Resouled.SaveManager.GetFloorSave()["Social Goals Saves"]["Dont enter a deal"] == nil and "Condition Met" or "Failed"
            return {Text = x, Color = x == "Condition Met" and colors.ConditionMet or colors.NotComplete}
        end
    }
)