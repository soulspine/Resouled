---@enum ResouledBuffFamily
Resouled.BuffFamilies = {
    CURSED_SKULL = 0,
    STEAM_SALE = 1,
    CROSS = 2,
    KIDS_DRAWING = 3,
    ZODIAC_SIGN = 4,
    IMP = 5,
    THE_MOON = 6,
    BLUE_KING_CROWN = 7,

    WAR = 8, --Special start from here
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
    BLACK_HOLE = 21,
    BLUE_KING_CROWN = 22,
    KING_CROWN = 23,
    ROYAL_CROWN = 24,

    WAR = 25, -- Special start from here
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
Resouled:RegisterBuffFamily(Resouled.BuffFamilies.THE_MOON, "The Moon", "gfx/buffs/the_moon.png")
Resouled:RegisterBuffFamily(Resouled.BuffFamilies.BLUE_KING_CROWN, "Blue King Crown", "gfx/buffs/blue_king_crown.png")

Resouled:RegisterBuffFamily(Resouled.BuffFamilies.WAR, "War", "gfx/buffs/war.png") -- Special

-- REGISTERING BUFF RARITIES
Resouled:RegisterBuffRarity(Resouled.BuffRarity.COMMON, "Common", 0.65)
Resouled:RegisterBuffRarity(Resouled.BuffRarity.RARE, "Rare", 0.25)
Resouled:RegisterBuffRarity(Resouled.BuffRarity.LEGENDARY, "Legendary", 0.1)
Resouled:RegisterBuffRarity(Resouled.BuffRarity.SPECIAL, "Special", 0)

-- REGISTERING BUFFS
Resouled:RegisterBuff(Resouled.Buffs.CURSED_SKULL, "Cursed Skull", 3, Resouled.BuffRarity.COMMON, Resouled.BuffFamilies.CURSED_SKULL, false)
Resouled:RegisterBuff(Resouled.Buffs.DEVILS_HEAD, "Devil's Head", 5, Resouled.BuffRarity.RARE, Resouled.BuffFamilies.CURSED_SKULL, false)
Resouled:RegisterBuff(Resouled.Buffs.FORBIDDEN_CRANIUM, "Forbidden Cranium", 8, Resouled.BuffRarity.LEGENDARY, Resouled.BuffFamilies.CURSED_SKULL, false)
Resouled:RegisterBuff(Resouled.Buffs.STEAM_SALE, "Steam Sale", 3, Resouled.BuffRarity.COMMON, Resouled.BuffFamilies.STEAM_SALE, true)
Resouled:RegisterBuff(Resouled.Buffs.STEAM_GIVEAWAY, "Steam Giveaway", 5, Resouled.BuffRarity.RARE, Resouled.BuffFamilies.STEAM_SALE, false)
Resouled:RegisterBuff(Resouled.Buffs.PIRACY, "Piracy", 8, Resouled.BuffRarity.LEGENDARY, Resouled.BuffFamilies.STEAM_SALE, false)
Resouled:RegisterBuff(Resouled.Buffs.CROSS, "Cross", 3, Resouled.BuffRarity.COMMON, Resouled.BuffFamilies.CROSS, false)
Resouled:RegisterBuff(Resouled.Buffs.RELIC, "Relic", 5, Resouled.BuffRarity.RARE, Resouled.BuffFamilies.CROSS, false)
Resouled:RegisterBuff(Resouled.Buffs.CRUCIFIX, "Crucifix", 8, Resouled.BuffRarity.LEGENDARY, Resouled.BuffFamilies.CROSS, false)
Resouled:RegisterBuff(Resouled.Buffs.KIDS_DRAWING, "Kid's Drawing", 3, Resouled.BuffRarity.COMMON, Resouled.BuffFamilies.KIDS_DRAWING, true)
Resouled:RegisterBuff(Resouled.Buffs.FORGOTTEN_POLAROID, "Forgotten Polaroid", 5, Resouled.BuffRarity.RARE, Resouled.BuffFamilies.KIDS_DRAWING, true)
Resouled:RegisterBuff(Resouled.Buffs.BROKEN_MEMORY, "Broken Memory", 8, Resouled.BuffRarity.LEGENDARY, Resouled.BuffFamilies.KIDS_DRAWING, true)
Resouled:RegisterBuff(Resouled.Buffs.ZODIAC_SIGN, "Zodiac Sign", 3, Resouled.BuffRarity.COMMON, Resouled.BuffFamilies.ZODIAC_SIGN, false)
Resouled:RegisterBuff(Resouled.Buffs.CONSTELLATION, "Constellation", 5, Resouled.BuffRarity.RARE, Resouled.BuffFamilies.ZODIAC_SIGN, false)
Resouled:RegisterBuff(Resouled.Buffs.HEAVENS_CALL, "Heaven's Call", 8,  Resouled.BuffRarity.LEGENDARY, Resouled.BuffFamilies.ZODIAC_SIGN, true)
Resouled:RegisterBuff(Resouled.Buffs.IMP, "Imp", 3, Resouled.BuffRarity.COMMON, Resouled.BuffFamilies.IMP, false)
Resouled:RegisterBuff(Resouled.Buffs.FIEND, "Fiend", 5, Resouled.BuffRarity.RARE, Resouled.BuffFamilies.IMP, false)
Resouled:RegisterBuff(Resouled.Buffs.DEMON, "Demon", 8, Resouled.BuffRarity.LEGENDARY, Resouled.BuffFamilies.IMP, false)
Resouled:RegisterBuff(Resouled.Buffs.THE_MOON, "The Moon", 3, Resouled.BuffRarity.COMMON, Resouled.BuffFamilies.THE_MOON, false)
Resouled:RegisterBuff(Resouled.Buffs.THE_SUN, "The Sun", 5, Resouled.BuffRarity.RARE, Resouled.BuffFamilies.THE_MOON, false)
Resouled:RegisterBuff(Resouled.Buffs.BLACK_HOLE, "Black Hole", 8, Resouled.BuffRarity.LEGENDARY, Resouled.BuffFamilies.THE_MOON, false)
Resouled:RegisterBuff(Resouled.Buffs.BLUE_KING_CROWN, "Blue King Crown", 3, Resouled.BuffRarity.COMMON, Resouled.BuffFamilies.BLUE_KING_CROWN, false)
Resouled:RegisterBuff(Resouled.Buffs.KING_CROWN, "King Crown", 5, Resouled.BuffRarity.RARE, Resouled.BuffFamilies.BLUE_KING_CROWN, false)
Resouled:RegisterBuff(Resouled.Buffs.ROYAL_CROWN, "Royal Crown", 8, Resouled.BuffRarity.LEGENDARY, Resouled.BuffFamilies.BLUE_KING_CROWN, false)

Resouled:RegisterBuff(Resouled.Buffs.WAR, "War", 0, Resouled.BuffRarity.SPECIAL, Resouled.BuffFamilies.WAR, true, Resouled.Souls.WAR) -- Special

Resouled:Log("Loaded "..tostring(#Resouled:GetBuffs()).." buffs")


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

include("scripts.buffs.war")