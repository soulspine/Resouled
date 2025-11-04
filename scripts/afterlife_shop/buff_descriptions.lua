local PaperSprite = Sprite()
PaperSprite:Load("gfx/misc/buff_description_paper.anm2", true)

local NameFont = Font()
NameFont:Load("font/upheaval.fnt")
local AVEARGE_LETTER_NAME_SIZE = 12

local DescFont = Font()
DescFont:Load("font/upheavalmini.fnt")
local AVEARGE_LETTER_DESC_SIZE = 7

local TILE_SIZE = 16

local BuffPedestal = Resouled.Stats.BuffPedestal

local EID_BUFFS = {
        [Resouled.Buffs.AGILITY] = "Grants +0.3 speed",
        [Resouled.Buffs.BLUE_KING_CROWN] = "Enemies have a 15% chance to turn into champions, rare pickup and chests appear 2.5% more often",
        [Resouled.Buffs.BROKEN_MEMORY] = "All Golden locked chests chest chest chest chest have 50% chance to be replaced with Dirty old chests for the whole run",
        [Resouled.Buffs.CONSTELLATION] = "Treasure room is replaced by planetarium",
        [Resouled.Buffs.CROSS] = "You spawn with an eternal heart # Holy card for lost and tainted lost",
        [Resouled.Buffs.CRUCIFIX] = "The boss item is replaced with a q4 angel deal item, # it costs one heart container. # If you dont have containers, the item is free.",
        [Resouled.Buffs.CURSED_SKULL] = "You're guaranteed to get a curse first floor, but you will gain one of each pickup and a random trinket spawns",
        [Resouled.Buffs.DEATH] = "Kills all enemies in the room the first time you take damage",
        [Resouled.Buffs.DEMON] = "Enemies on death have a 5% chance to explode. Bosses have a 1% chance to mini-bomb explode on hit. lasts the whole run",
        [Resouled.Buffs.DEVILS_HEAD] = "The first floor has a guaranteed devil deal. You get a curse of unknown",
        [Resouled.Buffs.FAMINE] = "Food items can not appear the whole run",
        [Resouled.Buffs.FIEND] = "Has a chance for a small bomb to spawn near a random enemy, lasts the whole run",
        [Resouled.Buffs.FORBIDDEN_CRANIUM] = "You get curse of the lost, unknown, maze, darkness, pain, greed but the first boss item has a q4 devil deal item cycle",
        [Resouled.Buffs.FORGOTTEN_POLAROID] = "Spawns a dire chest at the start",
        [Resouled.Buffs.FORTUNE] = "Grants +2 Luck",
        [Resouled.Buffs.FRIGHTENING_VISAGE] = "Reduces enemy health by 10%",
        [Resouled.Buffs.HEAVENS_CALL] = "First floor has a planetarium. +20% planetarium chance until a planetarium spawns",
        [Resouled.Buffs.IMP] = "First treasure room item is a bomb related item",
        [Resouled.Buffs.KIDS_DRAWING] = "You start with gulped Kid's Drawing",
        [Resouled.Buffs.KING_CROWN] = "Enemies have a 10% chance to turn into champions, rare pickup and chests appear 5% more often",
        [Resouled.Buffs.PESTILENCE] = "All maggot enemies have 50% chance to become charmed",
        [Resouled.Buffs.PIRACY] = "You can steal from the shops if you dont have enough money. # You will get a broken heart for each robbed thing",
        [Resouled.Buffs.RELIC] = "The first floor has a guaranteed angel deal.",
        [Resouled.Buffs.ROYAL_CROWN] = "Enemies have a 5% chance to turn into champions, rare pickup and chests appear 7.5% more often, keys spawn 5% more",
        [Resouled.Buffs.SADNESS] = "Grants +0.7 Tear rate",
        [Resouled.Buffs.SCARY_FACE] = "Reduces enemy health by 5%",
        [Resouled.Buffs.SIGHT] = "Grants +3 Range",
        [Resouled.Buffs.SOUL_CATCHER] = "15% chance to spawn another soul on spawn",
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

local Animations = {
    Left = {
        L1 = "Left",
    },
    Right = {
        R1 = "Right",
    },
    Bottom = {
        Start = "BottomStart",
        [1] = "BottomLoop1",
        [2] = "BottomLoop2",
        [3] = "BottomLoop3",
        [4] = "BottomLoop4",
        End = "BottomEnd"
    },
    Middle = {
        M1 = "Filling"
    },
    Scroll = {
        Start = "ScrollStart",
        Middle = "ScrollMiddle",
        End = "ScrollEnd"
    }
}

Resouled.BuffRarityColors = {
    [Resouled.BuffRarity.COMMON] = KColor(49.9/100, 59.6/100, 63.1/100, 0.75),
    [Resouled.BuffRarity.RARE] = KColor(60.4/100, 44.3/100, 69/100, 0.75),
    [Resouled.BuffRarity.LEGENDARY] = KColor(72.5/100, 66.7/100, 13.7/100, 0.75),
    [Resouled.BuffRarity.SPECIAL] = KColor(1, 1, 1, 1)
}

---@param rarity ResouledBuffRarityDesc
---@param color KColor
function Resouled:AddBuffRarityColor(rarity, color)
    Resouled.BuffRarityColors[rarity.Id] = color
end

local Config = {
    Name = "",
    ---@type string
    Description = "",
    DescriptionAligned = {},
    LastBuffID = 0,
    Family = "",

    Color = KColor(1, 1, 1, 1),


    Length = 0,

    Width = 0,
    Height = 0,

    MinWidth = 6,
    MinHeight = 0,

    StartPos = Vector(20, 30)
}

---@param buffID integer
local function adjustConfigToBuff(buffID)
    local buff = Resouled:GetBuffById(buffID)
    if buff then
        Config.Name = buff.Name
        Config.Description = Resouled.Stats.BuffDescriptions[buffID]
        Config.Family = buff.FamilyName
        Config.Color = Resouled.BuffRarityColors[buff.Rarity]
        Config.LastBuffID = buffID
    end
end

local function alignDescription()
    local newDesc = {}

    local lastCutText = 0
    local lastY = 0

    local desc = Config.Description

    local width = (math.max(Config.Width, Config.MinWidth) * TILE_SIZE) - AVEARGE_LETTER_DESC_SIZE

    for i = 1, desc:len() do
        local char = desc:sub(i, i)
        if char == " " then
            lastY = i
        end

        if char == "#" then
            newDesc[#newDesc + 1] = desc:sub(lastCutText + 1, lastY)
            lastCutText = lastY + 2
            lastY = lastCutText
        end

        if (i - lastCutText) * AVEARGE_LETTER_DESC_SIZE > width then
            newDesc[#newDesc + 1] = desc:sub(lastCutText + 1, lastY)
            lastCutText = lastY
        end
    end

    Config.DescriptionAligned = newDesc
end

if Config.Description then
    alignDescription()
end

---@param x integer
---@param y integer
---@param lastX integer
---@param lastY integer
---@return string
local function getAnimation(x, y, lastX, lastY)
    if y < lastY then
        if x == 0 then
            return Animations.Left.L1
        elseif x > 0 and x < lastX then
            return Animations.Middle.M1
        elseif x == lastX then
            return Animations.Right.R1
        end
    else
        if x == 0 then
            return Animations.Bottom.Start
        elseif x > 0 and x < lastX then
            return Animations.Bottom[(x % 4) + 1]
        elseif x == lastX then
            return Animations.Bottom.End
        end
    end
    return Animations.Middle.M1
end

---@param startPos Vector
local function renderScroll(startPos)
    PaperSprite:Play(Animations.Scroll.Start, true)

    PaperSprite:Render(startPos)

    PaperSprite:Play(Animations.Scroll.Middle, true)

    local length = math.max(Config.Width, Config.MinWidth) * TILE_SIZE

    PaperSprite.Scale.X = length

    PaperSprite:Render(startPos)

    PaperSprite.Scale.X = 1

    PaperSprite:Play(Animations.Scroll.End, true)

    PaperSprite:Render(startPos + Vector(length, 0))

    NameFont:DrawString(Config.Name, startPos.X, startPos.Y - 9, Config.Color)
end

---@param startPos Vector
local function renderDescription(startPos)
    alignDescription()
    for i = 1, #Config.DescriptionAligned do
        DescFont:DrawString(Config.DescriptionAligned[i], startPos.X + 3, 11 + startPos.Y + 7 * i, KColor(1, 1, 1, 0.75))
    end
end

local function findNearestBuff()
    local player = Isaac.GetPlayer()
    local closestPickupVarData = nil
    local closest = nil

    ---@param pickup EntityPickup
    Resouled.Iterators:IterateOverRoomPickups(function(pickup)
        if pickup.Variant == BuffPedestal.Variant and pickup.SubType == BuffPedestal.SubType then
            local varData = pickup:GetVarData()
            if varData then
                local distance = pickup.Position:Distance(player.Position)
                if closest then
                    if closest > distance then
                        closest = distance
                        closestPickupVarData = varData
                    end
                else
                    closest = distance
                end
            end
        end
    end)

    if closestPickupVarData and closestPickupVarData ~= Config.LastBuffID then
        adjustConfigToBuff(closestPickupVarData)
    end
end

local function onRender()
    
    if Isaac.GetFrameCount() % 3 == 0 then
        findNearestBuff()
    end

    local startPos = Config.StartPos

    local lastY = math.max(Config.Height, Config.MinHeight)
    local lastX = math.max(Config.Width, Config.MinWidth) - 1

    Config.Width = (Config.Name:len() * AVEARGE_LETTER_NAME_SIZE)//TILE_SIZE + 1

    if Config.Description then
        Config.Height = Config.Length//TILE_SIZE + math.floor((Config.Description:len() * AVEARGE_LETTER_DESC_SIZE)/(Config.Width * TILE_SIZE)/2 + 0.5)
    else
        Config.Height = Config.Length//TILE_SIZE
    end

    
    local z = Config.Length%TILE_SIZE
    if z == 0 then
        z = TILE_SIZE + 1
    end

    local offset = Vector(0, z - 1)
    
    for y = 0, lastY do
        for x = 0, lastX do
            local pos = startPos + Vector(TILE_SIZE * x, TILE_SIZE * y)
            
            PaperSprite:Play(getAnimation(x, y, lastX, lastY), true)
            
            PaperSprite:Render(pos + offset)
            
        end
    end
    renderScroll(startPos)
    if Config.Description then
        renderDescription(startPos)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_HUD_RENDER, onRender)