---@enum ResouledCurses
Resouled.Curses = {
    CURSE_OF_GREED = Isaac.GetCurseIdByName("Curse of Greed!"),
    CURSE_OF_PAIN = Isaac.GetCurseIdByName("Curse of Pain!"),
}

---@enum ResouledBlessings
Resouled.Blessings = {
    BLESSING_OF_ISAAC = Isaac.GetCurseIdByName("Blessing of Isaac!"),
    BLESSING_OF_MAGGY = Isaac.GetCurseIdByName("Blessing of Maggy!"),
    BLESSING_OF_SAMSON = Isaac.GetCurseIdByName("Blessing of Samson!"),
    BLESSING_OF_STEAM = Isaac.GetCurseIdByName("Blessing of Steam!"),
}

local CUSTOM_CURSE_CHANCE = 0.1

include("scripts.curses.BaseGameV2.curse_of_greed")
include("scripts.curses.BaseGameV2.curse_of_pain")
include("scripts.curses.Requiem.blessing_of_isaac")
include("scripts.curses.Requiem.blessing_of_maggy")
include("scripts.curses.Requiem.blessing_of_samson")
include("scripts.curses.Requiem.blessing_of_steam")

---@param curse ResouledCurses | ResouledBlessings
---@return boolean
function Resouled:CustomCursePresent(curse)

    if curse == -1 then
        return false
    end

    local curseShifted = 1 << (curse - 1)
    return Game():GetLevel():GetCurses() & curseShifted == curseShifted
end

---@param rng RNG
---@return integer
local function rollCurse(rng)
    local cursesToRollFrom = {}
    for _, curseId in pairs(Resouled.Curses) do
        if curseId ~= -1 then -- not found
            table.insert(cursesToRollFrom, curseId)
        end
    end
    for _, blessingId in pairs(Resouled.Blessings) do
        if blessingId ~= -1 then
            table.insert(cursesToRollFrom, blessingId)
        end
    end
    -- TODO ADD RESTART CHECK - CURSES ARE NOT LOADED AFTER JUST ENABLING THE MOD,
    -- GAME HAS TO BE RESTARTED FOR IT TO WORK PROPERLY
    return cursesToRollFrom[rng:RandomInt(#cursesToRollFrom) + 1] - 1
end


---@param curses integer
local function onCurseEval(_, curses)
    local currentLevel = Game():GetLevel()
    local currentStage = currentLevel:GetStage()
    local stageSeed = Game():GetSeeds():GetStageSeed(currentStage)
    local rng = RNG()
    rng:SetSeed(stageSeed, 0)
    if curses == 0 and rng:RandomFloat() < CUSTOM_CURSE_CHANCE then
        local newCurse = rollCurse(rng)
        curses = 1 << newCurse
        currentLevel:AddCurse(curses, false)
        end
    return curses
end
Resouled:AddCallback(ModCallbacks.MC_POST_CURSE_EVAL, onCurseEval)