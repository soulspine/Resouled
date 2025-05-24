---@class ResouledBuffs
---@field ID integer
---@field NAME string
---@field PRICE integer
---@field RARITY string
---@field FAMILY string

Resouled.Buffs = { --Effect will be applied using ID stat, Spritesheet will be replaced using the NAME stat, correct layer will be set visible using the RARITY stat, price will be set using the PRICE stat, correct spritesheet will be chosen using the FAMILY stat
    ---@type ResouledBuffs
    [1] = {
        ID = 1,
        NAME = "Cursed Skull",
        PRICE = 3,
        RARITY = "Common",
        FAMILY = "Cursed Skull"
    },
    ---@type ResouledBuffs
    [2] = {
        ID = 2,
        NAME = "Devil's Head",
        PRICE = 5,
        RARITY = "Rare",
        FAMILY = "Cursed Skull"
    },
    ---@type ResouledBuffs
    [3] = {
        ID = 3,
        NAME = "Forbidden Cranium",
        PRICE = 5,
        RARITY = "Legendary",
        FAMILY = "Cursed Skull"
    },
}

---@param buffID integer
---@return ResouledBuffs
function Resouled:GetBuffDesc(buffID)
    return Resouled.Buffs[buffID]
end

---@param buffName string
function Resouled:GetBuffIDByName(buffName)
    for i = 1, #Resouled.Buffs do
        if Resouled.Buffs[i].NAME == buffName then
            return i
        end
    end
end

---@param familyName string
---@return ResouledBuffs[]
function Resouled:GetBuffsFromFamily(familyName)
    local buffs = {}
    for i = 1, #Resouled.Buffs do
        if Resouled.Buffs[i].FAMILY == familyName then
            table.insert(buffs, Resouled.Buffs[i])
        end
    end
    return buffs
end

---@param buffID integer
---@return string
function Resouled:GetBuffSpritesheetName(buffID)
    local buff = Resouled:GetBuffDesc(buffID)
    local name = buff.FAMILY
    local spritesheet = ""
    for i = 1, #name do
        local char = string.byte(name, i)
        if char == string.byte(' ') then
            char = string.byte('_')
        end

        if char ~= string.byte('\'') then
            spritesheet = spritesheet..string.char(char)
        end
    end

    return spritesheet:lower()..".png"
end

local function postGameStarted()
    print(Resouled:GetBuffSpritesheetName(1))
end
Resouled:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, postGameStarted)