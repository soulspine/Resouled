local ISAACS_LAST_WILL = Resouled.Enums.Items.ISAACS_LAST_WILL

local itemBlacklist = {
    [ISAACS_LAST_WILL] = true,
}

local game = Game()

---@param integer integer
local function makeLookupKey(integer)
    return tostring(integer)
end

local function postNewLevel()
    local RunSave = SAVE_MANAGER.GetRunSave()
    if not RunSave.WhatTimeStagesBeenEntered then
        RunSave.WhatTimeStagesBeenEntered = {}
    end

    RunSave.WhatTimeStagesBeenEntered[makeLookupKey(game:GetLevel():GetStage() - 1)] = game.TimeCounter
end
Resouled:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, postNewLevel)

---@return table
function Resouled:GetTimesStagesHaveBeenEntered()
    local RunSave = SAVE_MANAGER.GetRunSave()

    if not RunSave.WhatTimeStagesBeenEntered then
        RunSave.WhatTimeStagesBeenEntered = {}
    end

    return RunSave.WhatTimeStagesBeenEntered
end

---@param player EntityPlayer
---@return integer
local function getNextStageFromSave(player)
    local times = Resouled:GetTimesStagesHaveBeenEntered()
    local RunSave = SAVE_MANAGER.GetRunSave(player)

    if not RunSave.IsaacsLastWill then
        RunSave.IsaacsLastWill = 1
    end

    local nextStage = nil

    local i = RunSave.IsaacsLastWill + 1
    while not nextStage and i <= LevelStage.NUM_STAGES do
        if times[makeLookupKey(i)] then
            nextStage = i
        end
        i = i + 1
    end

    return nextStage or LevelStage.NUM_STAGES + 1
end

---@param entity Entity
local function postPlayerRevive(_, entity)
    local player = entity:ToPlayer()
    if player and player:HasCollectible(ISAACS_LAST_WILL) then
        local RunSave = SAVE_MANAGER.GetRunSave(player)
        local times = Resouled:GetTimesStagesHaveBeenEntered()
        local items = player:GetHistory():GetCollectiblesHistory()

        if not RunSave.IsaacsLastWill then
            RunSave.IsaacsLastWill = 1
        end

        for _, item in ipairs(items) do
            local stageTime = times[makeLookupKey(RunSave.IsaacsLastWill)]
            if stageTime then
                if item:GetTime() <= stageTime then
                    local itemID = item:GetItemID()
                    local itemConfig = Isaac.GetItemConfig():GetCollectible(itemID)
                    if not itemConfig:HasTags(ItemConfig.TAG_QUEST) and not itemBlacklist[itemID] then
                        player:RemoveCollectible(itemID)
                    end
                end
            end
            
        end

        RunSave.IsaacsLastWill = getNextStageFromSave(player)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PLAYER_REVIVE, postPlayerRevive)

---@param player EntityPlayer
local function playerDeathPostCheckRevives(_, player)
    if player:HasCollectible(ISAACS_LAST_WILL) then
        local RunSave = SAVE_MANAGER.GetRunSave(player)
        local lastRoomIdx = Game():GetLevel():GetLastRoomDesc().GridIndex

        local times = Resouled:GetTimesStagesHaveBeenEntered()

        if not RunSave.IsaacsLastWill then
            RunSave.IsaacsLastWill = 1
        end

        local nextStage = getNextStageFromSave(player)

        if nextStage <= LevelStage.NUM_STAGES or times[makeLookupKey(RunSave.IsaacsLastWill)] then
            player:Revive()
            Game():StartRoomTransition(lastRoomIdx, Resouled:GetDirToRoomFromIdx(lastRoomIdx))
        else
            local itemCount = 0

            local items = player:GetHistory():GetCollectiblesHistory()
            for _, item in ipairs(items) do
                local itemID = item:GetItemID()
                local itemConfig = Isaac.GetItemConfig():GetCollectible(itemID)
                if not itemConfig:HasTags(ItemConfig.TAG_QUEST) and not itemBlacklist[itemID] then
                    itemCount = itemCount + 1
                    player:RemoveCollectible(itemID)
                end
            end

            if itemCount > 0 then
                player:Revive()
                Game():StartRoomTransition(lastRoomIdx, Resouled:GetDirToRoomFromIdx(lastRoomIdx))
            end
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_TRIGGER_PLAYER_DEATH_POST_CHECK_REVIVES, playerDeathPostCheckRevives)