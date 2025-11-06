local EID_BUFFS = {
        [Resouled.Buffs.AGILITY] = "Grants +0.3 speed",
        [Resouled.Buffs.BLUE_KING_CROWN] = 
            "Enemies have a 15% chance to turn into champions, rare pickup and chests appear 2.5% more often",
        [Resouled.Buffs.BROKEN_MEMORY] = "All " ..
            "Golden" ..
            " locked chests chest chest chest chest have 50% chance to be replaced with " ..
            "Dirty" .. " old chests for the whole run",
        [Resouled.Buffs.CONSTELLATION] = "Treasure room is replaced by planetarium",
        [Resouled.Buffs.CROSS] = "You spawn with an eternal heart //endl// " ..
            "Holy card for lost and tainted lost",
        [Resouled.Buffs.CRUCIFIX] = 
            "The boss item is replaced with a q4 angel deal item,  //endl// it costs one heart container.  //endl// If you dont have containers, the item is free.",
        [Resouled.Buffs.CURSED_SKULL] = 
            "You're guaranteed to get a curse first floor, but you will gain one of each pickup and a random trinket spawns",
        [Resouled.Buffs.DEATH] = "Kills all enemies in the room the first time you take damage",
        [Resouled.Buffs.DEMON] = 
            "Enemies on death have a 5% chance to explode. Bosses have a 1% chance to mini-bomb explode on hit. lasts the whole run",
        [Resouled.Buffs.DEVILS_HEAD] = 
            "The first floor has a guaranteed devil deal. You get a curse of unknown",
        [Resouled.Buffs.FAMINE] = "Food items can not appear the whole run",
        [Resouled.Buffs.FIEND] = 
            "Has a chance for a small bomb to spawn near a random enemy, lasts the whole run",
        [Resouled.Buffs.FORBIDDEN_CRANIUM] = 
            "You get curse of the lost, unknown, maze, darkness, pain, greed but the first boss item has a q4 devil deal item cycle",
        [Resouled.Buffs.FORGOTTEN_POLAROID] = "Spawns a dire chest at the start",
        [Resouled.Buffs.FORTUNE] = "Grants +2 Luck",
        [Resouled.Buffs.FRIGHTENING_VISAGE] = "Reduces enemy health by 10%",
        [Resouled.Buffs.HEAVENS_CALL] = 
            "First floor has a planetarium. +20% planetarium chance until a planetarium spawns",
        [Resouled.Buffs.IMP] = "First treasure room item is a bomb related item",
        [Resouled.Buffs.KIDS_DRAWING] = "You start with gulped Kid's Drawing",
        [Resouled.Buffs.KING_CROWN] = 
            "Enemies have a 10% chance to turn into champions, rare pickup and chests appear 5% more often",
        [Resouled.Buffs.PESTILENCE] = "All maggot enemies have 50% chance to become charmed",
        [Resouled.Buffs.PIRACY] = 
            "You can steal from the shops if you dont have enough money.  //endl// You will get a broken heart for each robbed thing",
        [Resouled.Buffs.RELIC] = "The first floor has a guaranteed angel deal.",
        [Resouled.Buffs.ROYAL_CROWN] = 
            "Enemies have a 5% chance to turn into champions, rare pickup and chests appear 7.5% more often, keys spawn 5% more",
        [Resouled.Buffs.SADNESS] = "Grants +0.7 Tear rate",
        [Resouled.Buffs.SCARY_FACE] = "Reduces enemy health by 5%",
        [Resouled.Buffs.SIGHT] = "Grants +3 Range",
        [Resouled.Buffs.SOUL_CATCHER] = 
            "15% chance to spawn another soul on spawn (obtained by ending the run with 30+ souls)",
        [Resouled.Buffs.STEAM_GIVEAWAY] = "First floor shop is free",
        [Resouled.Buffs.STEAM_SALE] = "First floor shop has a steam sale effect",
        [Resouled.Buffs.STRENGTH] = "Grants +1 Damage",
        [Resouled.Buffs.TERRIFYING_PHYSIOGNOMY] = "Reduces enemy health by 15%",
        [Resouled.Buffs.WAR] = "First bomb used in a run has a mama mega explosion",
        [Resouled.Buffs.ZODIAC_SIGN] = "First treasure room item is a zodiac sign",
}

for buff, description in pairs(EID_BUFFS) do
    Resouled:AddBuffDescription(buff, description)
end




Resouled.BuffRarityDescriptionColors = {
    [Resouled.BuffRarity.COMMON] = KColor(117/255, 152/255, 161/255, 1),
    [Resouled.BuffRarity.RARE] = KColor(154/255, 113/255, 176/255, 1),
    [Resouled.BuffRarity.LEGENDARY] = KColor(185/255, 170/255, 35/255, 1),
    [Resouled.BuffRarity.SPECIAL] = KColor(1, 1, 1, 1)
}

local buffDescriptionConfigs = {}

local buffPedestal = Resouled.Stats.BuffPedestal

local Background = Sprite()
Background:Load("gfx/ui/buff_desc_background.anm2", true)
Background:Play("Idle", true)
Background.Color.A = 0.75

local NameFont = Font()
NameFont:Load("font/upheaval.fnt")

local DescFont = Font()
DescFont:Load("font/luamini.fnt")

local ENDL = "//endl//"

local startPos = Vector(12, 12)
local MAX_WIDTH = 125
local NEW_LINE = ">> "

---@param Name string
---@param maxWidth? number
---@return table
local function alignName(Name, maxWidth)
    local alignedDesc = {}
    
    local lastSpace = 1

    ::Start::

    local length = 0

    for i = 1, Name:len() do
        local char = Name:sub(i, i)

        if char == " " then
            lastSpace = i
        end
        length = length + NameFont:GetStringWidth(char)

        if length > (maxWidth or MAX_WIDTH) then
            alignedDesc[#alignedDesc+1] = Name:sub(1, lastSpace)
            Name = Name:sub(lastSpace + 1, Name:len())
            goto Start
        end
    end

    if Name ~= "" then
        alignedDesc[#alignedDesc+1] = Name
    end

    return alignedDesc
end

---@param Family string
---@param maxWidth? number
---@return table
local function alignFamily(Family, maxWidth)
    local alignedDesc = {}
    
    local lastSpace = 1

    ::Start::

    local length = 0

    for i = 1, Family:len() do
        local char = Family:sub(i, i)

        if char == " " then
            lastSpace = i
        end
        length = length + DescFont:GetStringWidth(char)

        if length > (maxWidth or MAX_WIDTH) then
            alignedDesc[#alignedDesc+1] = Family:sub(1, lastSpace)
            Family = Family:sub(lastSpace + 1, Family:len())
            goto Start
        end
    end

    if Family ~= "" then
        alignedDesc[#alignedDesc+1] = Family
    end

    return alignedDesc
end

---@param description string
---@param maxWidth? number
---@return table
local function alignDesc(description, maxWidth)
    local alignedDesc = {}
    
    description = NEW_LINE..description
    
    local lastSpace = 1

    ::Start::

    local length = 0

    for i = 1, description:len() do
        local char = description:sub(i, i)

        if char == " " then
            lastSpace = i
        end
        length = length + DescFont:GetStringWidth(char)
        
        local endline = description:find(ENDL)
        if endline then
            if i == endline then
                alignedDesc[#alignedDesc+1] = description:sub(1, i - 1)
                description = NEW_LINE..description:sub(i + 1 + ENDL:len(), description:len())
                goto Start
            end
        end

        if length > (maxWidth or MAX_WIDTH) then
            alignedDesc[#alignedDesc+1] = description:sub(1, lastSpace)
            description = description:sub(lastSpace + 1, description:len())
            goto Start
        end
    end

    if description ~= "" then
        alignedDesc[#alignedDesc+1] = description
    end

    return alignedDesc
end

local outline = 10
local LINE_OFFSET = 12

---@param config table
---@return number
local function getBoxHeightFromConfig(config)
    local length = 0
    local offset = 0
        
    local i = 0
        
    local lineHeightName = NameFont:GetLineHeight() - 2
        
    for _, _ in pairs(config.Name) do
        i = i + 1
    end
    offset = offset + lineHeightName * (i - 1) + lineHeightName/2
        
    i = 0

    local lineHeightDesc = DescFont:GetLineHeight()
    for _, _ in pairs(config.Family) do
        i = i + 1
    end
        
    offset = offset + lineHeightDesc * i
        
    i = 0

    offset = offset + LINE_OFFSET

    for _, _ in pairs(config.Description) do
        i = i + 1
        length = math.max(length, lineHeightDesc * (i - 1) + offset)
    end

    return length
end


---@param font Font
---@param string string
---@param posX number
---@param posY number
---@param color KColor
---@param color2 KColor
---@param maxWidth? integer
---@param center? boolean
local function drawString(font, string, posX, posY, color, color2, maxWidth, center)
    font:DrawString(string, posX + 1, posY + 1, color2, maxWidth, center)
    font:DrawString(string, posX, posY, color, maxWidth, center)
end

local function renderDescription(buffId)
    local config = buffDescriptionConfigs[buffId]
    if config then
        local maxWidth = config.BoxWidth

        ---@type KColor
        local color = config.Color
        local colorShadow = KColor(color.Red/2, color.Green/2, color.Blue/2, color.Alpha/2)

        if not config.BoxLength then
            config.BoxLength = getBoxHeightFromConfig(config)
        end

        Background.Scale = Vector(maxWidth + outline, config.BoxLength + outline)

        Background:Render(Vector(startPos.X - outline/2, startPos.Y - outline/2))

        local offset = 0
        
        local i = 0
        
        local lineHeightName = NameFont:GetLineHeight() - 2
        
        for _, string in pairs(config.Name) do
            drawString(NameFont, string, startPos.X, startPos.Y + lineHeightName * (i - 1) + lineHeightName/2, color, colorShadow, maxWidth, true)
            i = i + 1
            
        end
        offset = offset + lineHeightName * (i - 1) + lineHeightName/2
        
        local dotString = ""
        local dotLength = DescFont:GetStringWidth("-")
        local dotStringLength = 0
        while dotStringLength <= maxWidth do
            dotStringLength = dotStringLength + dotLength
            if dotStringLength <= maxWidth then
                dotString = dotString.."-"
            end
        end
        
        drawString(DescFont, dotString, startPos.X, startPos.Y + offset - LINE_OFFSET/2, color, colorShadow, maxWidth, true)
        
        i = 0

        local lineHeightDesc = DescFont:GetLineHeight()
        for _, string in pairs(config.Family) do
            drawString(DescFont, string, startPos.X, startPos.Y + LINE_OFFSET * i + offset, color, colorShadow, maxWidth, true)
            i = i + 1
        end
        
        offset = offset + lineHeightDesc * i
        
        i = 0
        
        drawString(DescFont, dotString, startPos.X, startPos.Y + LINE_OFFSET * i + offset - LINE_OFFSET/2, color, colorShadow, maxWidth, true)

        offset = offset + LINE_OFFSET

        for _, string in pairs(config.Description) do
            drawString(DescFont, string, startPos.X, startPos.Y + lineHeightDesc * (i - 1) + offset, color, colorShadow)
    
            i = i + 1
            
        end

        Isaac.DrawQuad(
            Vector(startPos.X - outline/2, startPos.Y - outline/2),
            Vector(startPos.X + maxWidth + outline/2, startPos.Y - outline/2),
            Vector(startPos.X - outline/2, startPos.Y + config.BoxLength + outline/2),
            Vector(startPos.X + maxWidth + outline/2, startPos.Y + config.BoxLength + outline/2),
            config.Color,
            1
        )
    end
end

local function onRender()
    if Resouled.AfterlifeShop:IsAfterlifeShop() then
        local player = Isaac.GetPlayer()
        local closest = nil
        local buffId = nil
        
        ---@param pickup EntityPickup
        Resouled.Iterators:IterateOverRoomPickups(function(pickup)
            local varData = pickup:GetVarData()
            if pickup.Variant == buffPedestal.Variant and pickup.SubType == buffPedestal.SubType and varData > 0 then
                local distance = pickup.Position:Distance(player.Position)
                if not closest then
                    closest = distance
                    buffId = varData
                elseif closest > distance then
                    closest = distance
                    buffId = varData
                end
            end
        end)
        
        if buffId then
            renderDescription(buffId)
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_RENDER, onRender)

Resouled:AddCallback(ModCallbacks.MC_POST_MODS_LOADED, function() --comment the addcallback to be able to luamod
    for _, buffDesc in pairs(Resouled:GetBuffs()) do

        local config = {
            Name = alignName(buffDesc.Name),
            Family = alignFamily("''"..buffDesc.FamilyName.."''"),
            Description = alignDesc(Resouled.Stats.BuffDescriptions[buffDesc.Id] or "No Description"),
            Color = Resouled.BuffRarityDescriptionColors[buffDesc.Rarity],
        }

        local function redoConfig()
            config.Name = alignName(buffDesc.Name, config.BoxWidth)
            config.Family = alignFamily("''"..buffDesc.FamilyName.."''", config.BoxWidth)
            config.Description = alignDesc(Resouled.Stats.BuffDescriptions[buffDesc.Id] or "No Description", config.BoxWidth)
        end

        local length = 0
        ---@param string string
        for _, string in pairs(config.Name) do
            length = math.max(length, NameFont:GetStringWidth(string))
        end

        config.BoxWidth = math.max(MAX_WIDTH, length)

        local nameLength = NameFont:GetStringWidth(buffDesc.Name)
        if not buffDesc.Name:find(" ") and nameLength > MAX_WIDTH then
            config.BoxWidth = math.max(MAX_WIDTH, nameLength)

            redoConfig()
        end

        if config.Name[1]:len() == 1 then
            config.BoxWidth = config.BoxWidth + NameFont:GetCharacterWidth(config.Name[1])

            redoConfig()
        end

        buffDescriptionConfigs[buffDesc.Id] = config
    end
end)
