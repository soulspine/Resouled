local EID_BUFFS = {
        [Resouled.Buffs.AGILITY] = "Grants +0.3 speed",
        [Resouled.Buffs.BLUE_KING_CROWN] = 
            "Enemies have a 15% chance to turn into champions, rare pickup and chests appear 2.5% more often",
        [Resouled.Buffs.BROKEN_MEMORY] = "All " ..
            "Golden" ..
            " locked chests have 50% chance to be replaced with " ..
            "Dirty" .. " old chests for the whole run",
        [Resouled.Buffs.CONSTELLATION] = "First treasure room is replaced by planetarium",
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
            "First floor has a planetarium. +20% planetarium chance until a planetarium is entered",
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

for _, buffDesc in pairs(Resouled:GetBuffs()) do
    Resouled:AddBuffDescription(buffDesc.Id, EID_BUFFS[buffDesc.Id])
end

local buffPedestal = Resouled.Stats.BuffPedestal

local nameFont = Font()
local descFont = Font()
nameFont:Load("font/teammeatfont16.fnt")
descFont:Load("font/teammeatfont10.fnt")

local boxSprite = Sprite()
boxSprite:Load("gfx/ui/buff_description_box.anm2", true)
local BOX_SPRITE_SCALE = Vector(32, 32)
boxSprite.Color.A = 0.65

local playbackSpeed = 0.85

Resouled.BuffRarityDescriptionColors = {
    [Resouled.BuffRarity.COMMON] = KColor(117/255, 152/255, 161/255, 1),
    [Resouled.BuffRarity.RARE] = KColor(154/255, 113/255, 176/255, 1),
    [Resouled.BuffRarity.LEGENDARY] = KColor(185/255, 170/255, 35/255, 1),
    [Resouled.BuffRarity.SPECIAL] = KColor(1, 1, 1, 1)
}


---@param width number
---@param height number
local function getBoxSize(width, height)
    return Vector(math.ceil(width/BOX_SPRITE_SCALE.X) + 2, math.ceil(height/BOX_SPRITE_SCALE.Y) + 2)
end

local MAX_WIDTH = 5

local ENDL = "//endl//"

---@param s string
---@param font Font
---@param space? boolean
---@return table
local function alignText(s, font, space)
    space = space or false
    local alignedByEndl = {}
    local aligned = {}

    while true do
        local endl = s:find(ENDL)
        if endl then
            alignedByEndl[#alignedByEndl+1] = s:sub(1, endl-1)
            s = s:sub(endl+ENDL:len()+1, s:len())
        else break end
    end

    if s ~= "" then
        alignedByEndl[#alignedByEndl+1] = s
    end

    local len = 0
    local lastSpace = 1

    
    for _, string in ipairs(alignedByEndl) do
        s = string
        if space then
            s = "    "..s
        end
        ::Start::

        for i = 1, s:len() do
            local c = s:sub(i, i)
            if c == ' ' then lastSpace = i end
            len = len + font:GetStringWidth(c)
        
            if getBoxSize(len, 0).X > MAX_WIDTH + 2 then
                aligned[#aligned+1] = s:sub(1, lastSpace)
                s = s:sub(lastSpace + 1, s:len())
                len = 0
                goto Start
            end
        end
        if s ~= '' then
            aligned[#aligned+1] = s
        end
    end


    return aligned
end

local descsAligned = {}

for id, desc in pairs(Resouled.Stats.BuffDescriptions) do
    local buff = Resouled:GetBuffById(id)
    if buff then
        local config = {
            Name = alignText(buff.Name, nameFont),
            Desc = alignText(desc, descFont, true),
            Color = Resouled.BuffRarityDescriptionColors[buff.Rarity]
        }
        table.insert(descsAligned, config)
    end
end






---@param pos Vector
---@param width integer
---@param height integer
local function renderBox(pos, width, height)
    boxSprite.Scale = Vector(1, 1)

    local frame = math.floor((Isaac.GetFrameCount()%(16/playbackSpeed)) * playbackSpeed)
    boxSprite:SetFrame("topLeft", frame)
    boxSprite:Render(pos)

    local offset = Vector(0, 0)

    boxSprite:SetFrame("top", frame)
    for _ = 1, width - 2 do
        boxSprite:Render(pos + offset)
        offset.X = offset.X + BOX_SPRITE_SCALE.X
    end

    boxSprite:SetFrame("topRight", frame)
    boxSprite:Render(pos + offset)

    local rightPos = offset.X
    
    offset = Vector(0, 0)

    boxSprite:SetFrame("left", frame)
    for _ = 1, height - 2 do
        boxSprite:Render(pos + offset)
        offset.Y = offset.Y + BOX_SPRITE_SCALE.Y
    end

    boxSprite:SetFrame("bottomLeft", frame)
    boxSprite:Render(pos + offset)

    boxSprite:SetFrame("bottom", frame)
    for _ = 1, width - 2 do
        boxSprite:Render(pos + offset)
        offset.X = offset.X + BOX_SPRITE_SCALE.X
    end

    boxSprite:SetFrame("bottomRight", frame)
    boxSprite:Render(pos + offset)

    offset = Vector(rightPos, 0)

    boxSprite:SetFrame("right", frame)
    for _ = 1, height - 2 do
        boxSprite:Render(pos + offset)
        offset.Y = offset.Y + BOX_SPRITE_SCALE.Y
    end

    boxSprite.Scale = Vector(width - 2, height - 2)
    boxSprite:SetFrame("middle", frame)
    boxSprite:Render(pos)
end

---@param buffId ResouledBuff | integer
function Resouled:RenderBuffDescription(buffId)
    local config = descsAligned[buffId]

    if not config then return end

    local color = config.Color

    local size = getBoxSize(MAX_WIDTH * 32, #config.Desc * descFont:GetBaselineHeight() + #config.Name * nameFont:GetBaselineHeight())
    renderBox(Vector(25, 25), size.X, size.Y)

    local x1 = 25 - 8
    local x2 = 32 * (size.X - 1.5)

    local x = 25
    local y = 25
    
    local sep = nameFont:GetBaselineHeight()
    for _, s in ipairs(config.Name) do
        nameFont:DrawString(s, x, y, color)
        y = y + sep
    end
    
    Isaac.DrawLine(
        Vector(x1, y),
        Vector(x1 + x2/5, y),
        KColor(color.Red, color.Green, color.Blue, 0),
        KColor(color.Red, color.Green, color.Blue, boxSprite.Color.A),
        1
    )
    Isaac.DrawLine(
        Vector(x1 + x2/5, y),
        Vector(x1 + x2/5 * 4, y),
        KColor(color.Red, color.Green, color.Blue, boxSprite.Color.A),
        KColor(color.Red, color.Green, color.Blue, boxSprite.Color.A),
        1
    )
    Isaac.DrawLine(
        Vector(x1 + x2/5 * 4, y),
        Vector(x1 + x2, y),
        KColor(color.Red, color.Green, color.Blue, boxSprite.Color.A),
        KColor(color.Red, color.Green, color.Blue, 0),
        1
    )

    for _, s in ipairs(config.Desc) do
        descFont:DrawString(s, x, y, color)
        y = y + descFont:GetBaselineHeight()
    end
end

local glowColors = {
    [Resouled.BuffRarity.COMMON] = Color(117/255 * 2, 152/255 * 2, 161/255 * 2, 1),
    [Resouled.BuffRarity.RARE] = Color(154/255 * 2, 113/255 * 2, 176/255 * 2, 1),
    [Resouled.BuffRarity.LEGENDARY] = Color(185/255 * 2, 170/255 * 2, 35/255 * 2, 1),
    [Resouled.BuffRarity.SPECIAL] = Color(1, 1, 1, 1)
}
local glowColorsPedestal = {
    [Resouled.BuffRarity.COMMON] = Color(1 + 117/255/2, 1 + 152/255/2, 1 + 161/255/2),
    [Resouled.BuffRarity.RARE] = Color(1 + 154/255/2, 1 + 113/255/2, 1 + 176/255/2),
    [Resouled.BuffRarity.LEGENDARY] = Color(1 + 185/255/2, 1 + 170/255/2, 1 + 35/255/2),
    [Resouled.BuffRarity.SPECIAL] = Color(1 + 1/4, 1 + 1/4, 1 + 1/4)
}

Resouled:AddCallback(ModCallbacks.MC_POST_HUD_RENDER, function()
    local closest = nil
    ---@type integer | ResouledBuff
    local buffId = 0
    local entity = nil

    local player = Isaac.GetPlayer()

    ---@param pickup EntityPickup
    Resouled.Iterators:IterateOverRoomPickups(function(pickup)
        local varData = pickup:GetVarData()
        if pickup.Variant == buffPedestal.Variant and pickup.SubType == buffPedestal.SubType and varData > 0 then
            local distance = pickup.Position:Distance(player.Position)
            if not closest or closest > distance then
                closest = distance
                buffId = pickup:GetVarData()
                entity = pickup
            end
        end
    end)

    if buffId > 0 then
        Resouled:RenderBuffDescription(buffId)
    end

    if entity then
        local buff = Resouled:GetBuffById(buffId)
        if buff then
            if not Game():IsPauseMenuOpen() then
                EntityEffect.CreateLight(entity.Position + Vector(0, -43), 0.4, 5, 6, glowColors[buff.Rarity])
                entity:SetColor(glowColorsPedestal[buff.Rarity], 2, 1, true, true)
            end
        end
    end
end)