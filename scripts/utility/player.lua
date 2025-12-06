---@class PlayerModule
local playerModule = {}
local MOD = Resouled

---@param player EntityPlayer
function playerModule:IsUsingGamepad(player)
    return player.ControllerIndex ~= 0
end

---@param player EntityPlayer
function playerModule:IsUsingKeyboard(player)
    return not playerModule:IsUsingGamepad(player)
end

--- Grants a temporary heart container, it will be cleared upon leaving the current room.
---@param player EntityPlayer
---@param overcap? boolean default: `true` - Whether it should ignore the heart cap
function playerModule:Grant1RoomHeartContainer(player, overcap)
    if overcap == nil then overcap = true end

    local data = player:GetData()
    if not data.Temporary_Heart_Container_Remove_Me_After_This_Room_Is_This_Name_Unique_Enough_Question_Mark then
        data.Temporary_Heart_Container_Remove_Me_After_This_Room_Is_This_Name_Unique_Enough_Question_Mark = {}
    end

    table.insert(data.Temporary_Heart_Container_Remove_Me_After_This_Room_Is_This_Name_Unique_Enough_Question_Mark,
        { Overcap = overcap })
    player:AddMaxHearts(2)
    player:AddHearts(2)
end

---@param player EntityPlayer
---@param newLevel boolean
local function removeTemporaryContainerOnRoomExit(_, player, newLevel)
    -- triggers before exiting to main menu as well
    local data = player:GetData()

    if not data.Temporary_Heart_Container_Remove_Me_After_This_Room_Is_This_Name_Unique_Enough_Question_Mark then return end
    for _, _ in ipairs(data.Temporary_Heart_Container_Remove_Me_After_This_Room_Is_This_Name_Unique_Enough_Question_Mark) do
        print("removeing")
        player:AddMaxHearts(-2)
    end
    data.Temporary_Heart_Container_Remove_Me_After_This_Room_Is_This_Name_Unique_Enough_Question_Mark = nil
end
MOD:AddCallback(ModCallbacks.MC_PRE_ROOM_EXIT, removeTemporaryContainerOnRoomExit)

---@param player EntityPlayer
---@param limit integer
---@param isKeeper boolean
local function heartLimit(_, player, limit, isKeeper)
    local data = player:GetData()
    if not data.Temporary_Heart_Container_Remove_Me_After_This_Room_Is_This_Name_Unique_Enough_Question_Mark then return end

    for _, c in ipairs(data.Temporary_Heart_Container_Remove_Me_After_This_Room_Is_This_Name_Unique_Enough_Question_Mark) do
        if c.Overcap then
            limit = limit + 2
        end
    end
    return limit
end
MOD:AddCallback(ModCallbacks.MC_PLAYER_GET_HEART_LIMIT, heartLimit)

return playerModule
