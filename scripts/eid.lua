--local e = Resouled.EID

local EID_ITEMS = {
    [Resouled.Enums.Items.A_FRIEND] =
    "Spawns a friend that acts like a player # This friend can't die and can't pick up items",
    [Resouled.Enums.Items.AUCTION_GAVEL] =
    "On use removes a random item from your inventory and spawns 10 coins # The next shop item will be the last sold item and will always have a price of 15 cents",
    [Resouled.Enums.Items.BAG_O_HOLES] =
    "Allows you to switch between coin / bomb / key to throw #{{Coin}} Coin: Thows 3 midas tears#{{Bomb}} Bomb: Throws a bomb #{{Key}} Key: Throws 2 sharp keys",
    [Resouled.Enums.Items.BAG_O_TRASH] =
    "On use swings a bag that can collect small pickups # Hold to use 3 collected pickups and spawn 6 blue flies / random trinket / uncommon pickup",
    [Resouled.Enums.Items.BLAST_MINER] =
    "+5 bombs # Replaces your bombs with pushable tnt crates # The crates explode in 3 hits and use your bomb effects",
    [Resouled.Enums.Items.CEREMONIAL_BLADE] =
    "Luck based chance to drop a coin / bomb / key when killing an enemy # On room clear makes Isaac drop 1 pickup with no way to pick it up and spawns a new random pickup",
    [Resouled.Enums.Items.CHEESE_GRATER] =
    "Luck based chance to shoot a special tear that deals 2.5x damage but spawns a leech with 1HP # Reveals all {{QuestionMark}}question mark items",
    [Resouled.Enums.Items.CLASSIC_ROLLER] = "Rerolls items into items with the same quality",
    [Resouled.Enums.Items.CONJOINED_D6] =
    "Rerolls pedestal items in the room # If the quality of the pedestal after the roll is lower than the quality before roll, the player recieves stat ups # If the quality of the pedestal after the roll is higher than the quality before roll, the player recieves stat downs",
    [Resouled.Enums.Items.COOP_BABY] = "Familiar that orbits and shoots last damaged enemy",
    [Resouled.Enums.Items.CURSED_SOUL] =
    "When taking damage you have a chance to gain a soul # When entering an uncleared room you take damage (can't kill you) # If you don't get a soul on hit, your chance to gain a soul goes up # Can spawn up to 6 souls",
    [Resouled.Enums.Items.DADDY_HAUNT] =
    "Locks onto an enemy and hovers around them # Occasionally slams down dealing damage in a small area # Enemies hit have a chance to get feared",
    [Resouled.Enums.Items.FETAL_HAUNT] =
    "Familiar that occasionally rests and cries on the floor shooting tears in every direction",
    [Resouled.Enums.Items.FRIENDLY_SACK] = "After clearing 6 rooms, each familiar spawns a pickup",
    [Resouled.Enums.Items.GLITCH] =
    "Spawns with 3 other passive items cycling the same pedestal # Mutates into next item after clearing a room",
    [Resouled.Enums.Items.ISAACS_LAST_WILL] =
    "Gives you infinite revives as long as you have items # Has the lowest revive priority # When reviving, deletes your items starting from items you obtained on the 1st floor # Next revive items from the next floor get deleted, and so on",
    [Resouled.Enums.Items.KEEPERS_PENNY] =
    "On use, max charge is increased by 1 (max 12) # Spawns a penny for each charge",
    [Resouled.Enums.Items.MAMA_HAUNT] = "Familiar that sings petrifying all enemies in the room for a short time",
    [Resouled.Enums.Items.BLACK_PROGLOTTID] =
    "Familiar that shoots an egg once per room # Enemy hit by this egg will spawn a moderately large black creep pool on death # Enemies standing in this creep get slowed and occasionally immobilized # Creep lasts 40 seconds",
    [Resouled.Enums.Items.PINK_PROGLOTTID] =
    "Familiar that shoots an egg once per room # Enemy hit by this egg will get permanently charmed on death",
    [Resouled.Enums.Items.RED_PROGLOTTID] =
    "Familiar that shoots an egg once per room # Enemy hit by this egg will explote on death applying rotten tomato effect to nearby foes",
    [Resouled.Enums.Items.WHITE_PROGLOTTID] =
    "Familiar that shoots an egg once per room # Enemy hit by this egg will explode on death dealing damage to nearby foes and spawn a purgatory ghost for every dead enemy",
    [Resouled.Enums.Items.PUMPKIN_MASK] = "When Isaac takes damage, all enemies get feared",
    [Resouled.Enums.Items.RED_GFUEL] = "On use spawn a GFUEL LASER",
    [Resouled.Enums.Items.SIBLING_RIVALRY] =
    "Enemies have a chance to get angry at each other # Angry enemies target other enemies of the same type and punch them delivering a massive knockback",
    [Resouled.Enums.Items.SLEIGHT_OF_HAND] =
    "Peeks into the closest room and makes Isaac hold all pickups and items in that room # Usable only if current room is cleared # Cannot peek into uncleared Boss Rooms",
    [Resouled.Enums.Items.SOULBOND] =
    "Creates a bond between 2 enemies # Damaging one of bonded enemies transfers 25% of the damage to the other one # There can be more than one bond at a time",
    [Resouled.Enums.Items.THE_MONSTER] = "TODO",
    [Resouled.Enums.Items.TRICK_PENNY] =
    "Decreases all prices by 1 cent # Spending money has 50% chance to grant 1 cent back",
    [Resouled.Enums.Items.TUMOR_BALL] =
    "Orbiting familiar that blocks projectiles and grows with damage taken # After growing enough splits into 2 tumor balls # Each tumor can split only once per room",
    [Resouled.Enums.Items.ULTRA_FLESH_KID] = "Familiar that crawls towards enemies and deals contact damage",
    [Resouled.Enums.Items.UNSTABLE_DNA] =
    "When entering a new room, there's: # 25% chance to gain a temporary HP up # 25% chance to gain a random temporary stat up # 50% chance to remove all previously granted effects",
}

local EID_TRINKETS = {
    [Resouled.Enums.Trinkets.HANDICAPPED_PLACARD] =
    "Dropping it close to a locked door will open said door#Has 50% chance to break after each use"
}

local EID_BUFFS = {
    --    [Resouled.Enums.Buffs.AGILITY] = e:AutoIcons("Grants +0.3 speed"),
    --    [Resouled.Enums.Buffs.BLUE_KING_CROWN] = e:AutoIcons(
    --        "Enemies have a 15% chance to turn into champions, rare pickup and chests appear 2.5% more often"),
    --    [Resouled.Enums.Buffs.BROKEN_MEMORY] = "All " ..
    --        e:Chest("Golden") ..
    --        " locked chests chest chest chest chest have 50% chance to be replaced with " ..
    --        e:Chest("Dirty") .. " old chests for the whole run",
    --    [Resouled.Enums.Buffs.CONSTELLATION] = e:AutoIcons("Treasure room is replaced by planetarium"),
    --    [Resouled.Enums.Buffs.CROSS] = e:AutoIcons("You spawn with an eternal heart#" ..
    --        e:FadePurple("Holy card for lost and tainted lost")),
    --    [Resouled.Enums.Buffs.CRUCIFIX] = e:AutoIcons(
    --        "The boss item is replaced with a q4 angel deal item, #it costs one heart container. #If you dont have containers, the item is free."),
    --    [Resouled.Enums.Buffs.CURSED_SKULL] = e:AutoIcons(
    --        "You're guaranteed to get a curse first floor, but you will gain one of each pickup and a random trinket spawns"),
    --    [Resouled.Enums.Buffs.DEATH] = e:AutoIcons("Kills all enemies in the room the first time you take damage"),
    --    [Resouled.Enums.Buffs.DEMON] = e:AutoIcons(
    --        "Enemies on death have a 5% chance to explode. Bosses have a 1% chance to mini-bomb explode on hit. lasts the whole run"),
    --    [Resouled.Enums.Buffs.DEVILS_HEAD] = e:AutoIcons(
    --        "The first floor has a guaranteed devil deal. You get a curse of unknown"),
    --    [Resouled.Enums.Buffs.FAMINE] = e:AutoIcons("Food items can not appear the whole run"),
    --    [Resouled.Enums.Buffs.FIEND] = e:AutoIcons(
    --        "Has a chance for a small bomb to spawn near a random enemy, lasts the whole run"),
    --    [Resouled.Enums.Buffs.FORBIDDEN_CRANIUM] = e:AutoIcons(
    --        "You get curse of the lost, unknown, maze, darkness, pain, greed but the first boss item has a q4 devil deal item cycle"),
    --    [Resouled.Enums.Buffs.FORGOTTEN_POLAROID] = e:AutoIcons("Spawns a dire chest at the start"),
    --    [Resouled.Enums.Buffs.FORTUNE] = e:AutoIcons("Grants +2 Luck"),
    --    [Resouled.Enums.Buffs.FRIGHTENING_VISAGE] = e:AutoIcons("Reduces enemy health by 10%"),
    --    [Resouled.Enums.Buffs.HEAVENS_CALL] = e:AutoIcons(
    --        "First floor has a planetarium. +20% planetarium chance until a planetarium spawns"),
    --    [Resouled.Enums.Buffs.IMP] = e:AutoIcons("First treasure room item is a bomb related item"),
    --    [Resouled.Enums.Buffs.KIDS_DRAWING] = e:AutoIcons("You start with gulped Kid's Drawing"),
    --    [Resouled.Enums.Buffs.KING_CROWN] = e:AutoIcons(
    --        "Enemies have a 10% chance to turn into champions, rare pickup and chests appear 5% more often"),
    --    [Resouled.Enums.Buffs.PESTILENCE] = e:AutoIcons("All maggot enemies have 50% chance to become charmed"),
    --    [Resouled.Enums.Buffs.PIRACY] = e:AutoIcons(
    --        "You can steal from the shops if you dont have enough money. #You will get a broken heart for each robbed thing"),
    --    [Resouled.Enums.Buffs.RELIC] = e:AutoIcons("The first floor has a guaranteed angel deal."),
    --    [Resouled.Enums.Buffs.ROYAL_CROWN] = e:AutoIcons(
    --        "Enemies have a 5% chance to turn into champions, rare pickup and chests appear 7.5% more often, keys spawn 5% more"),
    --    [Resouled.Enums.Buffs.SADNESS] = e:AutoIcons("Grants +0.7 Tear rate"),
    --    [Resouled.Enums.Buffs.SCARY_FACE] = e:AutoIcons("Reduces enemy health by 5%"),
    --    [Resouled.Enums.Buffs.SIGHT] = e:AutoIcons("Grants +3 Range"),
    --    [Resouled.Enums.Buffs.SOUL_CATCHER] = e:AutoIcons(
    --        "15% chance to spawn another soul on spawn (obtained by ending the run with 30+ souls)"),
    --    [Resouled.Enums.Buffs.STEAM_GIVEAWAY] = e:AutoIcons("First floor shop is free"),
    --    [Resouled.Enums.Buffs.STEAM_SALE] = e:AutoIcons("First floor shop has a steam sale effect"),
    --    [Resouled.Enums.Buffs.STRENGTH] = e:AutoIcons("Grants +1 Damage"),
    --    [Resouled.Enums.Buffs.TERRIFYING_PHYSIOGNOMY] = e:AutoIcons("Reduces enemy health by 15%"),
    --    [Resouled.Enums.Buffs.WAR] = e:AutoIcons("First bomb used in a run has a mama mega explosion"),
    --    [Resouled.Enums.Buffs.ZODIAC_SIGN] = e:AutoIcons("First treasure room item is a zodiac sign"),
}

for item, description in pairs(EID_ITEMS) do
    EID:addCollectible(item, description)
end

for trinket, description in pairs(EID_TRINKETS) do
    EID:addTrinket(trinket, description)
end

for buff, description in pairs(EID_BUFFS) do
    Resouled:AddBuffDescription(buff, description)
end
