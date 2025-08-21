---@class ResouledEID
local Reid = {}

if not EID then
    Resouled:LogError("EID not loaded, skipping ResouledEID function")
    goto noEID
end

Reid.TextColors = {}

---@param string1 string
---@param string2 string
---@param position integer
---@return string
local function insertIntoString(string1, string2, position)
    return string1:sub(1, position) .. string2 .. string1:sub(position + 1)
end

---@param r number
---@param g number
---@param b number
local function brightColor(r, g, b)
    return KColor(r / 255 * 2, g / 255 * 2, b / 255 * 2, 1)
end

---@param shortcut string
---@param color? KColor
---@param colorFunction? function
function Reid:RegisterColor(shortcut, color, colorFunction)
    local key = "Resouled" .. shortcut

    if not Reid.TextColors[shortcut] then
        Reid.TextColors[shortcut] = "{{" .. key .. "}}"
    else
        Resouled:LogError("Trying to overwrite an already registered color")
    end

    EID:addColor(key, color, colorFunction)
end

---@param shortcut string
---@return string | nil
function Reid:GetColorByShortcut(shortcut)
    return Reid.TextColors[shortcut]
end

---@param shortcut string
---@param color KColor
---@param speed integer --The higher the number the slower it flashes
---@param maxColor? KColor --The max color the fade can achieve
function Reid:RegisterFadeColor(shortcut, color, speed, maxColor)
    Reid:RegisterColor(shortcut, nil, function(color2)
        local maxAnimTime = speed
        local maxAnimTime2 = speed * 2
        local animTime = Isaac.GetFrameCount() % maxAnimTime / maxAnimTime
        local animTime2 = Isaac.GetFrameCount() % maxAnimTime2 / maxAnimTime2

        animTime = math.abs(animTime - animTime2) * 2

        local color2nd = animTime

        if not maxColor then
            maxColor = KColor(1, 1, 1, 1)
        end

        color2 = KColor(
            (color.Red + (color2nd * (1 - color.Red))) * maxColor.Red,
            (color.Green + (color2nd * (1 - color.Green))) * maxColor.Green,
            (color.Blue + (color2nd * (1 - color.Blue))) * maxColor.Blue,
            1)

        return color2
    end)
end

---@return string
function Reid:ResetColorModifiers()
    return "{{ColorReset}}"
end

Reid:RegisterFadeColor("FadeNegativeStat", KColor(1, 0, 0, 1), 50)
---@param String string
---@return string
function Reid:FadeNegativeStat(String)
    return "{{ArrowDown}}" .. Reid:GetColorByShortcut("FadeNegativeStat") .. String .. Reid:ResetColorModifiers()
end

---@param String string
---@return string
function Reid:FadeNegativeStatNextLine(String)
    return "#{{ArrowDown}} " .. " " .. Reid:GetColorByShortcut("FadeNegativeStat") .. String ..
    Reid:ResetColorModifiers()
end

Reid:RegisterFadeColor("FadePositiveStat", KColor(0, 1, 0, 1), 50)
---@param String string
---@return string
function Reid:FadePositiveStat(String)
    return "{{ArrowUp}}" .. Reid:GetColorByShortcut("FadePositiveStat") .. String .. Reid:ResetColorModifiers()
end

---@param String string
---@return string
function Reid:FadePositiveStatNextLine(String)
    return "#{{ArrowUp}} " .. " " .. Reid:GetColorByShortcut("FadePositiveStat") .. String .. Reid:ResetColorModifiers()
end

Reid:RegisterColor("PositiveStat", KColor(0, 1, 0, 1))
---@param String string
---@return string
function Reid:PositiveStat(String)
    return "{{ArrowUp}}" .. Reid:GetColorByShortcut("PositiveStat") .. String .. Reid:ResetColorModifiers()
end

---@param String string
---@return string
function Reid:PositiveStatNextLine(String)
    return "#{{ArrowUp}} " .. " " .. Reid:GetColorByShortcut("PositiveStat") .. String .. Reid:ResetColorModifiers()
end

Reid:RegisterColor("NegativeStat", KColor(1, 0, 0, 1))
---@param String string
---@return string
function Reid:NegativeStat(String)
    return "{{ArrowDown}}" .. Reid:GetColorByShortcut("NegativeStat") .. String .. Reid:ResetColorModifiers()
end

---@param String string
---@return string
function Reid:NegativeStatNextLine(String)
    return "#{{ArrowDown}} " .. " " .. Reid:GetColorByShortcut("NegativeStat") .. String .. Reid:ResetColorModifiers()
end

---@param String string
---@return string
function Reid:Fade(String)
    return "{{ColorFade}}" .. String .. Reid:ResetColorModifiers()
end

---@param String string
---@return string
function Reid:Rainbow(String)
    return "{{ColorRainbow}}" .. String .. Reid:ResetColorModifiers()
end

Reid:RegisterFadeColor("FadeWarning", KColor(1, 1, 0, 1), 50)
---@param String string
---@return string
function Reid:FadeWarning(String)
    return "{{Warning}}" .. Reid:GetColorByShortcut("FadeWarning") .. String .. Reid:ResetColorModifiers()
end

---@param String string
---@return string
function Reid:FadeWarningNextLine(String)
    return "#{{Warning}} " .. " " .. Reid:GetColorByShortcut("FadeWarning") .. String .. Reid:ResetColorModifiers()
end

Reid:RegisterColor("Warning", KColor(1, 1, 0, 1))
---@param String string
---@return string
function Reid:Warning(String)
    return "{{Warning}}" .. Reid:GetColorByShortcut("Warning") .. String .. Reid:ResetColorModifiers()
end

---@param String string
---@return string
function Reid:WarningNextLine(String)
    return "#{{Warning}} " .. " " .. Reid:GetColorByShortcut("Warning") .. String .. Reid:ResetColorModifiers()
end

Reid:RegisterFadeColor("FadeBlue", KColor(0.25, 0.5, 1, 1), 50)
---@param String string
---@return string
function Reid:FadeBlue(String)
    return Reid:GetColorByShortcut("FadeBlue") .. String .. Reid:ResetColorModifiers()
end

Reid:RegisterFadeColor("FadeOrange", KColor(1, 0.5, 0.25, 1), 50)
---@param String string
---@return string
function Reid:FadeOrange(String)
    return Reid:GetColorByShortcut("FadeOrange") .. String .. Reid:ResetColorModifiers()
end

Reid:RegisterFadeColor("FadePurple", KColor(0.75, 0.5, 1, 1), 50)
---@param String string
---@return string
function Reid:FadePurple(String)
    return Reid:GetColorByShortcut("FadePurple") .. String .. Reid:ResetColorModifiers()
end

Reid:RegisterFadeColor("FadeGreen", KColor(0, 1, 0, 1), 50)
---@param String string
---@return string
function Reid:FadeGreen(String)
    return Reid:GetColorByShortcut("FadeGreen") .. String .. Reid:ResetColorModifiers()
end

Reid:RegisterColor("Curse", brightColor(142, 84, 242))
---@param String string
---@return string
function Reid:ColorCurse(String)
    return Reid:GetColorByShortcut("Curse") .. String .. Reid:ResetColorModifiers()
end

Reid:RegisterColor("Item", brightColor(241, 169, 0))
---@param String string
---@return string
function Reid:ColorItem(String)
    return Reid:GetColorByShortcut("Item") .. String .. Reid:ResetColorModifiers()
end

Reid:RegisterColor("Trinket", brightColor(85, 68, 60))
---@param String string
---@return string
function Reid:ColorTrinket(String)
    return Reid:GetColorByShortcut("Trinket") .. String .. Reid:ResetColorModifiers()
end

Reid:RegisterColor("Pickup", brightColor(255, 79, 0))
---@param String string
---@return string
function Reid:ColorPickup(String)
    return Reid:GetColorByShortcut("Pickup") .. String .. Reid:ResetColorModifiers()
end

---@return string
function Reid:Coin()
    return "{{Coin}}"
end

---@return string
function Reid:Bomb()
    return "{{Bomb}}"
end

---@return string
function Reid:GoldenBomb()
    return "{{GoldenBomb}}"
end

---@return string
function Reid:Key()
    return "{{Key}}"
end

---@return string
function Reid:GoldenKey()
    return "{{GoldenKey}}"
end

---@return string
function Reid:Damage()
    return "{{Damage}}"
end

---@return string
function Reid:DamageSmall()
    return "{{DamageSmall}}"
end

---@return string
function Reid:Speed()
    return "{{Speed}}"
end

---@return string
function Reid:SpeedSmall()
    return "{{SpeedSmall}}"
end

---@return string
function Reid:Tears()
    return "{{Tears}}"
end

---@return string
function Reid:TearsSmall()
    return "{{TearsSmall}}"
end

---@return string
function Reid:Range()
    return "{{Range}}"
end

---@return string
function Reid:RangeSmall()
    return "{{RangeSmall}}"
end

---@return string
function Reid:Shotspeed()
    return "{{Shotspeed}}"
end

---@return string
function Reid:ShotspeedSmall()
    return "{{ShotspeedSmall}}"
end

---@return string
function Reid:Luck()
    return "{{Luck}}"
end

---@return string
function Reid:LuckSmall()
    return "{{LuckSmall}}"
end

---@enum AutoEIDIconChests
local chests = {
    Golden = "Golden",
    Red = "Red",
    Spiked = "Spiked",
    Trap = "Trap",
    Holy = "Holy",
    Wooden = "Wooden",
    Stone = "Stone",
    Haunted = "Haunted",
    Dire = "Dirty",
    Mega = "Mega"
}

---@param type? AutoEIDIconChests
---@return string
function Reid:Chest(type)
    return "{{" .. (type or "") .. "Chest}}"
end

---@return string
function Reid:Trinket()
    return "{{Trinket}}"
end

---@return string
function Reid:Item()
    return "{{Collectible}}"
end

---@return string
function Reid:Q0()
    return "{{Quality0}}"
end

---@return string
function Reid:Q1()
    return "{{Quality1}}"
end

---@return string
function Reid:Q2()
    return "{{Quality2}}"
end

---@return string
function Reid:Q3()
    return "{{Quality3}}"
end

---@return string
function Reid:Q4()
    return "{{Quality4}}"
end

---@return string
function Reid:Pill()
    return "{{Pill}}"
end

---@return string
function Reid:Card()
    return "{{Card}}"
end

---@return string
function Reid:Rune()
    return "{{Rune}}"
end

---@return string
function Reid:Battery()
    return "{{Battery}}"
end

---@return string
function Reid:Poop()
    return "{{PoopPickup}}"
end

---@return string
function Reid:Sack()
    return "{{GrabBag}}"
end

---@return string
function Reid:Angel()
    return "{{AngelChanceSmall}}"
end

---@return string
function Reid:Devil()
    return "{{DevilChanceSmall}}"
end

---@return string
function Reid:DealChance()
    return "{{AngelDevilChanceSmall}}"
end

---@return string
function Reid:Planetarium()
    return "{{PlanetariumChanceSmall}}"
end

---@return string
function Reid:Fear()
    return "{{Fear}}"
end

---@return string
function Reid:Charm()
    return "{{Charm}}"
end

---@return string
function Reid:Bait()
    return "{{Bait}}"
end

---@return string
function Reid:Bleeding()
    return "{{BleedingOut}}"
end

---@return string
function Reid:Brimstone()
    return "{{BrimstoneCurse}}"
end

---@return string
function Reid:Burn()
    return "{{Burning}}"
end

---@return string
function Reid:Confusion()
    return "{{Confusion}}"
end

---@return string
function Reid:Slow()
    return "{{Slow}}"
end

---@return string
function Reid:Magnetize()
    return "{{Magnetize}}"
end

---@return string
function Reid:Marked()
    return "{{Marked}}"
end

---@return string
function Reid:Weakness()
    return "{{Weakness}}"
end

---@return string
function Reid:Freezing()
    return "{{Freezing}}"
end

---@return string
function Reid:Poison()
    return "{{Poison}}"
end

---@return string
function Reid:Treasure()
    return "{{TreasureRoom}}"
end

---@return string
function Reid:Secret()
    return "{{SecretRoom}}"
end

---@return string
function Reid:BlackSack()
    return "{{BlackSack}}"
end

---@return string
function Reid:SuperSecret()
    return "{{SuperSecretRoom}}"
end

---@return string
function Reid:UltraSecret()
    return "{{UltraSecretRoom}}"
end

---@return string
function Reid:Shop()
    return "{{Shop}}"
end

---@return string
function Reid:Library()
    return "{{Library}}"
end

---@return string
function Reid:MiniBoss()
    return "{{MiniBoss}}"
end

---@return string
function Reid:Boss()
    return "{{BossRoom}}"
end

---@return string
function Reid:ChallengeRoom()
    return "{{ChallengeRoom}}"
end

---@return string
function Reid:BossChallengeRoom()
    return "{{BossRushRoom}}"
end

---@return string
function Reid:CurseRoom()
    return "{{CursedRoom}}"
end

---@return string
function Reid:SacrificeRoom()
    return "{{SacrificeRoom}}"
end

---@return string
function Reid:ArcadeRoom()
    return "{{ArcadeRoom}}"
end

---@return string
function Reid:GreedTreasureRoom()
    return "{{GreedTreasureRoom}}"
end

---@return string
function Reid:DiceRoom()
    return "{{DiceRoom}}"
end

---@return string
function Reid:ChestRoom()
    return "{{ChestRoom}}"
end

---@return string
function Reid:Bedroom()
    return "{{IsaacsRoom}}"
end

---@return string
function Reid:DirtyBedroom()
    return "{{BarrenRoom}}"
end

---@return string
function Reid:Mirror()
    return "{{MirrorRoom}}"
end

---@return string
function Reid:Beggar()
    return "{{Beggar}}"
end

---@return string
function Reid:RottenBeggar()
    return "{{RottenBeggar}}"
end

---@return string
function Reid:BombBeggar()
    return "{{BombBeggar}}"
end

---@return string
function Reid:KeyBeggar()
    return "{{KeyBeggar}}"
end

---@return string
function Reid:BatteryBeggar()
    return "{{BatteryBeggar}}"
end

---@return string
function Reid:DemonBeggar()
    return "{{DemonBeggar}}"
end

---@return string
function Reid:FortuneMachine()
    return "{{FortuneTeller}}"
end

---@return string
function Reid:SlotMachine()
    return "{{Slotmachine}}"
end

---@return string
function Reid:BloodDono()
    return "{{BloodDonationMachine}}"
end

---@return string
function Reid:Confessional()
    return "{{Confessional}}"
end

---@return string
function Reid:DonationMachine()
    return "{{DonationMachine}}"
end

---@return string
function Reid:RestockMachine()
    return "{{RestockMachine}}"
end

---@return string
function Reid:CraneGame()
    return "{{CraneGame}}"
end

---@return string
function Reid:Mantle()
    return "{{HolyMantleSmall}}"
end

---@return string
function Reid:HardMode()
    return "{{HardModeSmall}}"
end

---@return string
function Reid:GreedMode()
    return "{{GreedModeSmall}}"
end

---@return string
function Reid:GreedierMode()
    return "{{GreedierModeSmall}}"
end

---@return string
function Reid:VictoryLap()
    return "{{VictoryLapSmall}}"
end

---@enum AutoEIDIconHearts
local hearts = {
    Half = "Half",
    Ethernal = "Ethernal",
    Empty = "Empty",
    Blended = "Blended",
    Bone = "Bone",
    HalfBone = "HalfBone",
    EmptyBone = "EmptyBone",
    Soul = "Soul",
    HalfSoul = "HalfSoul",
    Black = "Black",
    HalfBlack = "HalfBlack",
    Golden = "Golden",
    Coin = "Coin",
    HalfCoin = "HalfCoin",
    EmptyCoin = "EmptyCoin",
    Rotten = "Rotten",
    Broken = "Broken",
    RottenBone = "RottenBone",
    Unknown = "Unknown",
}

---@param type? AutoEIDIconHearts
---@return string
function Reid:Heart(type)
    return "{{" .. (type or "") .. "Heart}}"
end

---@param String string
---@param searchedWord string
---@param icon string
---@param noIcon? boolean
---@param ... table
local function repeatFindInsertUntilStringEnds(String, searchedWord, icon, noIcon, ...)
    local entries = { ... }
    local String2 = String:lower()

    local iconCount = 0

    local NoIcon = noIcon or false
    local SearchedWord = searchedWord
    local Icon = icon

    local position = String2:find(SearchedWord)
    while position do
        for _, Table in pairs(entries) do
            ---@type string
            local specialWord = Table[1] .. " "
            ---@type string
            local specialIcon = Table[2]

            local specialPos = position - specialWord:len()

            if String:find(specialWord, specialPos) == specialPos then
                Icon = specialIcon
                SearchedWord = specialWord .. searchedWord
                position = specialPos

                NoIcon = false
            end
        end

        Icon = Icon .. " "

        if NoIcon == false then
            String = insertIntoString(String, Icon, position - 1 + Icon:len() * iconCount)

            iconCount = iconCount + 1
        end

        position = String2:find(SearchedWord, position + SearchedWord:len())

        SearchedWord = searchedWord
        Icon = icon
    end
    return String
end

---@param String string
---@return string
function Reid:AutoIcons(String)
    String = repeatFindInsertUntilStringEnds(String, "bomb", Reid:Bomb(), nil, { [1] = "golden", [2] = Reid:GoldenBomb() })
    String = repeatFindInsertUntilStringEnds(String, "coin", Reid:Coin())
    String = repeatFindInsertUntilStringEnds(String, "penny", Reid:Coin())
    String = repeatFindInsertUntilStringEnds(String, "key", Reid:Key(), nil, { [1] = "golden", [2] = Reid:GoldenKey() })
    String = repeatFindInsertUntilStringEnds(String, "chest", Reid:Chest(), false,
        { [1] = "golden", [2] = Reid:Chest(chests.Golden) }, { [1] = "locked", [2] = Reid:Chest(chests.Golden) },
        { [1] = "red", [2] = Reid:Chest(chests.Red) }, { [1] = "eternal", [2] = Reid:Chest(chests.Holy) },
        { [1] = "spiked", [2] = Reid:Chest(chests.Spiked) },
        { [1] = "mimic ", [2] = Reid:Chest(chests.Trap) }, { [1] = "trapped", [2] = Reid:Chest(chests.Trap) },
        { [1] = "mega", [2] = Reid:Chest(chests.Mega) },
        { [1] = "big", [2] = Reid:Chest(chests.Mega) }, { [1] = "bomb", [2] = Reid:Chest(chests.Stone) },
        { [1] = "stone", [2] = Reid:Chest(chests.Stone) },
        { [1] = "wooden", [2] = Reid:Chest(chests.Wooden) }, { [1] = "haunted", [2] = Reid:Chest(chests.Haunted) },
        { [1] = "old", [2] = Reid:Chest(chests.Dire) },
        { [1] = "dire", [2] = Reid:Chest(chests.Dire) }
    )
    String = repeatFindInsertUntilStringEnds(String, "trinket", Reid:Trinket())
    String = repeatFindInsertUntilStringEnds(String, "collectible", Reid:Item())
    String = repeatFindInsertUntilStringEnds(String, "item", Reid:Item())
    String = repeatFindInsertUntilStringEnds(String, "q0", Reid:Q0())
    String = repeatFindInsertUntilStringEnds(String, "quality 0", Reid:Q0())
    String = repeatFindInsertUntilStringEnds(String, "q1", Reid:Q1())
    String = repeatFindInsertUntilStringEnds(String, "quality 1", Reid:Q1())
    String = repeatFindInsertUntilStringEnds(String, "q2", Reid:Q2())
    String = repeatFindInsertUntilStringEnds(String, "quality 2", Reid:Q2())
    String = repeatFindInsertUntilStringEnds(String, "q3", Reid:Q3())
    String = repeatFindInsertUntilStringEnds(String, "quality 3", Reid:Q3())
    String = repeatFindInsertUntilStringEnds(String, "q4", Reid:Q4())
    String = repeatFindInsertUntilStringEnds(String, "quality 4", Reid:Q4())
    String = repeatFindInsertUntilStringEnds(String, "pill", Reid:Pill())
    String = repeatFindInsertUntilStringEnds(String, "card", Reid:Card())
    String = repeatFindInsertUntilStringEnds(String, "rune", Reid:Rune())
    String = repeatFindInsertUntilStringEnds(String, "battery", Reid:Battery())
    String = repeatFindInsertUntilStringEnds(String, "poop", Reid:Poop())
    String = repeatFindInsertUntilStringEnds(String, "sack", Reid:Sack(), nil, { [1] = "black", [2] = Reid:BlackSack() })
    String = repeatFindInsertUntilStringEnds(String, "grab bag", Reid:Sack(), nil,
        { [1] = "black", [2] = Reid:BlackSack() })
    String = repeatFindInsertUntilStringEnds(String, "luck", Reid:LuckSmall())
    String = repeatFindInsertUntilStringEnds(String, "damage", Reid:DamageSmall())
    String = repeatFindInsertUntilStringEnds(String, "range", Reid:RangeSmall())
    String = repeatFindInsertUntilStringEnds(String, "tears", Reid:TearsSmall())
    String = repeatFindInsertUntilStringEnds(String, "tearrate", Reid:TearsSmall())
    String = repeatFindInsertUntilStringEnds(String, "speed", Reid:SpeedSmall(), nil,
        { [1] = "shot", [2] = Reid:ShotspeedSmall() })
    String = repeatFindInsertUntilStringEnds(String, "angel", Reid:Angel())
    String = repeatFindInsertUntilStringEnds(String, "devil", Reid:Devil())
    String = repeatFindInsertUntilStringEnds(String, "deal", Reid:DealChance(), nil, { [1] = "devil", [2] = "" },
        { [1] = "angel", [2] = "" })
    String = repeatFindInsertUntilStringEnds(String, "planetarium", Reid:Planetarium())
    String = repeatFindInsertUntilStringEnds(String, "fear", Reid:Fear())
    String = repeatFindInsertUntilStringEnds(String, "charm", Reid:Charm())
    String = repeatFindInsertUntilStringEnds(String, "bait", Reid:Bait())
    String = repeatFindInsertUntilStringEnds(String, "bleeding", Reid:Bleeding())
    String = repeatFindInsertUntilStringEnds(String, "burn", Reid:Burn())
    String = repeatFindInsertUntilStringEnds(String, "confusion", Reid:Confusion())
    String = repeatFindInsertUntilStringEnds(String, "confus", Reid:Confusion())
    String = repeatFindInsertUntilStringEnds(String, "slow", Reid:Slow())
    String = repeatFindInsertUntilStringEnds(String, "poison", Reid:Poison())
    String = repeatFindInsertUntilStringEnds(String, "magnet", Reid:Magnetize())
    String = repeatFindInsertUntilStringEnds(String, "marked", Reid:Marked(), nil,
        { [1] = "brimstone", [2] = Reid:Brimstone() })
    String = repeatFindInsertUntilStringEnds(String, "weak", Reid:Weakness())
    String = repeatFindInsertUntilStringEnds(String, "freez", Reid:Freezing())
    String = repeatFindInsertUntilStringEnds(String, "frozen", Reid:Freezing())
    String = repeatFindInsertUntilStringEnds(String, "posison", Reid:Poison())
    String = repeatFindInsertUntilStringEnds(String, "treasure", Reid:Treasure(), nil,
        { [1] = "greed", [2] = Reid:GreedTreasureRoom() })
    String = repeatFindInsertUntilStringEnds(String, "secret", Reid:Secret(), nil,
        { [1] = "super", [2] = Reid:SuperSecret() }, { [1] = "ultra", [2] = Reid:UltraSecret() })
    String = repeatFindInsertUntilStringEnds(String, "shop", Reid:Shop())
    String = repeatFindInsertUntilStringEnds(String, "vault", Reid:ChestRoom())
    String = repeatFindInsertUntilStringEnds(String, "library", Reid:Library())
    String = repeatFindInsertUntilStringEnds(String, "boss", Reid:Boss(), nil, { [1] = "mini", [2] = Reid:MiniBoss() })
    String = repeatFindInsertUntilStringEnds(String, "challenge room", Reid:ChallengeRoom())
    String = repeatFindInsertUntilStringEnds(String, "room", "", true, { [1] = "dice", [2] = Reid:DiceRoom() })
    String = repeatFindInsertUntilStringEnds(String, "sacrifice", Reid:SacrificeRoom())
    String = repeatFindInsertUntilStringEnds(String, "arcade", Reid:ArcadeRoom())
    String = repeatFindInsertUntilStringEnds(String, "bedroom", Reid:Bedroom(), nil,
        { [1] = "dirty", [2] = Reid:DirtyBedroom() })
    String = repeatFindInsertUntilStringEnds(String, "mirror", Reid:Mirror())
    String = repeatFindInsertUntilStringEnds(String, "beggar", Reid:Beggar(), nil,
        { [1] = "demon", [2] = Reid:DemonBeggar() }, { [1] = "black", [2] = Reid:DemonBeggar() },
        { [1] = "key", [2] = Reid:KeyBeggar() }, { [1] = "bomb", [2] = Reid:BombBeggar() },
        { [1] = "battery", [2] = Reid:BatteryBeggar() }, { [1] = "rotten", [2] = Reid:RottenBeggar() }
    )
    String = repeatFindInsertUntilStringEnds(String, "machine", "", nil, { [1] = "restock", [2] = Reid:RestockMachine() },
        { [1] = "fortune", [2] = Reid:FortuneMachine() }, { [1] = "slot", [2] = Reid:SlotMachine() },
        { [1] = "donation", [2] = Reid:DonationMachine() }
    )
    String = repeatFindInsertUntilStringEnds(String, "blood dono", Reid:BloodDono())
    String = repeatFindInsertUntilStringEnds(String, "blood donation", Reid:BloodDono())
    String = repeatFindInsertUntilStringEnds(String, "crane game", Reid:CraneGame())
    String = repeatFindInsertUntilStringEnds(String, "confessional", Reid:Confessional())
    String = repeatFindInsertUntilStringEnds(String, "mantle", Reid:Mantle())
    String = repeatFindInsertUntilStringEnds(String, "mode", "", nil, { [1] = "hard", [2] = Reid:HardMode() },
        { [1] = "greed", [2] = Reid:GreedMode() }, { [1] = "greedier", [2] = Reid:GreedierMode() })
    String = repeatFindInsertUntilStringEnds(String, "victory lap", Reid:VictoryLap())
    String = repeatFindInsertUntilStringEnds(String, "heart", Reid:Heart(), nil,
        { [1] = "half", [2] = Reid:Heart(hearts.Half) }, { [1] = "empty", [2] = Reid:Heart(hearts.Empty) },
        { [1] = "ethernal", [2] = Reid:Heart(hearts.Ethernal) }, { [1] = "eternal", [2] = Reid:Heart(hearts.Ethernal) },
        { [1] = "soul", [2] = Reid:Heart(hearts.Soul) }, { [1] = "half soul", [2] = Reid:Heart(hearts.HalfSoul) },
        { [1] = "black", [2] = Reid:Heart(hearts.Black) }, { [1] = "half black", [2] = Reid:Heart(hearts.HalfBlack) },
        { [1] = "demon", [2] = Reid:Heart(hearts.Black) }, { [1] = "bone", [2] = Reid:Heart(hearts.Bone) },
        { [1] = "half bone", [2] = Reid:Heart(hearts.Bone) }, { [1] = "empty bone", [2] = Reid:Heart(hearts.EmptyBone) },
        { [1] = "full", [2] = Reid:Heart() }, { [1] = "rotten", [2] = Reid:Heart(hearts.Rotten) },
        { [1] = "rotten bone", [2] = Reid:Heart(hearts.RottenBone) }, { [1] = "blended", [2] = Reid:Heart(hearts.Blended) },
        { [1] = "golden", [2] = Reid:Heart(hearts.Golden) }, { [1] = "coin", [2] = Reid:Heart(hearts.Coin) },
        { [1] = "half coin", [2] = Reid:Heart(hearts.HalfCoin) },
        { [1] = "empty coin", [2] = Reid:Heart(hearts.EmptyCoin) }, { [1] = "broken", [2] = Reid:Heart(hearts.Broken) },
        { [1] = "unknown", [2] = Reid:Heart(hearts.Unknown) }
    )

    return String
end

::noEID::
return Reid
