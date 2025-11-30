---@class ResouledEnums
local enums = {}

enums.Achievements = {
    CursedEnemies = Isaac.GetAchievementIdByName("Everything is cursed!"),
    ForeverAlone = Isaac.GetAchievementIdByName("??? now holds forever alone!"),
    SleightOfHand = Isaac.GetAchievementIdByName("Cain now holds sleight of hand!"),
    Soulbond = Isaac.GetAchievementIdByName("The Baleful now holds soulbond!"),
    SpindownDice = Isaac.GetAchievementIdByName("The Broken now holds spindown dice!"),
}

enums.Items = {
    A_FRIEND = Isaac.GetItemIdByName("A Friend"),
    AUCTION_GAVEL = Isaac.GetItemIdByName("Auction Gavel"),
    BAG_O_HOLES = Isaac.GetItemIdByName("Bag-O-Holes"),
    BAG_O_TRASH = Isaac.GetItemIdByName("Bag-O-Trash"),
    BLAST_MINER = Isaac.GetItemIdByName("Blast Miner TNT!"),
    CEREMONIAL_BLADE = Isaac.GetItemIdByName("Ceremonial Blade"),
    CHEESE_GRATER = Isaac.GetItemIdByName("Cheese Grater"),
    CLASSIC_ROLLER = Isaac.GetItemIdByName("Classic Roller"),
    CLUB = Isaac.GetItemIdByName("Club"),
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
    PROTOTYPE_DUMMY = Isaac.GetItemIdByName("Prototype"),
    PROTOTYPE_ACTIVE = Isaac.GetItemIdByName("Prototype_Active"),
    PROTOTYPE_PASSIVE = Isaac.GetItemIdByName("Prototype_Passive"),
    STACYS_EXTRA_HEAD = Isaac.GetItemIdByName("Stacy's Extra Head"),
}

enums.Trinkets = {
    HANDICAPPED_PLACARD = Isaac.GetTrinketIdByName("Handicapped Placard"),
    HAND_ME_DOWNS = Isaac.GetTrinketIdByName("Hand me Downs"),
    MUGGER_BEAN = Isaac.GetTrinketIdByName("Mugger Bean"),
    RECYCLING_STICKER = Isaac.GetTrinketIdByName("Recycling Sticker"),
    LIBRARY_CARD = Isaac.GetTrinketIdByName("Library Card"),
    GAME_SQUID = Isaac.GetTrinketIdByName("Game Squid"),
}

enums.Effects = {
    AIR_SHOCKWAVE = Resouled:GetEntityByName("Air Shockwave"),
    TORNADO = Resouled:GetEntityByName("Tornado"),
    HUNTER_CLAWS = Resouled:GetEntityByName("COTH attack claws"),
    HUNTER_SPEAR = Resouled:GetEntityByName("COTH attack spear"),
    PAPER_GORE_PARTICLE = Resouled:GetEntityByName("Paper Gore Particle"),
    DEATH_STATUE = Resouled:GetEntityByName("Death Statue"),
    CHAIN_PARTICLE = Resouled:GetEntityByName("Chain Particle"),
    WOOD_PARTICLE = Resouled:GetEntityByName("Wood Particle"),
    WOOD_GOLD_PARTICLE = Resouled:GetEntityByName("Wood Gold Particle"),
    DISAPPEAR = Resouled:GetEntityByName("Disappear"),
    GAVEL = Resouled:GetEntityByName("Gavel"),
    BALL_SPARKLE = Resouled:GetEntityByName("Ball Sparkle"),

    MUSIC_NOTE = Resouled:GetEntityByName("Music Note"),
    SOUL_LANTERN = Resouled:GetEntityByName("Soul Lantern"),
    SHUFFLE = Resouled:GetEntityByName("Shuffle"),
    SHUFFLE_SKULL = Resouled:GetEntityByName("Shuffle Skull"),

    STUN_TENTACLE_BLACK = Resouled:GetEntityByName("Stun Tentacle (Black)"),
    STUN_TENTACLE_PINK = Resouled:GetEntityByName("Stun Tentacle (Pink)"),

    PINK_CRACKED_EGG_PARTICLE = Resouled:GetEntityByName("Pink Cracked Egg Particle"),
    WHITE_CRACKED_EGG_PARTICLE = Resouled:GetEntityByName("White Cracked Egg Particle"),
    CLEAR_CRACKED_EGG_PARTICLE = Resouled:GetEntityByName("Clear Cracked Egg Particle"),

    CLUB = Resouled:GetEntityByName("Resouled Club"),
    CLUB_SWING = Resouled:GetEntityByName("Resouled Club Swing"),

    AFTERLIFE_BACKDROP_DECORATION = Resouled:GetEntityByName("Afterlife Backdrop Decoration"),
    MINI_NUKE = Resouled:GetEntityByName("Mini Nuke"),
    AFTERLIFE_BACKDROP_FIX = Resouled:GetEntityByName("Afterlife Backdrop Fix"),
}


enums.Buffs = Resouled.Buffs

-- Values double down as animation names in /gfx_resouled/status_effects/status_effects.anm2
enums.StatusEffects = {
    BLACK_PROGLOTTID = "Black Proglottid's Tentacles",
    PINK_PROGLOTTID = "Pink Proglottid's Heart",
    RED_PROGLOTTID = "Red Proglottid's Tomato",
    WHITE_PROGLOTTID = "White Proglottid's Ghost",
    MUGGER_BEAN = "Mugger Bean"
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

enums.SoundEffects = {
    PAPER_FLIP = Isaac.GetSoundIdByName("Paper Flip"),
    PAPER_DEATH_1 = Isaac.GetSoundIdByName("Paper Death 1"),
    PAPER_DEATH_2 = Isaac.GetSoundIdByName("Paper Death 2"),
    PAPER_DEATH_3 = Isaac.GetSoundIdByName("Paper Death 3"),
    BUFF0 = Isaac.GetSoundIdByName("Buff0"),
    BUFF1 = Isaac.GetSoundIdByName("Buff1"),
    BUFF2 = Isaac.GetSoundIdByName("Buff2"),
    BUFF3 = Isaac.GetSoundIdByName("Buff3"),
    AUCTION_GAVEL_SOLD = Isaac.GetSoundIdByName("Auction Gavel Sold"),
    HOLY_SPAWN_1 = Isaac.GetSoundIdByName("Holy Spawn 1"),
    HOLY_SPAWN_2 = Isaac.GetSoundIdByName("Holy Spawn 2"),
    HOLY_SPAWN_3 = Isaac.GetSoundIdByName("Holy Spawn 3"),
    SOUL_PICKUP_1 = Isaac.GetSoundIdByName("Soul Pickup 1"),
    SOUL_PICKUP_2 = Isaac.GetSoundIdByName("Soul Pickup 2"),
    SOUL_PICKUP_3 = Isaac.GetSoundIdByName("Soul Pickup 3"),
    SOUL_PICKUP_4 = Isaac.GetSoundIdByName("Soul Pickup 4"),
    GAVEL = Isaac.GetSoundIdByName("Gavel"),
    JUMPSCARE = Isaac.GetSoundIdByName("Jumpscare"),
    SOULBOND1 = Isaac.GetSoundIdByName("Soulbond1"),
    SOULBOND2 = Isaac.GetSoundIdByName("Soulbond2"),
    SOULBOND3 = Isaac.GetSoundIdByName("Soulbond3"),
}

return enums
