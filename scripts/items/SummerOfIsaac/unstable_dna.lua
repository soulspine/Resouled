local UNSTABLE_DNA = Isaac.GetItemIdByName("Unstable DNA")

if EID then
    EID:addCollectible(UNSTABLE_DNA, "When entering a new room, there's a: #{{ArrowUp}} 25% chance to gain a temporary Hp up #{{ArrowUp}} 25% chance to gain a random temporary stat up #{{Warning}} 50% chance to remove all the temporary effects")
end

local STAT_UP_CHANCE = 0.5

local STAT_UP_VALUES = {
    [1] = 0.15, --Speed
    [2] = 0.75, --Tears
    [3] = 0.35, --Damage
    [4] = 2, --Range
    [5] = 0.05, --Shotspeed
    [6] = 0.5, --Luck
    [7] = 2, --Hp
}

---@param type CollectibleType
---@param player EntityPlayer
local function postAddCollectible(_, type, charge, firstTime, slot, varData, player)
    if type == UNSTABLE_DNA then
        local RUN_SAVE = SAVE_MANAGER.GetRunSave()
        if not RUN_SAVE.ResouledUnstableDNA then
            RUN_SAVE.ResouledUnstableDNA = {}
        end

        if not RUN_SAVE.ResouledUnstableDNA[player:GetPlayerIndex()] then
            RUN_SAVE.ResouledUnstableDNA[player:GetPlayerIndex()] = {
                [1] = 0, --Speed
                [2] = 0, --Tears
                [3] = 0, --Damage
                [4] = 0, --Range
                [5] = 0, --Shotspeed
                [6] = 0, --Luck
                [7] = 0, --Hp
            }
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, postAddCollectible)

local function postNewRoom()
    local room = Game():GetRoom()
    if room:IsFirstVisit() then
        local RUN_SAVE = SAVE_MANAGER.GetRunSave()
        if RUN_SAVE.ResouledUnstableDNA then
            ---@param player EntityPlayer
            Resouled.Iterators:IterateOverPlayers(function(player)
                local index = player:GetPlayerIndex()
                local rng = RNG()
                rng:SetSeed(room:GetAwardSeed())
                if RUN_SAVE.ResouledUnstableDNA[index] then
                    local randomFloat = rng:RandomFloat()
                    if randomFloat < STAT_UP_CHANCE then
                        local hpOrStats = rng:RandomInt(2)
                        if hpOrStats == 0 then
                            for _ = 1, player:GetCollectibleNum(UNSTABLE_DNA) do
                                RUN_SAVE.ResouledUnstableDNA[index][7] = RUN_SAVE.ResouledUnstableDNA[index][7] + 2
                                player:AddMaxHearts(2, true)
                                player:AddHearts(2)
                            end
                        elseif hpOrStats == 1 then --Stats
                            for _ = 1, player:GetCollectibleNum(UNSTABLE_DNA) do
                                local randomNum = rng:RandomInt(#RUN_SAVE.ResouledUnstableDNA[index]-1) + 1
                                RUN_SAVE.ResouledUnstableDNA[index][randomNum] = RUN_SAVE.ResouledUnstableDNA[index][randomNum] + STAT_UP_VALUES[randomNum] * player:GetCollectibleNum(UNSTABLE_DNA)
                            end
                        end
                    else
                        player:AddMaxHearts(-RUN_SAVE.ResouledUnstableDNA[index][7], true)
                        for i = 1, #RUN_SAVE.ResouledUnstableDNA[index] do
                            RUN_SAVE.ResouledUnstableDNA[index][i] = 0
                        end
                    end
                    player:AddCacheFlags(CacheFlag.CACHE_ALL, true)
                end
            end)
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, postNewRoom)

---@param player EntityPlayer
---@param flag CacheFlag
local function onCacheEval(_, player, flag)
    local RUN_SAVE = SAVE_MANAGER.GetRunSave()
    if RUN_SAVE.ResouledUnstableDNA then
        ---@param player EntityPlayer
        Resouled.Iterators:IterateOverPlayers(function(player)
            local index = player:GetPlayerIndex()
            if RUN_SAVE.ResouledUnstableDNA[index] then

                if flag == CacheFlag.CACHE_SPEED then
                    player.MoveSpeed = player.MoveSpeed + RUN_SAVE.ResouledUnstableDNA[index][1]
                end

                if flag == CacheFlag.CACHE_FIREDELAY then
                    player.MaxFireDelay = player.MaxFireDelay - RUN_SAVE.ResouledUnstableDNA[index][2]
                end

                if flag == CacheFlag.CACHE_DAMAGE then
                    player.Damage = player.Damage + RUN_SAVE.ResouledUnstableDNA[index][3]
                end

                if flag == CacheFlag.CACHE_RANGE then
                    player.TearRange = player.TearRange + RUN_SAVE.ResouledUnstableDNA[index][4]
                end

                if flag == CacheFlag.CACHE_SHOTSPEED then
                    player.ShotSpeed = player.ShotSpeed + RUN_SAVE.ResouledUnstableDNA[index][5]
                end

                if flag == CacheFlag.CACHE_LUCK then
                    player.Luck = player.Luck + RUN_SAVE.ResouledUnstableDNA[index][6]
                end
            end
        end)
    end
end
Resouled:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, onCacheEval)