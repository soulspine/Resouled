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
    CURSE_OF_THE_SUSPICIOUS = Isaac.GetCurseIdByName("Curse of the Suspicious!"),
    CURSE_OF_TINY_HANDS = Isaac.GetCurseIdByName("Curse of Tiny Hands!"),
    CURSE_OF_THE_HUNTED = Isaac.GetCurseIdByName("Curse of the Hunted!"),
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
    [Resouled.Curses.CURSE_OF_THE_SUSPICIOUS] = "ResouledCurseOfTheSuspicious",
    [Resouled.Curses.CURSE_OF_TINY_HANDS] = "ResouledCurseOfTinyHands",
    [Resouled.Curses.CURSE_OF_THE_HUNTED] = "ResouledCurseOfTheHunted",
}

local CURSES_BLACKLIST = {
    [4] = true, -- curse of the cursed
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
include("scripts.curses.ExtraSets.curse_of_the_suspicious")
include("scripts.curses.ExtraSets.curse_of_tiny_hands")
include("scripts.curses.Requiem.curse_of_the_hunted")

---@param curses integer
local function onCurseEval(_, curses)
    local level = Game():GetLevel()
    local stage = level:GetStage()
    local stageSeed = Game():GetSeeds():GetStageSeed(stage)
    local rng = RNG()
    rng:SetSeed(stageSeed, 0)

    if curses ~= 0 and Resouled:GetCursesNum(curses) == 1 then -- CHALLNGE CURSES ARE APPLIED AFTER THIS SO NO NEED TO CHECK HOW MANY CURSES ARE ALREADY PRESENT BUT I ADDED IT JUST SO IT DOESNT MESS WITH OTHER MODS
        local validCurses = {}

        for i = 1, XMLData.GetNumEntries(XMLNode.CURSE) do
            i = i - 1 -- CURSES ARE SHIFTED BY 1 FOR SOME REASON ????? E.G. CURSE OF THE CURSED HAS ID 5 BUT ITS BIT IS 16 SO IT SHOULD BE 4 LOL?????
            if not CURSES_BLACKLIST[i] then
                table.insert(validCurses, i)
            end
        end

        local newCurseId = validCurses[rng:RandomInt(#validCurses) + 1]
        curses = 1 << (newCurseId)
        level:AddCurse(curses, false)
    end

    return curses
end
Resouled:AddCallback(ModCallbacks.MC_POST_CURSE_EVAL, onCurseEval)
