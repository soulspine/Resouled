local colors = {
    NotComplete = KColor(1, 0, 0, 1),
    InProgress = KColor(1, 1, 0, 1),
    Complete = KColor(0, 1, 0, 1)
}

Resouled:AddSocialGoal(
    {
        DisplayText = "Don't deal damage to the boss the first 10 seconds",
        Tasks = {
            {
                Callback = ModCallbacks.MC_POST_UPDATE,
                Func = function()
                    if Game():GetRoom():GetType() == RoomType.ROOM_BOSS then
                        local save = Resouled.SaveManager.GetFloorSave()["Social Goals"]
                        if not save["Don't deal damage to the boss the first 10 seconds"] then
                            save["Don't deal damage to the boss the first 10 seconds"] = 0
                        end

                        if save["Don't deal damage to the boss the first 10 seconds"] > -1 then
                            save["Don't deal damage to the boss the first 10 seconds"] = math.min(save["Don't deal damage to the boss the first 10 seconds"] + 1, 300)
                        end
                    end
                end
            },
            {
                Callback = ModCallbacks.MC_POST_ENTITY_TAKE_DMG,
                Func = function(_, en, _, _, source)
                    ---@type EntityNPC | nil
                    local npc = en:ToNPC()
                    if npc and npc:IsBoss() and source and source.Entity and Resouled:TryFindPlayerSpawner(source.Entity) then
                        local save = Resouled.SaveManager.GetFloorSave()["Social Goals"]["Don't deal damage to the boss the first 10 seconds"]
                        if save < 300 then
                            save["Don't deal damage to the boss the first 10 seconds"] = -1
                        end
                    end
                end
            }
        },
        Goal = function()
            local save = Resouled.SaveManager.GetFloorSave()["Social Goals"]["Don't deal damage to the boss the first 10 seconds"] or 0
            return (save > -1) and
            {Text = tostring(math.floor(save/3)).."%", Color = (save == 0 and colors.NotComplete) or (save == 300 and colors.Complete) or colors.InProgress}
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
                        local save = Resouled.SaveManager.GetFloorSave()["Social Goals"]
                        if not save["Don't enter treasure room and shop"] then
                            save["Don't enter treasure room and shop"] = true
                        end
                    end
                end
            }
        },
        Goal = function()
            local x = Resouled.SaveManager.GetFloorSave()["Social Goals"]["Don't enter treasure room and shop"] == nil and "Condition Met" or "Failed"
            return {Text = x, Color = x == "Condition Met" and colors.Complete or colors.NotComplete}
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
                    local save = Resouled.SaveManager.GetFloorSave()["Social Goals"]
                    if not save["Leave a visited room uncleared"] then
                        save["Leave a visited room uncleared"] = {}
                    end

                    save["Leave a visited room uncleared"][tostring(roomDesc.SafeGridIndex)] = not room:IsClear()
                end
            }
        },
        Goal = function()
            local save = Resouled.SaveManager.GetFloorSave()["Social Goals"]["Leave a visited room uncleared"] or {}
            for _, condition in pairs(save) do
                if condition == true then
                    return {Text = "Condition Met", Color = colors.Complete}
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
        DisplayText = "Clear a room without firing a tear",
        Tasks = {
            {
                Callback = ModCallbacks.MC_POST_NEW_ROOM,
                Func = function()
                    local save = Resouled.SaveManager.GetFloorSave()["Social Goals"]
                    if not save["Clear a room without firing a tear"] then
                        save["Clear a room without firing a tear"] = false
                    end
                    ---@param player EntityPlayer
                    Resouled.Iterators:IterateOverPlayers(function(player)
                        player:GetData().Resouled_NotFiredTearThisRoom = true
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
                Callback = ModCallbacks.MC_PRE_NEW_ROOM,
                Func = function()
                    ---@param player EntityPlayer
                    Resouled.Iterators:IterateOverPlayers(function(player)
                        local data = player:GetData()
                        if data.Resouled_NotFiredTearThisRoom and data.Resouled_NotFiredTearThisRoom == true then
                            Resouled.SaveManager.GetFloorSave()["Social Goals"]["Clear a room without firing a tear"] = true
                        end
                    end)
                end
            }
        },
        Goal = function()
            local x = (Resouled.SaveManager.GetFloorSave()["Social Goals"]["Clear a room without firing a tear"] or false) and "Condition not Met" or "Completed"
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
                Callback = ModCallbacks.MC_POST_ENTITY_TAKE_DMG,
                Func = function(_, en, amount)
                    if en.HitPoints - amount <= 0 then
                        
                        local save = Resouled.SaveManager.GetFloorSave()["Social Goals"]
                        local frameCount = Game():GetFrameCount()
                        if not save["Kill 2 enemies at the same time"] then
                            save["Kill 2 enemies at the same time"] = {
                                LastKill = frameCount,
                                Complete = false
                            }
                        end
                        
                        if frameCount == save["Kill 2 enemies at the same time"].LastKill then
                            save["Kill 2 enemies at the same time"].Complete = true
                        end
                        
                        save["Kill 2 enemies at the same time"].LastKill = frameCount
                    end
                end
            }
        },
        Goal = function()
            local save = Resouled.SaveManager.GetFloorSave()["Social Goals"]["Kill 2 enemies at the same time"]
            if save then
                local x = save.Complete == true and "Complete" or "Not Complete"
                return {Text = x, Color = x == "Complete" and colors.Complete or colors.NotComplete}
            end
            return {Text = "Not Complete", Color = colors.NotComplete}
        end
    }
)