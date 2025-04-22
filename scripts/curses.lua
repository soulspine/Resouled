---@enum ResouledCurses
Resouled.Curses = {
    CURSE_OF_GREED = Isaac.GetCurseIdByName("Curse of Greed!"),
    CURSE_OF_PAIN = Isaac.GetCurseIdByName("Curse of Pain!"),
    CURSE_OF_LOSS = Isaac.GetCurseIdByName("Curse of Loss!"),
    CURSE_OF_BLOOD_LUST = Isaac.GetCurseIdByName("Curse of Blood Lust!"),
    CURSE_OF_SOULLESS = Isaac.GetCurseIdByName("Curse of Soulless!"),
    CURSE_OF_FATIGUE = Isaac.GetCurseIdByName("Curse of Fatigue!"),
}

Resouled.CursesMapId = {
    [Resouled.Curses.CURSE_OF_GREED] = "ResouledCurseOfGreed",
    [Resouled.Curses.CURSE_OF_PAIN] = "ResouledCurseOfPain",
    [Resouled.Curses.CURSE_OF_LOSS] = "ResouledCurseOfLoss",
    [Resouled.Curses.CURSE_OF_BLOOD_LUST] = "ResouledCurseOfBloodLust",
    [Resouled.Curses.CURSE_OF_SOULLESS] = "ResouledCurseOfSoulless",
    [Resouled.Curses.CURSE_OF_FATIGUE] = "ResouledCurseOfFatigue",
}

Resouled.CursesSprite = Sprite()
Resouled.CursesSprite:Load("gfx/curses.anm2", true)

local CUSTOM_CURSE_CHANCE = 1

include("scripts.curses.BaseGameV2.curse_of_greed")
include("scripts.curses.BaseGameV2.curse_of_pain")
include("scripts.curses.BaseGameV2.curse_of_loss")
include("scripts.curses.BaseGameV2.curse_of_blood_lust")
include("scripts.curses.Requiem.curse_of_soulless")
include("scripts.curses.ExtraSets.curse_of_fatigue")

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