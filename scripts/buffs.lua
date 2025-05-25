---@enum ResouledBuffFamily
Resouled.BuffFamilies = {
    CURSED_SKULL = 0,
    STEAM_SALE = 1,
    CROSS = 2,
    KIDS_DRAWING = 3,
    ZODIAC_SIGN = 4,
    IMP = 5,
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
    CRUSIFIX = 9,
    KIDS_DRAWING = 10,
    FORGOTTEN_POLAROID = 11,
    BROKEN_MEMORY = 12,
    ZODIAC_SIGN = 13,
    CONSTELLATION = 14,
    HEAVENS_CALL = 15,
    IMP = 16,
    FIEND = 17,
    DEMON = 18,
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

-- REGISTERING BUFF RARITIES
Resouled:RegisterBuffRarity(Resouled.BuffRarity.COMMON, "Common", 0.65)
Resouled:RegisterBuffRarity(Resouled.BuffRarity.RARE, "Rare", 0.25)
Resouled:RegisterBuffRarity(Resouled.BuffRarity.LEGENDARY, "Legendary", 0.1)
Resouled:RegisterBuffRarity(Resouled.BuffRarity.SPECIAL, "Special", 0)

-- REGISTERING BUFFS
Resouled:RegisterBuff(Resouled.Buffs.CURSED_SKULL, "Cursed Skull", 3, Resouled.BuffRarity.COMMON, Resouled.BuffFamilies.CURSED_SKULL)
Resouled:RegisterBuff(Resouled.Buffs.DEVILS_HEAD, "Devil's Head", 5, Resouled.BuffRarity.RARE, Resouled.BuffFamilies.CURSED_SKULL)
Resouled:RegisterBuff(Resouled.Buffs.FORBIDDEN_CRANIUM, "Forbidden Cranium", 5, Resouled.BuffRarity.LEGENDARY, Resouled.BuffFamilies.CURSED_SKULL)
Resouled:RegisterBuff(Resouled.Buffs.STEAM_SALE, "Steam Sale", 3, Resouled.BuffRarity.COMMON, Resouled.BuffFamilies.STEAM_SALE)
Resouled:RegisterBuff(Resouled.Buffs.STEAM_GIVEAWAY, "Steam Giveaway", 5, Resouled.BuffRarity.RARE, Resouled.BuffFamilies.STEAM_SALE)
Resouled:RegisterBuff(Resouled.Buffs.PIRACY, "Piracy", 8, Resouled.BuffRarity.LEGENDARY, Resouled.BuffFamilies.STEAM_SALE)
Resouled:RegisterBuff(Resouled.Buffs.CROSS, "Cross", 3, Resouled.BuffRarity.COMMON, Resouled.BuffFamilies.CROSS)
Resouled:RegisterBuff(Resouled.Buffs.RELIC, "Relic", 5, Resouled.BuffRarity.RARE, Resouled.BuffFamilies.CROSS)
Resouled:RegisterBuff(Resouled.Buffs.CRUSIFIX, "Crusifix", 8, Resouled.BuffRarity.LEGENDARY, Resouled.BuffFamilies.CROSS)
Resouled:RegisterBuff(Resouled.Buffs.KIDS_DRAWING, "Kid's Drawing", 3, Resouled.BuffRarity.COMMON, Resouled.BuffFamilies.KIDS_DRAWING)
Resouled:RegisterBuff(Resouled.Buffs.FORGOTTEN_POLAROID, "Forgotten Polaroid", 5, Resouled.BuffRarity.RARE, Resouled.BuffFamilies.KIDS_DRAWING)
Resouled:RegisterBuff(Resouled.Buffs.BROKEN_MEMORY, "Broken Memory", 8, Resouled.BuffRarity.LEGENDARY, Resouled.BuffFamilies.KIDS_DRAWING)
Resouled:RegisterBuff(Resouled.Buffs.ZODIAC_SIGN, "Zodiac Sign", 3, Resouled.BuffRarity.COMMON, Resouled.BuffFamilies.ZODIAC_SIGN)
Resouled:RegisterBuff(Resouled.Buffs.CONSTELLATION, "Constellation", 5, Resouled.BuffRarity.RARE, Resouled.BuffFamilies.ZODIAC_SIGN)
Resouled:RegisterBuff(Resouled.Buffs.HEAVENS_CALL, "Heaven's Call", 8,  Resouled.BuffRarity.LEGENDARY, Resouled.BuffFamilies.ZODIAC_SIGN)
Resouled:RegisterBuff(Resouled.Buffs.IMP, "Imp", 3, Resouled.BuffRarity.COMMON, Resouled.BuffFamilies.IMP)
Resouled:RegisterBuff(Resouled.Buffs.FIEND, "Fiend", 5, Resouled.BuffRarity.RARE, Resouled.BuffFamilies.IMP)
Resouled:RegisterBuff(Resouled.Buffs.DEMON, "Demon", 8, Resouled.BuffRarity.LEGENDARY, Resouled.BuffFamilies.IMP)


-- IMPORTING BUFF SCRIPTS
include("scripts.buffs.cursed_skull")