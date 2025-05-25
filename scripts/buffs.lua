---@enum ResouledBuffFamily
Resouled.BuffFamilies = {
    CURSED_SKULL = 0,
}

---@enum ResouledBuff
Resouled.Buffs = {
    CURSED_SKULL = 0,
    DEVILS_HEAD = 1,
    FORBIDDEN_CRANIUM = 2,
}

---@enum ResouledBuffRarity
Resouled.BuffRarity = {
    COMMON = 0,
    RARE = 1,
    LEGENDARY = 2,
}

-- REGISTERING BUFF FAMILIES
Resouled:RegisterBuffFamily(Resouled.BuffFamilies.CURSED_SKULL, "Cursed Skull", "gfx/buffs/cursed_skull.png")


-- REGISTERING BUFFS
Resouled:RegisterBuff(Resouled.Buffs.CURSED_SKULL, "Cursed Skull", 3, Resouled.BuffRarity.COMMON, Resouled.BuffFamilies.CURSED_SKULL)
Resouled:RegisterBuff(Resouled.Buffs.DEVILS_HEAD, "Devil's Head", 5, Resouled.BuffRarity.RARE, Resouled.BuffFamilies.CURSED_SKULL)
Resouled:RegisterBuff(Resouled.Buffs.FORBIDDEN_CRANIUM, "Forbidden Cranium", 5, Resouled.BuffRarity.LEGENDARY, Resouled.BuffFamilies.CURSED_SKULL)


-- IMPORTING BUFF SCRIPTS
include("scripts.buffs.cursed_skull")