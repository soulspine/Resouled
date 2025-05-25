---@class ResouledBuffDesc
---@field Id ResouledBuff
---@field Name string
---@field Price integer
---@field Rarity ResouledBuffRarity
---@field Family ResouledBuffFamily
---@field FamilyName string

---@class ResouledBuffFamilyDesc
---@field Id ResouledBuffFamily
---@field Name string
---@field Spritesheet string
---@field ChildBuffs ResouledBuff[]

--- @type table<string, ResouledBuffFamilyDesc>
local registeredFamilies = {}

--- @type table<string, ResouledBuffDesc>
local registeredBuffs = {}

--- Registers a new buff family and saves its spritesheet path to properly load it later.
--- Returns `true` if the family was registered successfully, `false` if it was already registered.
---@param family ResouledBuffFamily
---@param name string
---@param spritesheet string
---@return boolean
function Resouled:RegisterBuffFamily(family, name, spritesheet)
    local key = tostring(family)
    if not registeredFamilies[key] then
        registeredFamilies[key] = {
            Id = family,
            Name = name,
            Spritesheet = spritesheet,
            ChildBuffs = {},
        }
        return true
    end
    Resouled:LogError("Tried to register a buff family that was already registered: " .. family)
    return false
end

--- Registers a new buff and saves its properties.
--- Returns `true` if the buff was registered successfully, `false` if it was already registered or if the family is not registered.
---@param buff ResouledBuff
---@param name string
---@param price integer
---@param rarity ResouledBuffRarity
---@param family ResouledBuffFamily
---@return boolean
function Resouled:RegisterBuff(buff, name, price, rarity, family)
    local buffKey = tostring(buff)
    local familyKey = tostring(family)
    if not registeredFamilies[familyKey] then
        Resouled:LogError("Tried to register a buff (" .. buff .. ") with an unregistered family (" .. family .. ")")
        return false
    end

    if not registeredBuffs[buffKey] then
        registeredBuffs[buffKey] = {
            Id = buff,
            Name = name,
            Price = price,
            Rarity = rarity,
            Family = family,
            FamilyName = registeredFamilies[familyKey].Name,
        }

        table.insert(registeredFamilies[familyKey].ChildBuffs, buff)
        return true
    end

    Resouled:LogError("Tried to register a buff that was already registered: " .. buff)
    return false
end

--- Retrieves the description of a buff by its ID.
--- Return a `ResouledBuffDesc` object or `nil` if the buff is not registered.
---@param buffID ResouledBuff
---@return ResouledBuffDesc | nil
function Resouled:GetBuffById(buffID)
    local buff = registeredBuffs[tostring(buffID)]
    if buff then
        return buff
    end
    Resouled:LogError("Tried to get a buff description for an unregistered buff: " .. buffID)
    return nil
end

--- Retrieves the description of a buff by its name.
--- Returns a `ResouledBuffDesc` object or `nil` if the buff is not registered.
---@param buffName string
---@return ResouledBuffDesc | nil
function Resouled:GetBuffByName(buffName)
    for _, buffDesc in pairs(registeredBuffs) do
        if buffDesc.Name == buffName then
            return buffDesc
        end
    end
    Resouled:LogError("Tried to get a buff description for an unregistered buff name: " .. buffName)
    return nil
end

--- Retrieves all buff descriptions under a specific buff family.
--- Returns a table of `ResouledBuffDesc` objects or `nil` if the family is not registered.
---@param family ResouledBuffFamily
---@return ResouledBuffDesc[] | nil
function Resouled:GetBuffsByFamilyId(family)
    local family = registeredFamilies[tostring(family)]
    if family then
        local out = {}
        for _, buffId in ipairs(family.ChildBuffs) do
            local buffDesc = self:GetBuffById(buffId)
            if buffDesc then
                table.insert(out, buffDesc)
            end
        end
        return out
    end
    Resouled:LogError("Tried to get buffs for an unregistered family: " .. family)
    return nil
end

--- Retrieves all buff descriptions under a specific buff family name.
--- Returns a table of `ResouledBuffDesc` objects or `nil` if the family is not registered.
--- @param familyName string
--- @return ResouledBuffDesc[] | nil
function Resouled:GetBuffsByFamilyName(familyName)
    for familyKey, familyDesc in pairs(registeredFamilies) do
        if familyDesc.Name == familyName then
            ---@diagnostic disable-next-line: param-type-mismatch
            return self:GetBuffsByFamilyId(familyKey)
        end
    end
    Resouled:LogError("Tried to get buffs for an unregistered family name: " .. familyName)
    return nil
end

--- Retrieves the description of a buff family by its ID.
--- Returns a `ResouledBuffFamilyDesc` object or `nil` if the family is not registered.
---@param family ResouledBuffFamily
---@return ResouledBuffFamilyDesc | nil
function Resouled:GetBuffFamilyById(family)
    local familyDesc = registeredFamilies[tostring(family)]
    if familyDesc then
        return familyDesc
    end
    Resouled:LogError("Tried to get a buff family description for an unregistered family: " .. family)
    return nil
end

--- Retrieves the description of a buff family by its name.
--- Returns a `ResouledBuffFamilyDesc` object or `nil` if the family is not registered.
--- @param familyName string
--- @return ResouledBuffFamilyDesc | nil
function Resouled:GetBuffFamilyByName(familyName)
    for _, familyDesc in pairs(registeredFamilies) do
        if familyDesc.Name == familyName then
            return familyDesc
        end
    end
    Resouled:LogError("Tried to get a buff family description for an unregistered family name: " .. familyName)
    return nil
end