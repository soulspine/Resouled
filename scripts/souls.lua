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
    THE_RAINMAKER = 60,
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
}

-- SPECIAL SOUL SCRIPTS

include("scripts.special_souls.the_bone")
include("scripts.special_souls.the_chest")

-- FILTERS
local isCharmedFilter = function(npc)
    return npc:HasEntityFlags(EntityFlag.FLAG_CHARM)
end

-- REGULAR SOUL DROP ENTRIES (ON ENEMY KILL)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_MONSTRO, 0, 0, Resouled.Souls.MONSTRO, 1)
Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_MONSTRO, 0, 1, Resouled.Souls.MONSTRO, 1)
Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_MONSTRO, 0, 2, Resouled.Souls.MONSTRO, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_MONSTRO, 0, 0, Resouled.Souls.CHARMED_MONSTRO, 1, isCharmedFilter)
Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_MONSTRO, 0, 1, Resouled.Souls.CHARMED_MONSTRO, 1, isCharmedFilter)
Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_MONSTRO, 0, 2, Resouled.Souls.CHARMED_MONSTRO, 1, isCharmedFilter)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_DUKE, 0, 0, Resouled.Souls.DUKE, 1)
Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_DUKE, 0, 1, Resouled.Souls.DUKE, 1)
Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_DUKE, 0, 2, Resouled.Souls.DUKE, 1)
Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_DUKE, 1, 0, Resouled.Souls.DUKE, 1)
Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_DUKE, 1, 1, Resouled.Souls.DUKE, 1)
Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_DUKE, 1, 2, Resouled.Souls.DUKE, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_LITTLE_HORN, 0, 0, Resouled.Souls.LITTLE_HORN, 1)
Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_LITTLE_HORN, 0, 1, Resouled.Souls.LITTLE_HORN, 1)
Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_LITTLE_HORN, 0, 2, Resouled.Souls.LITTLE_HORN, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_PEEP, 1, 1, Resouled.Souls.BLOAT, 1)
Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_PEEP, 1, 2, Resouled.Souls.BLOAT, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_WRATH, 0, 0, Resouled.Souls.WRATH, 1)
Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_WIDOW, 1, 0, Resouled.Souls.WIDOW, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_THE_HAUNT, Isaac.GetEntityVariantByName("Cursed Haunt"), 0, Resouled.Souls.CURSED_HAUNT, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_CHUB, 0, 0, Resouled.Souls.CHUB, 1)
Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_CHUB, 0, 1, Resouled.Souls.CHUB, 1)
Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_CHUB, 0, 2, Resouled.Souls.CHUB, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_CHUB, 2, 0, Resouled.Souls.CARRIOR_QUEEN, 1)
Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_CHUB, 2, 1, Resouled.Souls.CARRIOR_QUEEN, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_WAR, 1, 0, Resouled.Souls.CONQUEST, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_DADDYLONGLEGS, 0, 0, Resouled.Souls.DADDY_LONG_LEGS, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_DARK_ONE, 0, 0, Resouled.Souls.DARK_ONE, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_DEATH, 0, 0, Resouled.Souls.DEATH, 1)
Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_DEATH, 0, 1, Resouled.Souls.DEATH, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_ENVY, 0, 0, Resouled.Souls.ENVY, 1)
Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_ENVY, 1, 0, Resouled.Souls.ENVY, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_FAMINE, 0, 0, Resouled.Souls.FAMINE, 1)
Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_FAMINE, 0, 1, Resouled.Souls.FAMINE, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_GEMINI, 0, 0, Resouled.Souls.GEMINI, 1)
Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_GEMINI, 0, 1, Resouled.Souls.GEMINI, 1)
Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_GEMINI, 0, 2, Resouled.Souls.GEMINI, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_GLUTTONY, 0, 0, Resouled.Souls.GLUTTONY, 1)
Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_GLUTTONY, 1, 0, Resouled.Souls.GLUTTONY, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_GREED, 0, 0, Resouled.Souls.GREED, 1)
Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_GREED, 1, 0, Resouled.Souls.GREED, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_GURDY, 0, 0, Resouled.Souls.GURDY, 1)
Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_GURDY, 0, 1, Resouled.Souls.GURDY, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_GURDY_JR, 0, 0, Resouled.Souls.GURDY_JR, 1)
Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_GURDY_JR, 0, 1, Resouled.Souls.GURDY_JR, 1)
Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_GURDY_JR, 0, 2, Resouled.Souls.GURDY_JR, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_LARRYJR, 0, 0, Resouled.Souls.LARRY_JR, 1)
Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_LARRYJR, 0, 1, Resouled.Souls.LARRY_JR, 1)
Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_LARRYJR, 0, 2, Resouled.Souls.LARRY_JR, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_LUST, 0, 0, Resouled.Souls.LUST, 1)
Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_LUST, 1, 0, Resouled.Souls.LUST, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_MASK_OF_INFAMY, 0, 0, Resouled.Souls.MASK_OF_INFAMY, 1)
Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_MASK_OF_INFAMY, 0, 1, Resouled.Souls.MASK_OF_INFAMY, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_MEGA_FATTY, 0, 0, Resouled.Souls.MEGA_FATTY, 1)
Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_MEGA_FATTY, 0, 1, Resouled.Souls.MEGA_FATTY, 1)
Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_MEGA_FATTY, 0, 2, Resouled.Souls.MEGA_FATTY, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_PEEP, 0, 0, Resouled.Souls.PEEP, 1)
Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_PEEP, 0, 1, Resouled.Souls.PEEP, 1)
Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_PEEP, 0, 2, Resouled.Souls.PEEP, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_PESTILENCE, 0, 0, Resouled.Souls.PESTILENCE, 1)
Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_PESTILENCE, 0, 1, Resouled.Souls.PESTILENCE, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_PIN, 0, 0, Resouled.Souls.PIN, 1)
Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_PIN, 0, 1, Resouled.Souls.PIN, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_PRIDE, 0, 0, Resouled.Souls.PRIDE, 1)
Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_PRIDE, 1, 0, Resouled.Souls.PRIDE, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_RAG_MAN, 0, 0, Resouled.Souls.RAG_MAN, 1)
Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_RAG_MAN, 0, 1, Resouled.Souls.RAG_MAN, 1)
Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_RAG_MAN, 0, 2, Resouled.Souls.RAG_MAN, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_PIN, 1, 0, Resouled.Souls.SCOLEX, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_SLOTH, 0, 0, Resouled.Souls.SLOTH, 1)
Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_SLOTH, 0, 1, Resouled.Souls.SLOTH, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_THE_HAUNT, 0, 0, Resouled.Souls.HAUNT, 1)
Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_THE_HAUNT, 0, 1, Resouled.Souls.HAUNT, 1)
Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_THE_HAUNT, 0, 2, Resouled.Souls.HAUNT, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_THE_LAMB, 10, 0, Resouled.Souls.THE_LAMB, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_WAR, 10, 0, Resouled.Souls.WAR, 1)
Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_WAR, 10, 1, Resouled.Souls.WAR, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_MOM, 0, 0, Resouled.Souls.MOM, 1)
Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_MOM, 0, 1, Resouled.Souls.MOM, 1)
Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_MOM, 0, 2, Resouled.Souls.MOM, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_SATAN, 10, 0, Resouled.Souls.SATAN, 2)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_HEADLESS_HORSEMAN, 0, 0, Resouled.Souls.HEADLESS_HORSEMAN, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_BLASTOCYST_BIG, 0, 0, Resouled.Souls.BLASTOCYST, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_DINGLE, 0, 0, Resouled.Souls.DINGLE, 1)
Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_DINGLE, 0, 1, Resouled.Souls.DINGLE, 1)
Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_DINGLE, 0, 2, Resouled.Souls.DINGLE, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_FALLEN, 1, 0, Resouled.Souls.KRAMPUS, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_MONSTRO2, 0, 0, Resouled.Souls.MONSTRO_II, 1)
Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_MONSTRO2, 0, 1, Resouled.Souls.MONSTRO_II, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_FALLEN, 0, 0, Resouled.Souls.THE_FALLEN, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_ISAAC, 0, 0, Resouled.Souls.ISAAC, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_MOMS_HEART, 0, 0, Resouled.Souls.MOMS_HEART, 2)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_MOMS_HEART, 0, 0, Resouled.Souls.CHARMED_MOMS_HEART, 1, isCharmedFilter)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_BABY_PLUM, 0, 0, Resouled.Souls.BABY_PLUM, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_BROWNIE, 0, 0, Resouled.Souls.BROWNIE, 1)
Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_BROWNIE, 0, 1, Resouled.Souls.BROWNIE, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_CLOG, 0, 0, Resouled.Souls.CLOG, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_HORNFEL, 0, 0, Resouled.Souls.HORNFEL, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_MAMA_GURDY, 0, 0, Resouled.Souls.MAMA_GURDY, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_RAG_MEGA, 0, 0, Resouled.Souls.RAG_MEGA, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_SISTERS_VIS, 0, 0, Resouled.Souls.SISTERS_VIS, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_RAINMAKER, 0, 0, Resouled.Souls.THE_RAINMAKER, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_SCOURGE, 0, 0, Resouled.Souls.THE_SCOURGE, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_SIREN, 0, 0, Resouled.Souls.THE_SIREN, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_GURGLING, 2, 0, Resouled.Souls.TURDLINGS, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_ULTRA_GREED, 0, 0, Resouled.Souls.ULTRA_GREED, 1)
Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_ULTRA_GREED, 1, 0, Resouled.Souls.ULTRA_GREED, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_MEGA_SATAN_2, 0, 0, Resouled.Souls.MEGA_SATAN, 2)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_MOTHER, 10, 0, Resouled.Souls.MOTHER, 2)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_ROTGUT, 1, 0, Resouled.Souls.GUS, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_HUSH, 0, 0, Resouled.Souls.HUSH, 2)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_FISTULA_BIG, 0, 0, Resouled.Souls.FISTULA, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_GURGLING, 0, 0, Resouled.Souls.GURGLINGS, 1)
Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_GURGLING, 1, 0, Resouled.Souls.GURGLINGS, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_POLYCEPHALUS, 0, 0, Resouled.Souls.POLYCEPHALUS, 1)
Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_POLYCEPHALUS, 0, 1, Resouled.Souls.POLYCEPHALUS, 1)
Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_POLYCEPHALUS, 0, 2, Resouled.Souls.POLYCEPHALUS, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_GEMINI, 1, 0, Resouled.Souls.STEVEN, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_CAGE, 0, 0, Resouled.Souls.THE_CAGE, 1)
Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_CAGE, 0, 1, Resouled.Souls.THE_CAGE, 1)
Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_CAGE, 0, 2, Resouled.Souls.THE_CAGE, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_BIG_HORN, 0, 0, Resouled.Souls.BIG_HORN, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_LOKI, 0, 0, Resouled.Souls.LOKI, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_ADVERSARY, 0, 0, Resouled.Souls.THE_ADVERSARY, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_FISTULA_BIG, 1, 0, Resouled.Souls.TERATOMA, 1)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_MOMS_HEART, 1, 0, Resouled.Souls.IT_LIVES, 2)

Resouled:AddNewBasicSoulSpawnRule(EntityType.ENTITY_BEAST, 1, 0, Resouled.Souls.THE_BEAST, 2)


Resouled:Log("Loaded", Resouled:GetNumBasicSoulSpawnRules(), "basic soul spawn rules.")