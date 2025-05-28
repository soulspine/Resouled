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

---@class ResouledBuffRarityDesc
---@field Id ResouledBuffRarity
---@field Weight integer
---@field Name string

--- @type table<string, ResouledBuffFamilyDesc>
local registeredFamilies = {}

--- @type table<string, ResouledBuffRarityDesc>
local registeredRarities = {}

--- @type table<string, ResouledBuffDesc>
local registeredBuffs = {}


local fileSaveBuffTable = {}

local function postModsLoaded()
    for i = 1, #Resouled:GetBuffs() do
        table.insert(fileSaveBuffTable, i, 0)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_MODS_LOADED, postModsLoaded)



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

--- Registers a new buff rarity and saves its properties.
--- Returns `true` if the rarity was registered successfully, `false` if it was already registered.
---@param rarity ResouledBuffRarity
---@param name string
---@param weight number
function Resouled:RegisterBuffRarity(rarity, name, weight)
    local key = tostring(rarity)
    if not registeredRarities[key] then
        registeredRarities[key] = {
            Id = rarity,
            Name = name,
            Weight = weight,
        }
        return true
    end
    Resouled:LogError("Tried to register a buff rarity that was already registered: " .. rarity)
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
    local rarityKey = tostring(rarity)
    local familyKey = tostring(family)
    if not registeredFamilies[familyKey] then
        Resouled:LogError("Tried to register a buff (" .. buff .. ") with an unregistered family (" .. family .. ")")
        return false
    elseif not registeredRarities[rarityKey] then
        Resouled:LogError("Tried to register a buff (" .. buff .. ") with an unregistered rarity (" .. rarity .. ")")
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

--- Retrieves a table containing all registered buff descriptions.
---@return ResouledBuffDesc[]
function Resouled:GetBuffs()
    local out = {}
    for _, buffDesc in pairs(registeredBuffs) do
        table.insert(out, buffDesc)
    end
    return out
end

--- Retrieves a table containing all registered buff rarities.
---@return ResouledBuffRarityDesc[]
function Resouled:GetBuffRarities()
    local out = {}
    for _, rarityDesc in pairs(registeredRarities) do
        table.insert(out, rarityDesc)
    end
    return out
end

--- Retrieves the description of a buff rarity by its ID.
--- Returns a `ResouledBuffRarityDesc` object or `nil` if the rarity is not registered.
--- @param rarity ResouledBuffRarity
function Resouled:GetBuffRarityById(rarity)
    local rarityDesc = registeredRarities[tostring(rarity)]
    if rarityDesc then
        return rarityDesc
    end
    Resouled:LogError("Tried to get a buff rarity description for an unregistered rarity: " .. rarity)
    return nil
end

--- Retrieves the description of a buff rarity by its name.
--- Returns a `ResouledBuffRarityDesc` object or `nil` if the rarity is not registered.
--- @param rarityName string
--- @return ResouledBuffRarityDesc | nil
function Resouled:GetBuffRarityByName(rarityName)
    for _, rarityDesc in pairs(registeredRarities) do
        if rarityDesc.Name == rarityName then
            return rarityDesc
        end
    end
    Resouled:LogError("Tried to get a buff rarity description for an unregistered rarity name: " .. rarityName)
    return nil
end

---@param rng RNG
---@param blacklist? ResouledBuff[]
---@return ResouledBuff | nil
function Resouled:GetRandomWeightedBuff(rng, blacklist)
    local randomFloat = rng:RandomFloat()
    local ranges = {}
    blacklist = blacklist or {}

    local blacklistSet = {}

    for _, buffId in ipairs(blacklist) do
        blacklistSet[tostring(buffId)] = true
    end

    for _, rarityDesc in pairs(registeredRarities) do
        if rarityDesc.Weight > 0 then
            local upperBound = rarityDesc.Weight
            if #ranges > 0 then
                local previous = ranges[#ranges]
                upperBound = previous.UpperBound + upperBound
            end
            table.insert(ranges, {
                Rarity = rarityDesc.Id,
                UpperBound = upperBound,
            })
        end
    end

    ---@type ResouledBuffRarity
    local chosenRarity = nil

    for _, range in ipairs(ranges) do
        if randomFloat < range.UpperBound then
            chosenRarity = range.Rarity
            break
        end
    end

    if not chosenRarity then
        Resouled:LogError("Failed to choose a rarity for the random buff, no valid ranges found.")
        return nil
    end

    local possibleBuffs = {}

    for _, buffDesc in ipairs(self:GetBuffs()) do
        if buffDesc.Rarity == chosenRarity and not blacklistSet[tostring(buffDesc.Id)] then
            table.insert(possibleBuffs, buffDesc.Id)
        end
    end

    return #possibleBuffs > 0 and possibleBuffs[rng:RandomInt(#possibleBuffs) + 1] or nil
end

---@param buffID ResouledBuff
function Resouled:AddBuffToSave(buffID)
    local FILE_SAVE = SAVE_MANAGER.GetPersistentSave()
    if not FILE_SAVE then
        FILE_SAVE = {}
    end
    if not FILE_SAVE.Resouled_Buffs then
        FILE_SAVE.Resouled_Buffs = fileSaveBuffTable
    elseif #FILE_SAVE.Resouled_Buffs ~= fileSaveBuffTable then
        for i = 1, #fileSaveBuffTable do
            FILE_SAVE.Resouled_Buffs[i] = FILE_SAVE.Resouled_Buffs[i] or 0
        end
    end

    FILE_SAVE.Resouled_Buffs[buffID] = (FILE_SAVE.Resouled_Buffs[buffID] or 0) + 1
end

---@param buffID ResouledBuff
function Resouled:RemoveBuffFromSave(buffID)
    local FILE_SAVE = SAVE_MANAGER.GetPersistentSave()
    if not FILE_SAVE then
        FILE_SAVE = {}
    end
    if not FILE_SAVE.Resouled_Buffs then
        FILE_SAVE.Resouled_Buffs = fileSaveBuffTable
    elseif #FILE_SAVE.Resouled_Buffs ~= fileSaveBuffTable then
        for i = 1, #fileSaveBuffTable do
            FILE_SAVE.Resouled_Buffs[i] = FILE_SAVE.Resouled_Buffs[i] or 0
        end
    end

    if FILE_SAVE.Resouled_Buffs[buffID] > 0 then
        FILE_SAVE.Resouled_Buffs[buffID] = (FILE_SAVE.Resouled_Buffs[buffID]) - 1
    end
end

---@param buffID ResouledBuff
---@return integer
function Resouled:GetBuffAmount(buffID)
    local FILE_SAVE = SAVE_MANAGER.GetPersistentSave()
    if FILE_SAVE and FILE_SAVE.Resouled_Buffs and FILE_SAVE.Resouled_Buffs[buffID] then
        return FILE_SAVE.Resouled_Buffs[buffID]
    end
    return 0
end

---@param buffID ResouledBuff
---@return boolean
function Resouled:BuffPresent(buffID)
    local FILE_SAVE = SAVE_MANAGER.GetPersistentSave()
    if FILE_SAVE and FILE_SAVE.Resouled_Buffs and FILE_SAVE.Resouled_Buffs[buffID] and FILE_SAVE.Resouled_Buffs[buffID] > 0 then
        return true
    end
    return false
end