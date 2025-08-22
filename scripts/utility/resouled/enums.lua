---@class ResouledEnums
local enums = {}

enums.Items = {
    A_FRIEND = Isaac.GetItemIdByName("A Friend"),
    AUCTION_GAVEL = Isaac.GetItemIdByName("Auction Gavel"),
    BAG_O_HOLES = Isaac.GetItemIdByName("Bag-O-Holes"),
    BAG_O_TRASH = Isaac.GetItemIdByName("Bag-O-Trash"),
    BLAST_MINER = Isaac.GetItemIdByName("Blast Miner TNT!"),
    CEREMONIAL_BLADE = Isaac.GetItemIdByName("Ceremonial Blade"),
    CHEESE_GRATER = Isaac.GetItemIdByName("Cheese Grater"),
    CLASSIC_ROLLER = Isaac.GetItemIdByName("Classic Roller"),
    CONJOINED_D6 = Isaac.GetItemIdByName("Conjoined D6"),
    COOP_BABY = Isaac.GetItemIdByName("Co-Op Baby"),
    CURSED_SOUL = Isaac.GetItemIdByName("Cursed Soul"),
    DADDY_HAUNT = Isaac.GetItemIdByName("Daddy Haunt"),
    FETAL_HAUNT = Isaac.GetItemIdByName("Fetal Haunt"),
    FRIENDLY_SACK = Isaac.GetItemIdByName("Friendly Sack"),
    GLITCH = Isaac.GetItemIdByName("Glitch"),
    ISAACS_LAST_WILL = Isaac.GetItemIdByName("Isaac's last will"),
    KEEPERS_PENNY = Isaac.GetItemIdByName("Keeper's Penny"),
    MAMA_HAUNT = Isaac.GetItemIdByName("Mama Haunt"),
    BLACK_PROGLOTTID = Isaac.GetItemIdByName("Black Proglottid"),
    PINK_PROGLOTTID = Isaac.GetItemIdByName("Pink Proglottid"),
    RED_PROGLOTTID = Isaac.GetItemIdByName("Red Proglottid"),
    WHITE_PROGLOTTID = Isaac.GetItemIdByName("White Proglottid"),
    PUMPKIN_MASK = Isaac.GetItemIdByName("Pumpkin Mask"),
    RED_GFUEL = Isaac.GetItemIdByName("Red GFUEL"),
    SIBLING_RIVALRY = Isaac.GetItemIdByName("Sibling Rivalry"),
    SLEIGHT_OF_HAND = Isaac.GetItemIdByName("Sleight of Hand"),
    SOULBOND = Isaac.GetItemIdByName("Soulbond"),
    THE_MONSTER = Isaac.GetItemIdByName("The Monster"),
    TRICK_PENNY = Isaac.GetItemIdByName("Trick Penny"),
    TUMOR_BALL = Isaac.GetItemIdByName("Tumor Ball"),
    ULTRA_FLESH_KID = Isaac.GetItemIdByName("Ultra Flesh Kid"),
    UNSTABLE_DNA = Isaac.GetItemIdByName("Unstable DNA"),
}

enums.Buffs = Resouled.Buffs

-- Values double down as animation names in /gfx/status_effects/status_effects.anm2
enums.StatusEffects = {
    BLACK_PROGLOTTID = "Black Proglottid's Tentacles",
    PINK_PROGLOTTID = "Pink Proglottid's Heart",
    RED_PROGLOTTID = "Red Proglottid's Tomato",
    WHITE_PROGLOTTID = "White Proglottid's Ghost",
}

enums.Familiars = {
    A_FRIEND = Resouled:GetEntityByName("A Friend"),
    TUMOR_BALL = Resouled:GetEntityByName("Tumor Ball"),
    DADDY_HAUNT = Resouled:GetEntityByName("Daddy Haunt"),
    MAMA_HAUNT = Resouled:GetEntityByName("Mama Haunt"),
    COOP_BABY = Resouled:GetEntityByName("Coop Baby"),
    ULTRA_FLESH_KID = Resouled:GetEntityByName("Ultra Flesh Kid"),
    BLACK_PROGLOTTID = Resouled:GetEntityByName("Black Proglottid"),
    WHITE_PROGLOTTID = Resouled:GetEntityByName("White Proglottid"),
    PINK_PROGLOTTID = Resouled:GetEntityByName("Pink Proglottid"),
    RED_PROGLOTTID = Resouled:GetEntityByName("Red Proglottid"),
    FETAL_HAUNT = Resouled:GetEntityByName("Fetal Haunt"),
}

return enums
