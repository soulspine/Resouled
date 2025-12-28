---@enum ResouledBuffFamily
Resouled.BuffFamilies = {
    CURSED_SKULL = 0,
    STEAM_SALE = 1,
    CROSS = 2,
    KIDS_DRAWING = 3,
    ZODIAC_SIGN = 4,
    IMP = 5,
    METEOR = 6,
    BLUE_KING_CROWN = 7,
    SCARY_FACE = 18,
    SMALL_CAP = 19,
    MAGGOT = 41,

    WAR = 8, --Special start from here
    DEATH = 9,
    SOUL_CATCHER = 10,
    SIGHT = 11,
    FORTUNE = 12,
    AGILITY = 13,
    STRENGTH = 14,
    SADNESS = 15,
    PESTILENCE = 16,
    FAMINE = 17,
    PUTRIFIER = 25,
    CHITIN = 26,
    WRATH = 33,
    GLUTTONY = 34,
    GREED = 35,
    SLOTH = 36,
    PRIDE = 37,
    LUST = 38,
    ENVY = 39,

    RESSURECTION_DAY = 20,
    LORD_OF_THE_FLIES = 21,
    MASQUERADE = 22,
    DELIRIOUS = 23,
    MOTHERLY_LOVE = 24,
    GREEDS_GAMBLE = 27,
    STOMPING_GROUND = 28,
    TRICK_OR_TREAT = 29,
    LIFE_OF_LUST = 30,
    FATTYS_FEAST = 31,
    KRAMPUS_CHRISTMAS = 32,
    DAY_OF_THE_DOODLER = 40,
}

---@enum ResouledBuff
Resouled.Buffs = {
    CURSED_SKULL = 1,
    DEVILS_HEAD = 2,
    FORBIDDEN_CRANIUM = 3,
    STEAM_SALE = 4,
    STEAM_GIVEAWAY = 5,
    PIRACY = 6,
    CROSS = 7,
    RELIC = 8,
    CRUCIFIX = 9,
    KIDS_DRAWING = 10,
    FORGOTTEN_POLAROID = 11,
    BROKEN_MEMORY = 12,
    ZODIAC_SIGN = 13,
    CONSTELLATION = 14,
    HEAVENS_CALL = 15,
    IMP = 16,
    FIEND = 17,
    DEMON = 18,
    METEOR = 19,
    THE_MOON = 20,
    THE_SUN = 21,
    BLUE_KING_CROWN = 22,
    KING_CROWN = 23,
    ROYAL_CROWN = 24,
    SCARY_FACE = 35,
    FRIGHTENING_VISAGE = 36,
    TERRIFYING_PHYSIOGNOMY = 37,
    SMALL_CAP = 38,
    MEDIUM_CAP = 39,
    BIG_CAP = 40,
    MAGGOT = 62,
    WORM = 63,
    PROGLOTTID = 64,

    WAR = 25, -- Special start from here
    DEATH = 26,
    SOUL_CATCHER = 27,
    SIGHT = 28,
    FORTUNE = 29,
    AGILITY = 30,
    STRENGTH = 31,
    SADNESS = 32,
    PESTILENCE = 33,
    FAMINE = 34,
    PUTRIFIER = 46,
    CHITIN = 47,
    WRATH = 54,
    GLUTTONY = 55,
    GREED = 56,
    SLOTH = 57,
    PRIDE = 58,
    LUST = 59,
    ENVY = 60,

    RESSURECTION_DAY = 41,
    LORD_OF_THE_FLIES = 42,
    MASQUERADE = 43,
    DELIRIOUS = 44,
    MOTHERLY_LOVE = 45,
    GREEDS_GAMBLE = 48,
    STOMPING_GROUND = 49,
    TRICK_OR_TREAT = 50,
    LIFE_OF_LUST = 51,
    FATTYS_FEAST = 52,
    KRAMPUS_CHRISTMAS = 53,
    DAY_OF_THE_DOODLER = 61,
}

---@enum ResouledBuffRarity
Resouled.BuffRarity = {
    COMMON = 0,
    RARE = 1,
    LEGENDARY = 2,
    SPECIAL = 3,
    CURSED = 4,
}

local COMMON_BASE_PRICE = 4
local RARE_BASE_PRICE = 7
local LEGENDARY_BASE_PRICE = 10

-- REGISTERING BUFF FAMILIES
Resouled:RegisterBuffFamily(Resouled.BuffFamilies.CURSED_SKULL, "Cursed Skull", "gfx_resouled/buffs/cursed_skull.png")
Resouled:RegisterBuffFamily(Resouled.BuffFamilies.STEAM_SALE, "Steam Sale", "gfx_resouled/buffs/steam_sale.png")
Resouled:RegisterBuffFamily(Resouled.BuffFamilies.CROSS, "Cross", "gfx_resouled/buffs/cross.png")
Resouled:RegisterBuffFamily(Resouled.BuffFamilies.KIDS_DRAWING, "Kid's Drawing", "gfx_resouled/buffs/kids_drawing.png")
Resouled:RegisterBuffFamily(Resouled.BuffFamilies.ZODIAC_SIGN, "Zodiac Sign", "gfx_resouled/buffs/zodiac_sign.png")
Resouled:RegisterBuffFamily(Resouled.BuffFamilies.IMP, "Imp", "gfx_resouled/buffs/imp.png")
Resouled:RegisterBuffFamily(Resouled.BuffFamilies.METEOR, "Meteor", "gfx_resouled/buffs/meteor.png")
Resouled:RegisterBuffFamily(Resouled.BuffFamilies.BLUE_KING_CROWN, "Blue King Crown", "gfx_resouled/buffs/blue_king_crown.png")
Resouled:RegisterBuffFamily(Resouled.BuffFamilies.SCARY_FACE, "Scary Face", "gfx_resouled/buffs/scary_face.png")
Resouled:RegisterBuffFamily(Resouled.BuffFamilies.SMALL_CAP, "Small Cap", "gfx_resouled/buffs/small_cap.png")
Resouled:RegisterBuffFamily(Resouled.BuffFamilies.MAGGOT, "Maggot", "gfx_resouled/buffs/maggot.png")


Resouled:RegisterBuffFamily(Resouled.BuffFamilies.WAR, "War", "gfx_resouled/buffs/war.png") -- Special
Resouled:RegisterBuffFamily(Resouled.BuffFamilies.FAMINE, "Famine", "gfx_resouled/buffs/famine.png")
Resouled:RegisterBuffFamily(Resouled.BuffFamilies.DEATH, "Death", "gfx_resouled/buffs/death.png")
Resouled:RegisterBuffFamily(Resouled.BuffFamilies.PESTILENCE, "Pestilence", "gfx_resouled/buffs/pestilence.png")
Resouled:RegisterBuffFamily(Resouled.BuffFamilies.SOUL_CATCHER, "Soul Catcher", "gfx_resouled/buffs/soul_catcher.png")
Resouled:RegisterBuffFamily(Resouled.BuffFamilies.SIGHT, "Sight", "gfx_resouled/buffs/sight.png")
Resouled:RegisterBuffFamily(Resouled.BuffFamilies.FORTUNE, "Fortune", "gfx_resouled/buffs/fortune.png")
Resouled:RegisterBuffFamily(Resouled.BuffFamilies.AGILITY, "Agility", "gfx_resouled/buffs/agility.png")
Resouled:RegisterBuffFamily(Resouled.BuffFamilies.STRENGTH, "Strength", "gfx_resouled/buffs/strength.png")
Resouled:RegisterBuffFamily(Resouled.BuffFamilies.SADNESS, "Sadness", "gfx_resouled/buffs/sadness.png")
Resouled:RegisterBuffFamily(Resouled.BuffFamilies.PUTRIFIER, "Putrifier", "gfx_resouled/buffs/placeholder.png")
Resouled:RegisterBuffFamily(Resouled.BuffFamilies.CHITIN, "Chitin", "gfx_resouled/buffs/placeholder.png")
Resouled:RegisterBuffFamily(Resouled.BuffFamilies.WRATH, "Wrath", "gfx_resouled/buffs/wrath.png")
Resouled:RegisterBuffFamily(Resouled.BuffFamilies.GLUTTONY, "Gluttony", "gfx_resouled/buffs/gluttony.png")
Resouled:RegisterBuffFamily(Resouled.BuffFamilies.GREED, "Greed", "gfx_resouled/buffs/greed.png")
Resouled:RegisterBuffFamily(Resouled.BuffFamilies.ENVY, "Envy", "gfx_resouled/buffs/envy.png")
Resouled:RegisterBuffFamily(Resouled.BuffFamilies.SLOTH, "Sloth", "gfx_resouled/buffs/sloth.png")
Resouled:RegisterBuffFamily(Resouled.BuffFamilies.LUST, "Lust", "gfx_resouled/buffs/lust.png")
Resouled:RegisterBuffFamily(Resouled.BuffFamilies.PRIDE, "Pride", "gfx_resouled/buffs/pride.png")

Resouled:RegisterBuffFamily(Resouled.BuffFamilies.RESSURECTION_DAY, "Ressurection Day", "gfx_resouled/buffs/cursed/placeholder_cursed.png") -- Cursed
Resouled:RegisterBuffFamily(Resouled.BuffFamilies.LORD_OF_THE_FLIES, "Lord of The Flies", "gfx_resouled/buffs/cursed/placeholder_cursed.png")
Resouled:RegisterBuffFamily(Resouled.BuffFamilies.MASQUERADE, "Masquerade", "gfx_resouled/buffs/cursed/placeholder_cursed.png")
Resouled:RegisterBuffFamily(Resouled.BuffFamilies.DELIRIOUS, "Delirious", "gfx_resouled/buffs/cursed/delirious.png")
Resouled:RegisterBuffFamily(Resouled.BuffFamilies.MOTHERLY_LOVE, "Motherly Love", "gfx_resouled/buffs/cursed/placeholder_cursed.png")
Resouled:RegisterBuffFamily(Resouled.BuffFamilies.GREEDS_GAMBLE, "Greed's Gamble", "gfx_resouled/buffs/cursed/placeholder_cursed.png")
Resouled:RegisterBuffFamily(Resouled.BuffFamilies.STOMPING_GROUND, "Stomping Ground", "gfx_resouled/buffs/cursed/placeholder_cursed.png")
Resouled:RegisterBuffFamily(Resouled.BuffFamilies.TRICK_OR_TREAT, "Trick or Treat", "gfx_resouled/buffs/cursed/placeholder_cursed.png")
Resouled:RegisterBuffFamily(Resouled.BuffFamilies.LIFE_OF_LUST, "Life of Lust", "gfx_resouled/buffs/cursed/placeholder_cursed.png")
Resouled:RegisterBuffFamily(Resouled.BuffFamilies.FATTYS_FEAST, "Fatty's Feast", "gfx_resouled/buffs/cursed/placeholder_cursed.png")
Resouled:RegisterBuffFamily(Resouled.BuffFamilies.KRAMPUS_CHRISTMAS, "Krampus Christmas", "gfx_resouled/buffs/cursed/placeholder_cursed.png")
Resouled:RegisterBuffFamily(Resouled.BuffFamilies.DAY_OF_THE_DOODLER, "Day of The Doodler", "gfx_resouled/buffs/cursed/placeholder_cursed.png")

-- REGISTERING BUFF RARITIES
Resouled:RegisterBuffRarity(Resouled.BuffRarity.COMMON, "Common", 0.65, Color(117/255, 152/255, 161/255))
Resouled:RegisterBuffRarity(Resouled.BuffRarity.RARE, "Rare", 0.25, Color(154/255, 113/255, 176/255))
Resouled:RegisterBuffRarity(Resouled.BuffRarity.LEGENDARY, "Legendary", 0.1, Color(185/255, 170/255, 35/255))
Resouled:RegisterBuffRarity(Resouled.BuffRarity.SPECIAL, "Special", 0, Color(1, 1, 1))
Resouled:RegisterBuffRarity(Resouled.BuffRarity.CURSED, "Cursed", 0, Color(108.9/255, 94/255, 198/255))

-- REGISTERING BUFFS
Resouled:RegisterBuff(Resouled.Buffs.CURSED_SKULL, "Cursed Skull", COMMON_BASE_PRICE, Resouled.BuffRarity.COMMON,
    Resouled.BuffFamilies.CURSED_SKULL, false)
Resouled:RegisterBuff(Resouled.Buffs.DEVILS_HEAD, "Devil's Head", RARE_BASE_PRICE, Resouled.BuffRarity.RARE,
    Resouled.BuffFamilies.CURSED_SKULL, false)
Resouled:RegisterBuff(Resouled.Buffs.FORBIDDEN_CRANIUM, "Forbidden Cranium", LEGENDARY_BASE_PRICE, Resouled.BuffRarity.LEGENDARY,
    Resouled.BuffFamilies.CURSED_SKULL, false)
Resouled:RegisterBuff(Resouled.Buffs.STEAM_SALE, "Steam Sale", COMMON_BASE_PRICE, Resouled.BuffRarity.COMMON,
    Resouled.BuffFamilies.STEAM_SALE, true)
Resouled:RegisterBuff(Resouled.Buffs.STEAM_GIVEAWAY, "Steam Giveaway", RARE_BASE_PRICE, Resouled.BuffRarity.RARE,
    Resouled.BuffFamilies.STEAM_SALE, false)
Resouled:RegisterBuff(Resouled.Buffs.PIRACY, "Piracy", LEGENDARY_BASE_PRICE, Resouled.BuffRarity.LEGENDARY, Resouled.BuffFamilies
    .STEAM_SALE, false)
Resouled:RegisterBuff(Resouled.Buffs.CROSS, "Cross", COMMON_BASE_PRICE, Resouled.BuffRarity.COMMON, Resouled.BuffFamilies.CROSS, false)
Resouled:RegisterBuff(Resouled.Buffs.RELIC, "Relic", RARE_BASE_PRICE, Resouled.BuffRarity.RARE, Resouled.BuffFamilies.CROSS, false)
Resouled:RegisterBuff(Resouled.Buffs.CRUCIFIX, "Crucifix", LEGENDARY_BASE_PRICE, Resouled.BuffRarity.LEGENDARY, Resouled.BuffFamilies.CROSS,
    false)
Resouled:RegisterBuff(Resouled.Buffs.KIDS_DRAWING, "Kid's Drawing", COMMON_BASE_PRICE, Resouled.BuffRarity.COMMON,
    Resouled.BuffFamilies.KIDS_DRAWING, true)
Resouled:RegisterBuff(Resouled.Buffs.FORGOTTEN_POLAROID, "Forgotten Polaroid", RARE_BASE_PRICE, Resouled.BuffRarity.RARE,
    Resouled.BuffFamilies.KIDS_DRAWING, true)
Resouled:RegisterBuff(Resouled.Buffs.BROKEN_MEMORY, "Broken Memory", LEGENDARY_BASE_PRICE, Resouled.BuffRarity.LEGENDARY,
    Resouled.BuffFamilies.KIDS_DRAWING, true)
Resouled:RegisterBuff(Resouled.Buffs.ZODIAC_SIGN, "Zodiac Sign", COMMON_BASE_PRICE, Resouled.BuffRarity.COMMON,
    Resouled.BuffFamilies.ZODIAC_SIGN, false)
Resouled:RegisterBuff(Resouled.Buffs.CONSTELLATION, "Constellation", RARE_BASE_PRICE, Resouled.BuffRarity.RARE,
    Resouled.BuffFamilies.ZODIAC_SIGN, false)
Resouled:RegisterBuff(Resouled.Buffs.HEAVENS_CALL, "Heaven's Call", LEGENDARY_BASE_PRICE, Resouled.BuffRarity.LEGENDARY,
    Resouled.BuffFamilies.ZODIAC_SIGN, true)
Resouled:RegisterBuff(Resouled.Buffs.IMP, "Imp", COMMON_BASE_PRICE, Resouled.BuffRarity.COMMON, Resouled.BuffFamilies.IMP, false)
Resouled:RegisterBuff(Resouled.Buffs.FIEND, "Fiend", RARE_BASE_PRICE, Resouled.BuffRarity.RARE, Resouled.BuffFamilies.IMP, false)
Resouled:RegisterBuff(Resouled.Buffs.DEMON, "Demon", LEGENDARY_BASE_PRICE, Resouled.BuffRarity.LEGENDARY, Resouled.BuffFamilies.IMP, false)
Resouled:RegisterBuff(Resouled.Buffs.METEOR, "Meteor", COMMON_BASE_PRICE, Resouled.BuffRarity.COMMON, Resouled.BuffFamilies.METEOR, false)
Resouled:RegisterBuff(Resouled.Buffs.THE_MOON, "The Moon", RARE_BASE_PRICE, Resouled.BuffRarity.RARE, Resouled.BuffFamilies.METEOR,
    true)
Resouled:RegisterBuff(Resouled.Buffs.THE_SUN, "The Sun", LEGENDARY_BASE_PRICE, Resouled.BuffRarity.LEGENDARY, Resouled.BuffFamilies.METEOR,
    true)
Resouled:RegisterBuff(Resouled.Buffs.BLUE_KING_CROWN, "Blue King Crown", COMMON_BASE_PRICE, Resouled.BuffRarity.COMMON,
    Resouled.BuffFamilies.BLUE_KING_CROWN, false)
Resouled:RegisterBuff(Resouled.Buffs.KING_CROWN, "King Crown", RARE_BASE_PRICE, Resouled.BuffRarity.RARE,
    Resouled.BuffFamilies.BLUE_KING_CROWN, false)
Resouled:RegisterBuff(Resouled.Buffs.ROYAL_CROWN, "Royal Crown", LEGENDARY_BASE_PRICE, Resouled.BuffRarity.LEGENDARY,
    Resouled.BuffFamilies.BLUE_KING_CROWN, false)
Resouled:RegisterBuff(Resouled.Buffs.SCARY_FACE, "Scary Face", COMMON_BASE_PRICE, Resouled.BuffRarity.COMMON,
    Resouled.BuffFamilies.SCARY_FACE, false)
Resouled:RegisterBuff(Resouled.Buffs.FRIGHTENING_VISAGE, "Frightening Visage", RARE_BASE_PRICE, Resouled.BuffRarity.RARE,
    Resouled.BuffFamilies.SCARY_FACE, false)
Resouled:RegisterBuff(Resouled.Buffs.TERRIFYING_PHYSIOGNOMY, "Terrifying Physiognomy", LEGENDARY_BASE_PRICE, Resouled.BuffRarity.LEGENDARY,
    Resouled.BuffFamilies.SCARY_FACE, false)

Resouled:RegisterBuff(Resouled.Buffs.WAR, "War", 0, Resouled.BuffRarity.SPECIAL, Resouled.BuffFamilies.WAR, false,
    Resouled.Souls.WAR)
Resouled:RegisterBuff(Resouled.Buffs.DEATH, "Death", 0, Resouled.BuffRarity.SPECIAL, Resouled.BuffFamilies.DEATH, false,
    Resouled.Souls.DEATH)
Resouled:RegisterBuff(Resouled.Buffs.SOUL_CATCHER, "Soul Catcher", 0, Resouled.BuffRarity.SPECIAL,
    Resouled.BuffFamilies.SOUL_CATCHER, false)
Resouled:RegisterBuff(Resouled.Buffs.SIGHT, "Sight", 0, Resouled.BuffRarity.SPECIAL, Resouled.BuffFamilies.SIGHT, false)
Resouled:RegisterBuff(Resouled.Buffs.FORTUNE, "Fortune", 0, Resouled.BuffRarity.SPECIAL, Resouled.BuffFamilies.FORTUNE,
    false)
Resouled:RegisterBuff(Resouled.Buffs.AGILITY, "Agility", 0, Resouled.BuffRarity.SPECIAL, Resouled.BuffFamilies.AGILITY,
    false)
Resouled:RegisterBuff(Resouled.Buffs.STRENGTH, "Strength", 0, Resouled.BuffRarity.SPECIAL, Resouled.BuffFamilies
    .STRENGTH, false)
Resouled:RegisterBuff(Resouled.Buffs.SADNESS, "Sadness", 0, Resouled.BuffRarity.SPECIAL, Resouled.BuffFamilies.SADNESS,
    false)
Resouled:RegisterBuff(Resouled.Buffs.PESTILENCE, "Pestilence", 0, Resouled.BuffRarity.SPECIAL,
    Resouled.BuffFamilies.PESTILENCE, false, Resouled.Souls.PESTILENCE)
Resouled:RegisterBuff(Resouled.Buffs.FAMINE, "Famine", 0, Resouled.BuffRarity.SPECIAL, Resouled.BuffFamilies.FAMINE,
    false, Resouled.Souls.FAMINE)
Resouled:RegisterBuff(Resouled.Buffs.SMALL_CAP, "Small Cap", COMMON_BASE_PRICE, Resouled.BuffRarity.COMMON, Resouled.BuffFamilies.SMALL_CAP, false)
Resouled:RegisterBuff(Resouled.Buffs.MEDIUM_CAP, "Meduim Cap", RARE_BASE_PRICE, Resouled.BuffRarity.RARE, Resouled.BuffFamilies.SMALL_CAP, false)
Resouled:RegisterBuff(Resouled.Buffs.BIG_CAP, "Big Cap", LEGENDARY_BASE_PRICE, Resouled.BuffRarity.LEGENDARY, Resouled.BuffFamilies.SMALL_CAP, false)
Resouled:RegisterBuff(Resouled.Buffs.RESSURECTION_DAY, "Ressurection Day", -4, Resouled.BuffRarity.CURSED, Resouled.BuffFamilies.RESSURECTION_DAY, false)
Resouled:RegisterBuff(Resouled.Buffs.LORD_OF_THE_FLIES, "Lord of The Flies", -4, Resouled.BuffRarity.CURSED, Resouled.BuffFamilies.LORD_OF_THE_FLIES, false)
Resouled:RegisterBuff(Resouled.Buffs.MASQUERADE, "Masquerade", -4, Resouled.BuffRarity.CURSED, Resouled.BuffFamilies.MASQUERADE, false)
Resouled:RegisterBuff(Resouled.Buffs.DELIRIOUS, "Delirious", -4, Resouled.BuffRarity.CURSED, Resouled.BuffFamilies.DELIRIOUS, false)
Resouled:RegisterBuff(Resouled.Buffs.MOTHERLY_LOVE, "Motherly Love", -4, Resouled.BuffRarity.CURSED, Resouled.BuffFamilies.MOTHERLY_LOVE, false)
Resouled:RegisterBuff(Resouled.Buffs.PUTRIFIER, "Putrifier", 0, Resouled.BuffRarity.SPECIAL, Resouled.BuffFamilies.PUTRIFIER, false)
Resouled:RegisterBuff(Resouled.Buffs.CHITIN, "Chitin", 0, Resouled.BuffRarity.SPECIAL, Resouled.BuffFamilies.CHITIN, false)
Resouled:RegisterBuff(Resouled.Buffs.GREEDS_GAMBLE, "Greed's Gamble", -4, Resouled.BuffRarity.CURSED, Resouled.BuffFamilies.GREEDS_GAMBLE, false)
Resouled:RegisterBuff(Resouled.Buffs.STOMPING_GROUND, "Stomping Ground", -4, Resouled.BuffRarity.CURSED, Resouled.BuffFamilies.STOMPING_GROUND, false)
Resouled:RegisterBuff(Resouled.Buffs.TRICK_OR_TREAT, "Trick or Treat", -4, Resouled.BuffRarity.CURSED, Resouled.BuffFamilies.TRICK_OR_TREAT, false)
Resouled:RegisterBuff(Resouled.Buffs.LIFE_OF_LUST, "Life of Lust", -4, Resouled.BuffRarity.CURSED, Resouled.BuffFamilies.LIFE_OF_LUST, false)
Resouled:RegisterBuff(Resouled.Buffs.FATTYS_FEAST, "Fatty's Feast", -4, Resouled.BuffRarity.CURSED, Resouled.BuffFamilies.FATTYS_FEAST, false)
Resouled:RegisterBuff(Resouled.Buffs.KRAMPUS_CHRISTMAS, "Krampus Christmas", -4, Resouled.BuffRarity.CURSED, Resouled.BuffFamilies.KRAMPUS_CHRISTMAS, false)
Resouled:RegisterBuff(Resouled.Buffs.WRATH, "Wrath", 0, Resouled.BuffRarity.SPECIAL, Resouled.BuffFamilies.WRATH, false, Resouled.Souls.WRATH)
Resouled:RegisterBuff(Resouled.Buffs.GLUTTONY, "Gluttony", 0, Resouled.BuffRarity.SPECIAL, Resouled.BuffFamilies.GLUTTONY, false, Resouled.Souls.GLUTTONY)
Resouled:RegisterBuff(Resouled.Buffs.GREED, "Greed", 0, Resouled.BuffRarity.SPECIAL, Resouled.BuffFamilies.GREED, false, Resouled.Souls.GREED)
Resouled:RegisterBuff(Resouled.Buffs.LUST, "Lust", 0, Resouled.BuffRarity.SPECIAL, Resouled.BuffFamilies.LUST, false, Resouled.Souls.LUST)
Resouled:RegisterBuff(Resouled.Buffs.SLOTH, "Sloth", 0, Resouled.BuffRarity.SPECIAL, Resouled.BuffFamilies.SLOTH, false, Resouled.Souls.SLOTH)
Resouled:RegisterBuff(Resouled.Buffs.PRIDE, "Pride", 0, Resouled.BuffRarity.SPECIAL, Resouled.BuffFamilies.PRIDE, false, Resouled.Souls.PRIDE)
Resouled:RegisterBuff(Resouled.Buffs.ENVY, "Envy", 0, Resouled.BuffRarity.SPECIAL, Resouled.BuffFamilies.ENVY, false, Resouled.Souls.ENVY)
Resouled:RegisterBuff(Resouled.Buffs.DAY_OF_THE_DOODLER, "Day of The Doodler", -4, Resouled.BuffRarity.CURSED, Resouled.BuffFamilies.DAY_OF_THE_DOODLER, false)
Resouled:RegisterBuff(Resouled.Buffs.MAGGOT, "Maggot", COMMON_BASE_PRICE, Resouled.BuffRarity.COMMON, Resouled.BuffFamilies.MAGGOT, false)
Resouled:RegisterBuff(Resouled.Buffs.WORM, "Worm", RARE_BASE_PRICE, Resouled.BuffRarity.RARE, Resouled.BuffFamilies.MAGGOT, false)
Resouled:RegisterBuff(Resouled.Buffs.PROGLOTTID, "Proglottid", LEGENDARY_BASE_PRICE, Resouled.BuffRarity.LEGENDARY, Resouled.BuffFamilies.MAGGOT, false)


Resouled:Log("Loaded " .. tostring(#Resouled:GetBuffs()) .. " buffs")



local buffsToRemoveOnGameEnd = {}
local removeIfDeath = {}

---@param buffId ResouledBuff
---@param removeOnDeath? boolean --Default: false
function Resouled:AddBuffToRemoveOnRunEnd(buffId, removeOnDeath)
    table.insert(buffsToRemoveOnGameEnd, buffId)
    removeIfDeath[buffId] = removeOnDeath or false
end

---@param isGameOver boolean
local function postGameEnd(_, isGameOver)
    for _, buffId in ipairs(buffsToRemoveOnGameEnd) do
        if isGameOver and removeIfDeath[buffId] == false then else
            Resouled:RemoveActiveBuff(buffId)
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_GAME_END, postGameEnd)




-- IMPORTING BUFF SCRIPTS
include("scripts.buffs.cursed_skull")
include("scripts.buffs.devils_head")
include("scripts.buffs.forbidden_cranium")
include("scripts.buffs.cross")
include("scripts.buffs.relic")
include("scripts.buffs.crucifix")
include("scripts.buffs.steam_sale")
include("scripts.buffs.steam_giveaway")
include("scripts.buffs.piracy")
include("scripts.buffs.kids_drawing")
include("scripts.buffs.forgotten_polaroid")
include("scripts.buffs.broken_memory")
include("scripts.buffs.zodiac_sign")
include("scripts.buffs.constellation")
include("scripts.buffs.heavens_call")
include("scripts.buffs.blue_king_crown")
include("scripts.buffs.king_crown")
include("scripts.buffs.royal_crown")
include("scripts.buffs.imp")
include("scripts.buffs.fiend")
include("scripts.buffs.demon")
include("scripts.buffs.scary_face")
include("scripts.buffs.frightening_visage")
include("scripts.buffs.terrifying_physiognomy")
include("scripts.buffs.the_moon")
include("scripts.buffs.the_sun")
include("scripts.buffs.small_cap")
include("scripts.buffs.medium_cap")
include("scripts.buffs.big_cap")
include("scripts.buffs.maggot")
include("scripts.buffs.worm")
include("scripts.buffs.proglottid")

include("scripts.buffs.war")
include("scripts.buffs.death")
include("scripts.buffs.soul_catcher")
include("scripts.buffs.sight")
include("scripts.buffs.fortune")
include("scripts.buffs.agility")
include("scripts.buffs.strength")
include("scripts.buffs.sadness")
include("scripts.buffs.pestilence")
include("scripts.buffs.famine")
include("scripts.buffs.chitin")
include("scripts.buffs.wrath")
include("scripts.buffs.gluttony")
include("scripts.special_souls.the_bone")
include("scripts.buffs.pride")

include("scripts.buffs.cursed.lord_of_the_flies")
include("scripts.buffs.cursed.masquerade")
include("scripts.buffs.cursed.ressurection_day")
include("scripts.buffs.cursed.delirious")
include("scripts.buffs.cursed.motherly_love")
include("scripts.buffs.cursed.greeds_gamble")
include("scripts.buffs.cursed.stomping_ground")
include("scripts.buffs.cursed.trick_or_treat")
include("scripts.buffs.cursed.life_of_lust")
include("scripts.buffs.cursed.fatty's_feast")
include("scripts.buffs.cursed.krampus_christmas")