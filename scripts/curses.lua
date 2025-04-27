---@enum ResouledCurses
Resouled.Curses = {
    CURSE_OF_GREED = Isaac.GetCurseIdByName("Curse of Greed!"),
    CURSE_OF_PAIN = Isaac.GetCurseIdByName("Curse of Pain!"),
    CURSE_OF_LOSS = Isaac.GetCurseIdByName("Curse of Loss!"),
    CURSE_OF_BLOOD_LUST = Isaac.GetCurseIdByName("Curse of Blood Lust!"),
    CURSE_OF_SOULLESS = Isaac.GetCurseIdByName("Curse of Soulless!"),
    CURSE_OF_FATIGUE = Isaac.GetCurseIdByName("Curse of Fatigue!"),
    CURSE_OF_ENVY = Isaac.GetCurseIdByName("Curse of Envy!"),
    CURSE_OF_EMPATHY = Isaac.GetCurseIdByName("Curse of Empathy!"),
    CURSE_OF_THE_HOLLOW = Isaac.GetCurseIdByName("Curse of the Hollow!"),
}

Resouled.CursesMapId = {
    [Resouled.Curses.CURSE_OF_GREED] = "ResouledCurseOfGreed",
    [Resouled.Curses.CURSE_OF_PAIN] = "ResouledCurseOfPain",
    [Resouled.Curses.CURSE_OF_LOSS] = "ResouledCurseOfLoss",
    [Resouled.Curses.CURSE_OF_BLOOD_LUST] = "ResouledCurseOfBloodLust",
    [Resouled.Curses.CURSE_OF_SOULLESS] = "ResouledCurseOfSoulless",
    [Resouled.Curses.CURSE_OF_FATIGUE] = "ResouledCurseOfFatigue",
    [Resouled.Curses.CURSE_OF_ENVY] = "ResouledCurseOfEnvy",
    [Resouled.Curses.CURSE_OF_EMPATHY] = "ResouledCurseOfEmpathy",
    [Resouled.Curses.CURSE_OF_THE_HOLLOW] = "ResouledCurseOfTheHollow",
}

local CURSES_BLACKLIST = {
    [7] = true, -- curse of giant
}

Resouled.CursesSprite = Sprite()
Resouled.CursesSprite:Load("gfx/curses.anm2", true)

local CUSTOM_CURSE_CHANCE = 1

include("scripts.curses.BaseGameV2.curse_of_greed")
include("scripts.curses.BaseGameV2.curse_of_pain")
include("scripts.curses.BaseGameV2.curse_of_loss")
include("scripts.curses.BaseGameV2.curse_of_blood_lust")
include("scripts.curses.Requiem.curse_of_soulless")
include("scripts.curses.Requiem.curse_of_empathy")
include("scripts.curses.ExtraSets.curse_of_fatigue")
include("scripts.curses.SummerOfIsaac.curse_of_envy")
include("scripts.curses.Requiem.curse_of_the_hollow")

---@param curses integer
local function onCurseEval(_, curses)
    local level = Game():GetLevel()
    local stage = level:GetStage()
    local stageSeed = Game():GetSeeds():GetStageSeed(stage)
    local rng = RNG()
    rng:SetSeed(stageSeed, 0)

    if curses ~= 0 and Resouled:GetCursesNum(curses) == 1 then -- CHALLNGE CURSES ARE APPLIED AFTER THIS SO NO NEED TO CHECK HOW MANY CURSES ARE ALREADY PRESENT BUT I ADDED IT JUST SO IT DOESNT MESS WITH OTHER MODS
        local validCurses = {}
        -- VANILLA CURSES
        for i = 1, LevelCurse.NUM_CURSES - 1 do
            if not CURSES_BLACKLIST[i] then
                table.insert(validCurses, i)
            end
        end

        --RESOULED CURSES
        for _, curseId in pairs(Resouled.Curses) do
            if not CURSES_BLACKLIST[curseId] then
                table.insert(validCurses, curseId)
            end
        end

        local newCurseId = validCurses[rng:RandomInt(#validCurses) + 1]
        curses = 1 << (newCurseId - 1)
        level:AddCurse(curses, false)
    end

    return curses
end
Resouled:AddCallback(ModCallbacks.MC_POST_CURSE_EVAL, onCurseEval)