---@class AccurateStatsModule
local accurateStatsModule = {}

--- Returns effective HP of the player. \
--- Every half a `red` / `soul` / `black` heart counts as 1 HP. \
--- Every `bone` / `rotten` / `eternal` heart counts as 1 HP.
---@param player EntityPlayer
---@return integer
function accurateStatsModule:GetEffectiveHP(player)
    -- TODO
    local red = player:GetHearts()
    local soul = player:GetSoulHearts() -- black hearts are counted in
    local bone = player:GetBoneHearts()
    local rotten = player:GetRottenHearts() -- we substract this because rotten hearts are counted in red hearts as well
    local eternal = player:GetEternalHearts()
    return red + soul + bone - rotten + eternal
end

-- Returns exactly how much red HP player has
---@param player EntityPlayer
---@return integer
function accurateStatsModule:GetEffectiveRedHP(player)
    return player:GetHearts() - 2*player:GetRottenHearts()
end

--- Returns exactly how much soul HP player has
---@param player EntityPlayer
---@return integer
function accurateStatsModule:GetEffectiveSoulHP(player)
    return math.max(player:GetSoulHearts() - 2*player:GetBlackHearts(), 0)
end

--- Returns exactly how much black HP player has
---@param player EntityPlayer
---@return integer
function accurateStatsModule:GetEffectiveBlackHP(player)
    return player:GetSoulHearts() - accurateStatsModule:GetEffectiveSoulHP(player)
end

--- Returns number representing player's in-game fire rate \
---@param player EntityPlayer
---@return number
function accurateStatsModule:GetFireRate(player)
    return 30 / (player.MaxFireDelay + 1)
end

--- Returns player's theoretical DPS if all tears hit a target
--- @param player EntityPlayer
--- @return number
function accurateStatsModule:GetDPS(player)
    return player.Damage * accurateStatsModule:GetFireRate(player)
end

--- Returns amount of containers player has based on their default health type
--- @param player EntityPlayer
--- @return integer
function accurateStatsModule:GetEffectiveHealthContainers(player)
    local healthType = player:GetHealthType()
    if healthType == HealthType.RED or HealthType == HealthType.BONE or healthType == HealthType.COIN then
        return player:GetEffectiveMaxHearts()
    elseif healthType == HealthType.SOUL then
        return player:GetSoulHearts() -- black hearts are counted in
    end
    return 0
end

function accurateStatsModule:GetCurrentChapter()
    local stage = Game():GetLevel():GetStage()
    if stage < 9 then
        return (stage+1)//2
    else
        return 4 + (stage-8)
    end
end

function accurateStatsModule:IsCurrentFloorLastFloorOfChapter()
    local stage = Game():GetLevel():GetStage()
    if stage < 9 then
        return stage % 2 == 0
    else
        return true
    end
end

return accurateStatsModule