---@enum ResouledSoul
Resouled.Souls = {
    MONSTRO = 1,
    DUKE = 2,
    LITTLE_HORN = 3,
    BLOAT = 4,
    WRATH = 5,
    WIDOW = 6,
    CURSED_HAUNT = 7,
    THE_BONE = 8,
    THE_CHEST = 9,
    CARRIOR_QUEEN = 10,
    PANDORAS_BOX = 11,
    CHUB = 12,
    CONQUEST = 13,
    DADDY_LONG_LEGS = 14,
    DARK_ONE = 15,
    DEATH = 16,
    ENVY = 17,
    FAMINE = 18,
    GEMINI = 19,
    GLUTTONY = 20,
    GREED = 21,
    GURDY = 22,
    GURDY_JR = 23,
    LARRY_JR = 24,
    LUST = 25,
    MASK_OF_INFAMY = 26,
    MEGA_FATTY = 27,
    PEEP = 28,
    PESTILENCE = 29,
    PIN = 30,
    PRIDE = 31,
    RAG_MAN = 32,
    SCOLEX = 33,
    SLOTH = 34,
    HAUNT = 35,
    THE_LAMB = 36,
    WAR = 37,
    MOM = 38,
    SATAN = 39,
    HEADLESS_HORSEMAN = 40,
    BLASTOCYST = 41,
    DINGLE = 42,
    KRAMPUS = 43,
    MONSTRO_II = 44,
    THE_FALLEN = 45,
    ISAAC = 46,
    MOMS_HEART = 47,
    HOLY_CHEST = 48,
    EXPERIMENTAL_TREATMENT = 49,
    ULTRA_FLESH_KID = 50,
    CURSED_SOUL = 51,
    BABY_PLUM = 52,
    BROWNIE = 53,
    CHARMED_MONSTRO = 54,
    CLOG = 55,
    HORNFEL = 56,
    MAMA_GURDY = 57,
    RAG_MEGA = 58,
    SISTERS_VIS = 59,
    RAINMAKER = 60,
    THE_SCOURGE = 61,
    THE_SIREN = 62,
    TURDLINGS = 63,
    ULTRA_GREED = 64,
    MEGA_SATAN = 65,
    MOTHER = 66,
    GUS = 67,
    A_FRIEND = 68,
    HUSH = 69,
    HOLY_GREED = 70,
    HOT_POTATO = 71,
    FISTULA = 72,
    GURGLINGS = 73,
    POLYCEPHALUS = 74,
    STEVEN = 75,
    THE_CAGE = 76,
    BIG_HORN = 77,
    LOKI = 78,
    THE_ADVERSARY = 79,
    TERATOMA = 78,
    IT_LIVES = 79,
    CHARMED_MOMS_HEART = 80,
    THE_LOST = 81,
    THE_BEAST = 82,
    THE_HOLLOW = 83,
    TUFF_TWIN = 84,
    THE_SHELL = 85,
    CHAD = 86,
    GISH = 87,
    ULTRA_PRIDE = 88,
    THE_FRAIL = 89,
    WORMWOOD = 90,
    THE_HUSK = 91,
    LOKII = 92,
    THE_BLIGHTED_OVUM = 93,
    THE_WRETCHED = 94,
    TRIACHNID = 95,
    BLUE_BABY = 96,
    DANGLE = 97,
    THE_GATE = 98,
    MEGA_MAW = 99,
    THE_PILE = 100,
    MR_FRED = 101,
    URIEL = 102,
    FALLEN_URIEL = 103,
    GABRIEL = 104,
    FALLEN_GABRIEL = 105,
    THE_STAIN = 106,
    THE_FORSAKEN = 107,
    DELIRIUM = 108,
    THE_MATRIARCH = 109,
    REAP_CREEP = 110,
    LIL_BULB = 111,
    VISAGE = 112,
    THE_HERETIC = 113,
    GREAT_GIDEON = 114,
    CHIMERA = 115,
    ROTGUT = 116,
    MIN_MIN = 117,
    SINGE = 118,
    BUMBINO = 119,
    COLOSTOMIA = 120,
    TURDLETS = 121,
    HORNY_BOYS = 122,
    DOGMA = 123,
    ULTRA_FAMINE = 124,
    ULTRA_WAR = 125,
    ULTRA_PESTILENCE = 126,
    ULTRA_DEATH = 127,
}

-- SPECIAL SOUL SCRIPTS

include("scripts.special_souls.the_bone")
include("scripts.special_souls.the_chest")

-- FILTERS
local isCharmedFilter = function(npc)
    return npc:HasEntityFlags(EntityFlag.FLAG_CHARM)
end

-- REGULAR SOUL DROP ENTRIES (ON ENEMY KILL)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_MONSTRO, 0, nil, Resouled.Souls.MONSTRO, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_MONSTRO, 0, nil, Resouled.Souls.CHARMED_MONSTRO, 1, isCharmedFilter)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_DUKE, 0, nil, Resouled.Souls.DUKE, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_DUKE, 1, nil, Resouled.Souls.THE_HUSK, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_LITTLE_HORN, 0, nil, Resouled.Souls.LITTLE_HORN, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_PEEP, 1, nil, Resouled.Souls.BLOAT, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_WRATH, 0, nil, Resouled.Souls.WRATH, 1)
Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_WRATH, 1, nil, Resouled.Souls.WRATH, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_WIDOW, 1, nil, Resouled.Souls.WIDOW, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_THE_HAUNT, Isaac.GetEntityVariantByName("Cursed Haunt"), 0, Resouled.Souls.CURSED_HAUNT, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_CHUB, 0, nil, Resouled.Souls.CHUB, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_CHUB, 2, nil, Resouled.Souls.CARRIOR_QUEEN, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_WAR, 1, nil, Resouled.Souls.CONQUEST, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_DADDYLONGLEGS, 0, nil, Resouled.Souls.DADDY_LONG_LEGS, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_DARK_ONE, 0, nil, Resouled.Souls.DARK_ONE, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_DEATH, 0, nil, Resouled.Souls.DEATH, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_ENVY, 0, nil, Resouled.Souls.ENVY, 1)
Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_ENVY, 1, nil, Resouled.Souls.ENVY, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_FAMINE, 0, nil, Resouled.Souls.FAMINE, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_GEMINI, 0, nil, Resouled.Souls.GEMINI, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_GLUTTONY, 0, nil, Resouled.Souls.GLUTTONY, 1)
Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_GLUTTONY, 1, nil, Resouled.Souls.GLUTTONY, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_GREED, 0, nil, Resouled.Souls.GREED, 1)
Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_GREED, 1, nil, Resouled.Souls.GREED, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_GURDY, 0, nil, Resouled.Souls.GURDY, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_GURDY_JR, 0, nil, Resouled.Souls.GURDY_JR, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_LARRYJR, 0, nil, Resouled.Souls.LARRY_JR, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_LUST, 0, nil, Resouled.Souls.LUST, 1)
Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_LUST, 1, nil, Resouled.Souls.LUST, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_MASK_OF_INFAMY, 0, nil, Resouled.Souls.MASK_OF_INFAMY, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_MEGA_FATTY, 0, nil, Resouled.Souls.MEGA_FATTY, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_PEEP, 0, nil, Resouled.Souls.PEEP, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_PESTILENCE, 0, nil, Resouled.Souls.PESTILENCE, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_PIN, 0, nil, Resouled.Souls.PIN, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_PRIDE, 0, nil, Resouled.Souls.PRIDE, 1)
Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_PRIDE, 1, nil, Resouled.Souls.PRIDE, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_RAG_MAN, 0, nil, Resouled.Souls.RAG_MAN, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_PIN, 1, nil, Resouled.Souls.SCOLEX, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_SLOTH, 0, nil, Resouled.Souls.SLOTH, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_THE_HAUNT, 0, nil, Resouled.Souls.HAUNT, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_THE_LAMB, 10, nil, Resouled.Souls.THE_LAMB, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_WAR, 10, nil, Resouled.Souls.WAR, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_MOM, 0, nil, Resouled.Souls.MOM, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_SATAN, 10, nil, Resouled.Souls.SATAN, 2)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_HEADLESS_HORSEMAN, 0, nil, Resouled.Souls.HEADLESS_HORSEMAN, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_BLASTOCYST_BIG, 0, nil, Resouled.Souls.BLASTOCYST, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_DINGLE, 0, nil, Resouled.Souls.DINGLE, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_FALLEN, 1, nil, Resouled.Souls.KRAMPUS, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_MONSTRO2, 0, nil, Resouled.Souls.MONSTRO_II, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_FALLEN, 0, nil, Resouled.Souls.THE_FALLEN, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_ISAAC, 0, 0, Resouled.Souls.ISAAC, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_MOMS_HEART, 0, nil, Resouled.Souls.MOMS_HEART, 2)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_MOMS_HEART, 0, nil, Resouled.Souls.CHARMED_MOMS_HEART, 1, isCharmedFilter)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_BABY_PLUM, 0, nil, Resouled.Souls.BABY_PLUM, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_BROWNIE, 0, nil, Resouled.Souls.BROWNIE, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_CLOG, 0, nil, Resouled.Souls.CLOG, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_HORNFEL, 0, nil, Resouled.Souls.HORNFEL, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_MAMA_GURDY, 0, nil, Resouled.Souls.MAMA_GURDY, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_RAG_MEGA, 0, nil, Resouled.Souls.RAG_MEGA, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_SISTERS_VIS, 0, nil, Resouled.Souls.SISTERS_VIS, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_RAINMAKER, 0, nil, Resouled.Souls.RAINMAKER, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_SCOURGE, 0, nil, Resouled.Souls.THE_SCOURGE, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_SIREN, 0, nil, Resouled.Souls.THE_SIREN, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_GURGLING, 2, nil, Resouled.Souls.TURDLINGS, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_ULTRA_GREED, 0, nil, Resouled.Souls.ULTRA_GREED, 1)
Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_ULTRA_GREED, 1, nil, Resouled.Souls.ULTRA_GREED, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_MEGA_SATAN_2, 0, nil, Resouled.Souls.MEGA_SATAN, 2)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_MOTHER, 10, nil, Resouled.Souls.MOTHER, 2)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_ROTGUT, 1, nil, Resouled.Souls.GUS, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_HUSH, 0, nil, Resouled.Souls.HUSH, 2)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_FISTULA_BIG, 0, nil, Resouled.Souls.FISTULA, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_GURGLING, 0, nil, Resouled.Souls.GURGLINGS, 1)
Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_GURGLING, 1, nil, Resouled.Souls.GURGLINGS, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_POLYCEPHALUS, 0, nil, Resouled.Souls.POLYCEPHALUS, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_GEMINI, 1, nil, Resouled.Souls.STEVEN, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_CAGE, 0, nil, Resouled.Souls.THE_CAGE, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_BIG_HORN, 0, nil, Resouled.Souls.BIG_HORN, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_LOKI, 0, nil, Resouled.Souls.LOKI, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_ADVERSARY, 0, nil, Resouled.Souls.THE_ADVERSARY, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_FISTULA_BIG, 1, nil, Resouled.Souls.TERATOMA, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_MOMS_HEART, 1, nil, Resouled.Souls.IT_LIVES, 2)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_BEAST, 1, nil, Resouled.Souls.THE_BEAST, 2)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_LARRYJR, 1, nil, Resouled.Souls.THE_HOLLOW, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_LARRYJR, 2, nil, Resouled.Souls.TUFF_TWIN, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_LARRYJR, 3, nil, Resouled.Souls.THE_SHELL, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_CHUB, 1, nil, Resouled.Souls.CHAD, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_MONSTRO2, 1, nil, Resouled.Souls.GISH, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_SLOTH, 2, nil, Resouled.Souls.ULTRA_PRIDE, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_PIN, 2, nil, Resouled.Souls.THE_FRAIL, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_PIN, 3, nil, Resouled.Souls.WORMWOOD, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_LOKI, 1, nil, Resouled.Souls.LOKII, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_GEMINI, 2, nil, Resouled.Souls.THE_BLIGHTED_OVUM, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_WIDOW, 1, nil, Resouled.Souls.THE_WRETCHED, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_DADDYLONGLEGS, 1, nil, Resouled.Souls.TRIACHNID, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_ISAAC, 1, nil, Resouled.Souls.BLUE_BABY, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_DINGLE, 1, nil, Resouled.Souls.DANGLE, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_GATE, 0, nil, Resouled.Souls.THE_GATE, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_MEGA_MAW, 0, nil, Resouled.Souls.MEGA_MAW, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_POLYCEPHALUS, 1, nil, Resouled.Souls.THE_PILE, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_MR_FRED, 0, nil, Resouled.Souls.MR_FRED, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_URIEL, 0, nil, Resouled.Souls.URIEL, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_URIEL, 1, nil, Resouled.Souls.FALLEN_URIEL, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_GABRIEL, 0, nil, Resouled.Souls.GABRIEL, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_GABRIEL, 1, nil, Resouled.Souls.FALLEN_GABRIEL, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_STAIN, 0, nil, Resouled.Souls.THE_STAIN, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_FORSAKEN, 0, nil, Resouled.Souls.THE_FORSAKEN, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_DELIRIUM, 0, nil, Resouled.Souls.DELIRIUM, 2)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_MATRIARCH, 0, nil, Resouled.Souls.THE_MATRIARCH, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_REAP_CREEP, 0, nil, Resouled.Souls.REAP_CREEP, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_LIL_BLUB, 0, nil, Resouled.Souls.LIL_BULB, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_VISAGE, 0, nil, Resouled.Souls.VISAGE, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_HERETIC, 0, nil, Resouled.Souls.THE_HERETIC, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_GIDEON, 0, nil, Resouled.Souls.GREAT_GIDEON, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_CHIMERA, 1, nil, Resouled.Souls.CHIMERA, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_ROTGUT, 0, nil, Resouled.Souls.ROTGUT, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_MIN_MIN, 0, nil, Resouled.Souls.MIN_MIN, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_SINGE, 0, nil, Resouled.Souls.SINGE, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_BUMBINO, 0, nil, Resouled.Souls.BUMBINO, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_COLOSTOMIA, 0, nil, Resouled.Souls.COLOSTOMIA, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_TURDLET, 0, nil, Resouled.Souls.TURDLETS, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_HORNY_BOYS, 0, nil, Resouled.Souls.HORNY_BOYS, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_DOGMA, 2, nil, Resouled.Souls.DOGMA, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_BEAST, 10, nil, Resouled.Souls.ULTRA_FAMINE, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_BEAST, 20, nil, Resouled.Souls.ULTRA_PESTILENCE, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_BEAST, 30, nil, Resouled.Souls.ULTRA_WAR, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_BEAST, 40, nil, Resouled.Souls.ULTRA_DEATH, 1)


Resouled:Log("Loaded", Resouled:GetNumBasicSoulSpawnRules(), "basic soul spawn rules.")