local UNSTABLE_DNA = Resouled.Enums.Items.UNSTABLE_DNA

local STAT_UP_CHANCE = 0.5

local IGNORE_KEEPER = true

local STAT_ENUM = {
    SPEED = 1,
    TEARS = 2,
    DAMAGE = 3,
    RANGE = 4,
    SHOTSPEED = 5,
    LUCK = 6,
    HP = 7,
}

local STAT_UP_VALUES = {
    [STAT_ENUM.SPEED] = 0.15, --Speed
    [STAT_ENUM.TEARS] = 0.75, --Tears
    [STAT_ENUM.DAMAGE] = 0.35, --Damage
    [STAT_ENUM.RANGE] = 2, --Range
    [STAT_ENUM.SHOTSPEED] = 0.05, --Shotspeed
    [STAT_ENUM.LUCK] = 0.5, --Luck
    [STAT_ENUM.HP] = 2, --Hp
}

local OMNI_CACHE_FLAG = CacheFlag.CACHE_SPEED | CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_RANGE | CacheFlag.CACHE_SHOTSPEED | CacheFlag.CACHE_LUCK

local function postNewRoom()
    local room = Game():GetRoom()
    if room:IsFirstVisit() then
        Resouled.Iterators:IterateOverPlayers(function(player)
            --local sprite = player:GetSprite() -- SLIGH COLOR CHANGES WITH PILLS
            --sprite.Color = Color(math.random(), math.random(), math.random(), sprite.Color.A)
                    
            local itemCount = player:GetCollectibleNum(UNSTABLE_DNA)
            if itemCount > 0 then
                local RUN_SAVE = SAVE_MANAGER.GetRunSave(player)
                local rng = RNG()
                rng:SetSeed(room:GetAwardSeed())
                if not RUN_SAVE.UnstableDNA or rng:RandomFloat() < STAT_UP_CHANCE then -- stat up
                    local itemRng = player:GetCollectibleRNG(UNSTABLE_DNA)
                    local cacheFlag = 0
                    for _ = 1, itemCount do -- rolling for random stat up

                        local validStatUps = { -- UNCONDITIONAL STATS
                            STAT_ENUM.SPEED,
                            STAT_ENUM.TEARS,
                            STAT_ENUM.DAMAGE,
                            STAT_ENUM.RANGE,
                            STAT_ENUM.SHOTSPEED,
                            STAT_ENUM.LUCK,
                        }

                        -- HP STAT UP IS CONDITIONAL, CHECK WHETHER ITS APPLICABLE, IF NOT, DONT ADD IT TO ROLLABLE STATS
                        local healthType = player:GetPlayerType()
                        if healthType ~= HealthType.NO_HEALTH and healthType ~= HealthType.COIN then
                            table.insert(validStatUps, STAT_ENUM.HP)
                        end

                        local chosenStat = validStatUps[itemRng:RandomInt(#validStatUps) + 1]
                        local statString = tostring(chosenStat)
                        local statValue = STAT_UP_VALUES[chosenStat]

                        if not RUN_SAVE.UnstableDNA then
                            RUN_SAVE.UnstableDNA = {}
                        end

                        if not RUN_SAVE.UnstableDNA[statString] then
                            RUN_SAVE.UnstableDNA[statString] = 0
                        end

                        -- ADDING THE STAT UP
                        RUN_SAVE.UnstableDNA[statString] = RUN_SAVE.UnstableDNA[statString] + statValue

                        -- SELECTING A CACHE FLAG
                        if chosenStat == STAT_ENUM.SPEED then
                            cacheFlag = cacheFlag | CacheFlag.CACHE_SPEED
                        elseif chosenStat == STAT_ENUM.TEARS then
                            cacheFlag = cacheFlag | CacheFlag.CACHE_FIREDELAY
                        elseif chosenStat == STAT_ENUM.DAMAGE then
                            cacheFlag = cacheFlag | CacheFlag.CACHE_DAMAGE
                        elseif chosenStat == STAT_ENUM.RANGE then
                            cacheFlag = cacheFlag | CacheFlag.CACHE_RANGE
                        elseif chosenStat == STAT_ENUM.SHOTSPEED then
                            cacheFlag = cacheFlag | CacheFlag.CACHE_SHOTSPEED
                        elseif chosenStat == STAT_ENUM.LUCK then
                            cacheFlag = cacheFlag | CacheFlag.CACHE_LUCK
                        elseif chosenStat == STAT_ENUM.HP then
                            player:AddMaxHearts(statValue, IGNORE_KEEPER)
                            player:AddHearts(statValue)
                        end

                    end

                    if cacheFlag ~= 0 then
                        ---@diagnostic disable-next-line: param-type-mismatch
                        player:AddCacheFlags(cacheFlag, true)
                    end
                else -- remove all stat ups
                    -- REMOVE HP BECAUSE IT IS NOT HANDLED IN CACHE UPDATES
                    local hpToRemove = RUN_SAVE.UnstableDNA[tostring(STAT_ENUM.HP)]
                    if hpToRemove then
                        hpToRemove = math.min(hpToRemove, Resouled.AccurateStats:GetEffectiveHealthContainers(player) - 1)  --  making sure it doesnt kill the player
                        player:AddMaxHearts(-hpToRemove, IGNORE_KEEPER)
                    end
                    
                    RUN_SAVE.UnstableDNA = nil
                    
                    ---@diagnostic disable-next-line: param-type-mismatch
                    player:AddCacheFlags(OMNI_CACHE_FLAG, true)
                    
                end
            end
        end)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, postNewRoom)

---@param player EntityPlayer
---@param flag CacheFlag
local function onCacheEval(_, player, flag)
    local RUN_SAVE = SAVE_MANAGER.GetRunSave(player)
    if RUN_SAVE.UnstableDNA then

        local statValue = 0

        if flag & CacheFlag.CACHE_SPEED > 0 then
            statValue = RUN_SAVE.UnstableDNA[tostring(STAT_ENUM.SPEED)] or 0
            player.MoveSpeed = player.MoveSpeed + statValue
        end

        if flag & CacheFlag.CACHE_FIREDELAY > 0 then
            statValue = RUN_SAVE.UnstableDNA[tostring(STAT_ENUM.TEARS)] or 0
            player.MaxFireDelay = player.MaxFireDelay - statValue
        end

        if flag & CacheFlag.CACHE_DAMAGE > 0 then
            statValue = RUN_SAVE.UnstableDNA[tostring(STAT_ENUM.DAMAGE)] or 0
            player.Damage = player.Damage + statValue
        end

        if flag & CacheFlag.CACHE_RANGE > 0 then
            statValue = RUN_SAVE.UnstableDNA[tostring(STAT_ENUM.RANGE)] or 0
            player.TearRange = player.TearRange + statValue
        end

        if flag & CacheFlag.CACHE_SHOTSPEED > 0 then
            statValue = RUN_SAVE.UnstableDNA[tostring(STAT_ENUM.SHOTSPEED)] or 0
            player.ShotSpeed = player.ShotSpeed + statValue
        end

        if flag & CacheFlag.CACHE_LUCK > 0 then
            statValue = RUN_SAVE.UnstableDNA[tostring(STAT_ENUM.LUCK)] or 0
            player.Luck = player.Luck + statValue
        end

    end
end
Resouled:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, onCacheEval)