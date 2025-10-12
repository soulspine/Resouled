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
    THE_MOON = 19,
    THE_SUN = 20,
    METEOR = 21,
    BLUE_KING_CROWN = 22,
    KING_CROWN = 23,
    ROYAL_CROWN = 24,
    SCARY_FACE = 35,
    FRIGHTENING_VISAGE = 36,
    TERRIFYING_PHYSIOGNOMY = 37,

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
}

---@enum ResouledBuffRarity
Resouled.BuffRarity = {
    COMMON = 0,
    RARE = 1,
    LEGENDARY = 2,
    SPECIAL = 3,
}

-- REGISTERING BUFF FAMILIES
Resouled:RegisterBuffFamily(Resouled.BuffFamilies.CURSED_SKULL, "Cursed Skull", "gfx/buffs/cursed_skull.png")
Resouled:RegisterBuffFamily(Resouled.BuffFamilies.STEAM_SALE, "Steam Sale", "gfx/buffs/steam_sale.png")
Resouled:RegisterBuffFamily(Resouled.BuffFamilies.CROSS, "Cross", "gfx/buffs/cross.png")
Resouled:RegisterBuffFamily(Resouled.BuffFamilies.KIDS_DRAWING, "Kid's Drawing", "gfx/buffs/kids_drawing.png")
Resouled:RegisterBuffFamily(Resouled.BuffFamilies.ZODIAC_SIGN, "Zodiac Sign", "gfx/buffs/zodiac_sign.png")
Resouled:RegisterBuffFamily(Resouled.BuffFamilies.IMP, "Imp", "gfx/buffs/imp.png")
Resouled:RegisterBuffFamily(Resouled.BuffFamilies.METEOR, "Meteor", "gfx/buffs/meteor.png")
Resouled:RegisterBuffFamily(Resouled.BuffFamilies.BLUE_KING_CROWN, "Blue King Crown", "gfx/buffs/blue_king_crown.png")
Resouled:RegisterBuffFamily(Resouled.BuffFamilies.SIGHT, "Sight", "gfx/buffs/sight.png")
Resouled:RegisterBuffFamily(Resouled.BuffFamilies.FORTUNE, "Fortune", "gfx/buffs/fortune.png")
Resouled:RegisterBuffFamily(Resouled.BuffFamilies.AGILITY, "Agility", "gfx/buffs/agility.png")
Resouled:RegisterBuffFamily(Resouled.BuffFamilies.STRENGTH, "Strength", "gfx/buffs/strength.png")
Resouled:RegisterBuffFamily(Resouled.BuffFamilies.SADNESS, "Sadness", "gfx/buffs/sadness.png")
Resouled:RegisterBuffFamily(Resouled.BuffFamilies.PESTILENCE, "Pestilence", "gfx/buffs/pestilence.png")
Resouled:RegisterBuffFamily(Resouled.BuffFamilies.FAMINE, "Famine", "gfx/buffs/famine.png")
Resouled:RegisterBuffFamily(Resouled.BuffFamilies.SCARY_FACE, "Scary Face", "gfx/buffs/scary_face.png")

Resouled:RegisterBuffFamily(Resouled.BuffFamilies.WAR, "War", "gfx/buffs/war.png") -- Special
Resouled:RegisterBuffFamily(Resouled.BuffFamilies.DEATH, "Death", "gfx/buffs/death.png")
Resouled:RegisterBuffFamily(Resouled.BuffFamilies.SOUL_CATCHER, "Soul Catcher", "gfx/buffs/soul_catcher.png")

-- REGISTERING BUFF RARITIES
Resouled:RegisterBuffRarity(Resouled.BuffRarity.COMMON, "Common", 0.65)
Resouled:RegisterBuffRarity(Resouled.BuffRarity.RARE, "Rare", 0.25)
Resouled:RegisterBuffRarity(Resouled.BuffRarity.LEGENDARY, "Legendary", 0.1)
Resouled:RegisterBuffRarity(Resouled.BuffRarity.SPECIAL, "Special", 0)

-- REGISTERING BUFFS
Resouled:RegisterBuff(Resouled.Buffs.CURSED_SKULL, "Cursed Skull", 3, Resouled.BuffRarity.COMMON,
    Resouled.BuffFamilies.CURSED_SKULL, false)
Resouled:RegisterBuff(Resouled.Buffs.DEVILS_HEAD, "Devil's Head", 5, Resouled.BuffRarity.RARE,
    Resouled.BuffFamilies.CURSED_SKULL, false)
Resouled:RegisterBuff(Resouled.Buffs.FORBIDDEN_CRANIUM, "Forbidden Cranium", 8, Resouled.BuffRarity.LEGENDARY,
    Resouled.BuffFamilies.CURSED_SKULL, false)
Resouled:RegisterBuff(Resouled.Buffs.STEAM_SALE, "Steam Sale", 3, Resouled.BuffRarity.COMMON,
    Resouled.BuffFamilies.STEAM_SALE, true)
Resouled:RegisterBuff(Resouled.Buffs.STEAM_GIVEAWAY, "Steam Giveaway", 5, Resouled.BuffRarity.RARE,
    Resouled.BuffFamilies.STEAM_SALE, false)
Resouled:RegisterBuff(Resouled.Buffs.PIRACY, "Piracy", 8, Resouled.BuffRarity.LEGENDARY, Resouled.BuffFamilies
    .STEAM_SALE, false)
Resouled:RegisterBuff(Resouled.Buffs.CROSS, "Cross", 3, Resouled.BuffRarity.COMMON, Resouled.BuffFamilies.CROSS, false)
Resouled:RegisterBuff(Resouled.Buffs.RELIC, "Relic", 5, Resouled.BuffRarity.RARE, Resouled.BuffFamilies.CROSS, false)
Resouled:RegisterBuff(Resouled.Buffs.CRUCIFIX, "Crucifix", 8, Resouled.BuffRarity.LEGENDARY, Resouled.BuffFamilies.CROSS,
    false)
Resouled:RegisterBuff(Resouled.Buffs.KIDS_DRAWING, "Kid's Drawing", 3, Resouled.BuffRarity.COMMON,
    Resouled.BuffFamilies.KIDS_DRAWING, true)
Resouled:RegisterBuff(Resouled.Buffs.FORGOTTEN_POLAROID, "Forgotten Polaroid", 5, Resouled.BuffRarity.RARE,
    Resouled.BuffFamilies.KIDS_DRAWING, true)
Resouled:RegisterBuff(Resouled.Buffs.BROKEN_MEMORY, "Broken Memory", 8, Resouled.BuffRarity.LEGENDARY,
    Resouled.BuffFamilies.KIDS_DRAWING, true)
Resouled:RegisterBuff(Resouled.Buffs.ZODIAC_SIGN, "Zodiac Sign", 3, Resouled.BuffRarity.COMMON,
    Resouled.BuffFamilies.ZODIAC_SIGN, false)
Resouled:RegisterBuff(Resouled.Buffs.CONSTELLATION, "Constellation", 5, Resouled.BuffRarity.RARE,
    Resouled.BuffFamilies.ZODIAC_SIGN, false)
Resouled:RegisterBuff(Resouled.Buffs.HEAVENS_CALL, "Heaven's Call", 8, Resouled.BuffRarity.LEGENDARY,
    Resouled.BuffFamilies.ZODIAC_SIGN, true)
Resouled:RegisterBuff(Resouled.Buffs.IMP, "Imp", 3, Resouled.BuffRarity.COMMON, Resouled.BuffFamilies.IMP, false)
Resouled:RegisterBuff(Resouled.Buffs.FIEND, "Fiend", 5, Resouled.BuffRarity.RARE, Resouled.BuffFamilies.IMP, false)
Resouled:RegisterBuff(Resouled.Buffs.DEMON, "Demon", 8, Resouled.BuffRarity.LEGENDARY, Resouled.BuffFamilies.IMP, false)
Resouled:RegisterBuff(Resouled.Buffs.METEOR, "Meteor", 3, Resouled.BuffRarity.COMMON, Resouled.BuffFamilies.METEOR, false)
Resouled:RegisterBuff(Resouled.Buffs.THE_MOON, "The Moon", 5, Resouled.BuffRarity.RARE, Resouled.BuffFamilies.METEOR,
    true)
Resouled:RegisterBuff(Resouled.Buffs.THE_SUN, "The Sun", 8, Resouled.BuffRarity.LEGENDARY, Resouled.BuffFamilies.METEOR,
    true)
Resouled:RegisterBuff(Resouled.Buffs.BLUE_KING_CROWN, "Blue King Crown", 3, Resouled.BuffRarity.COMMON,
    Resouled.BuffFamilies.BLUE_KING_CROWN, false)
Resouled:RegisterBuff(Resouled.Buffs.KING_CROWN, "King Crown", 5, Resouled.BuffRarity.RARE,
    Resouled.BuffFamilies.BLUE_KING_CROWN, false)
Resouled:RegisterBuff(Resouled.Buffs.ROYAL_CROWN, "Royal Crown", 8, Resouled.BuffRarity.LEGENDARY,
    Resouled.BuffFamilies.BLUE_KING_CROWN, false)
Resouled:RegisterBuff(Resouled.Buffs.SCARY_FACE, "Scary Face", 3, Resouled.BuffRarity.COMMON,
    Resouled.BuffFamilies.SCARY_FACE, false)
Resouled:RegisterBuff(Resouled.Buffs.FRIGHTENING_VISAGE, "Frightening Visage", 5, Resouled.BuffRarity.RARE,
    Resouled.BuffFamilies.SCARY_FACE, false)
Resouled:RegisterBuff(Resouled.Buffs.TERRIFYING_PHYSIOGNOMY, "Terrifying Physiognomy", 8, Resouled.BuffRarity.LEGENDARY,
    Resouled.BuffFamilies.SCARY_FACE, false)

Resouled:RegisterBuff(Resouled.Buffs.WAR, "War", 0, Resouled.BuffRarity.SPECIAL, Resouled.BuffFamilies.WAR, false,
    Resouled.Souls.WAR) -- Special
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

Resouled:Log("Loaded " .. tostring(#Resouled:GetBuffs()) .. " buffs")


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
