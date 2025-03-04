---@enum ResouledCurses
Resouled.Curses = {
    CURSE_OF_GREED = Isaac.GetCurseIdByName("Curse of Greed!"),
    CURSE_OF_PAIN = Isaac.GetCurseIdByName("Curse of Pain!")
}

local CUSTOM_CURSE_CHANCE = 0.1

include("scripts.curses.curse_of_greed")
include("scripts.curses.curse_of_pain")

---@param curse ResouledCurses
---@return boolean
function Resouled:CustomCursePresent(curse)
    local curseShifted = 1 << (curse - 1)
    return Game():GetLevel():GetCurses() & curseShifted == curseShifted
end

---@param rng RNG
---@return integer
local function rollCurse(rng)
    local cursesToRollFrom = {}
    for _, curseId in pairs(Resouled.Curses) do
        table.insert(cursesToRollFrom, curseId)
    end
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