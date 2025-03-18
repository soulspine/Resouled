---@enum ResouledCurses
Resouled.Curses = {
    CURSE_OF_GREED = Isaac.GetCurseIdByName("Curse of Greed!"),
    CURSE_OF_PAIN = Isaac.GetCurseIdByName("Curse of Pain!"),
    CURSE_OF_LOSS = Isaac.GetCurseIdByName("Curse of Loss!"),
}

local CUSTOM_CURSE_CHANCE = 1

include("scripts.curses.BaseGameV2.curse_of_greed")
include("scripts.curses.BaseGameV2.curse_of_pain")
include("scripts.curses.BaseGameV2.curse_of_loss")

---@param curse ResouledCurses
---@return boolean
function Resouled:CustomCursePresent(curse)

    if curse == -1 then
        return false
    end

    local curseShifted = 1 << (curse - 1)
    return Game():GetLevel():GetCurses() & curseShifted == curseShifted
end

---@param rng RNG
---@return LevelCurse
local function rollCurse(rng)
    local cursesToRollFrom = {}
    for _, curseId in pairs(Resouled.Curses) do
        if curseId ~= -1 then -- not found
            table.insert(cursesToRollFrom, curseId)
        end
    end
    -- TODO ADD RESTART CHECK - CURSES ARE NOT LOADED AFTER JUST ENABLING THE MOD,
    -- GAME HAS TO BE RESTARTED FOR IT TO WORK PROPERLY
    return cursesToRollFrom[rng:RandomInt(#cursesToRollFrom) + 1]
end


---@param curses integer
local function onCurseEval(_, curses)
    local currentLevel = Game():GetLevel()
    local currentStage = currentLevel:GetStage()
    local stageSeed = Game():GetSeeds():GetStageSeed(currentStage)
    local rng = RNG()
    rng:SetSeed(stageSeed, 0)
    if curses == 0 and rng:RandomFloat() < CUSTOM_CURSE_CHANCE then
        curses = 1 << (rollCurse(rng) - 1)
        currentLevel:AddCurse(curses, false)
        print(Game():GetLevel():GetCurses())
        print(Game():GetLevel():GetCurseName())
        end 
    return curses
end
Resouled:AddCallback(ModCallbacks.MC_POST_CURSE_EVAL, onCurseEval)