---@class ResouledBuffDesc
---@field Id ResouledBuff
---@field Name string
---@field Price integer
---@field Rarity ResouledBuffRarity
---@field Family ResouledBuffFamily
---@field FamilyName string
---@field Stackable boolean
---@field TiedSpecialSoul ResouledSoul|nil

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

local BUFF_PEDESTAL_TYPE = Isaac.GetEntityTypeByName("Buff Pedestal")
local BUFF_PEDESTAL_VARIANT = Isaac.GetEntityVariantByName("Buff Pedestal")
local BUFF_PEDESTAL_SUBTYPE = Isaac.GetEntitySubTypeByName("Buff Pedestal")


local function makeSureSavesExist()
    local FILE_SAVE = SAVE_MANAGER.GetPersistentSave()

    if not FILE_SAVE then
        FILE_SAVE = {}
    end

    if not FILE_SAVE.Resouled_PendingBuffs then
        FILE_SAVE.Resouled_PendingBuffs = {}
    end
    if not FILE_SAVE.Resouled_ActiveBuffs then
        FILE_SAVE.Resouled_ActiveBuffs = {}
    end
end

---@param buffID ResouledBuff
---@param position? Vector
---@return EntityPickup | nil
function Resouled:SpawnSetBuffPedestal(buffID, position)
    local buff = Game():Spawn(BUFF_PEDESTAL_TYPE, BUFF_PEDESTAL_VARIANT, position or Game():GetRoom():GetCenterPos(), Vector.Zero, nil, BUFF_PEDESTAL_SUBTYPE, Game():GetRoom():GetSpawnSeed() + Isaac.GetFrameCount()):ToPickup()
    if buff then
        buff:SetVarData(buffID)
        return buff
    else
        Resouled:LogError("There was a problem spawning a set buff pedestal")
        return nil
    end
end

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
---@param stackable boolean
---@param tiedSpecialSoul? ResouledSoul
---@return boolean
function Resouled:RegisterBuff(buff, name, price, rarity, family, stackable, tiedSpecialSoul)
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
            Stackable = stackable,
            TiedSpecialSoul = tiedSpecialSoul
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
    if buffID ~= 0 then
        Resouled:LogError("Tried to get a buff description for an unregistered buff: " .. buffID)
    end
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

---@param buff ResouledBuff
---@return ResouledSoul | nil
function Resouled:TryGetSpecialSoulTiedToBuff(buff)
    return Resouled:GetBuffById(buff).TiedSpecialSoul
end

---@param soul ResouledSoul
---@return ResouledBuff | nil
function Resouled:TryGetBuffTiedToSpecialSoul(soul)
    for _, buffID in pairs(Resouled.Buffs) do
        local buff = Resouled:GetBuffById(buffID)
        if buff and buff.TiedSpecialSoul and buff.TiedSpecialSoul == soul then
            return buffID
        end
    end
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
function Resouled:AddPendingBuff(buffID)
    local FILE_SAVE = SAVE_MANAGER.GetPersistentSave()

    if not FILE_SAVE then
        FILE_SAVE = {}
    end

    local buff = Resouled:GetBuffById(buffID)
    
    if buff then
        local key = tostring(buff.Id)
        if buff.Stackable then
            FILE_SAVE.Resouled_PendingBuffs[key] = (FILE_SAVE.Resouled_PendingBuffs[key] or 0) + 1
        else
            FILE_SAVE.Resouled_PendingBuffs[key] = true
        end
    else
        Resouled:LogError("Provided unregistered buff while adding buffs. nil ID: "..tostring(buffID))
    end
end

---@param buffID ResouledBuff
function Resouled:RemovePendingBuff(buffID)
    local FILE_SAVE = SAVE_MANAGER.GetPersistentSave()
    if not FILE_SAVE then
        FILE_SAVE = {}
    end
    if not FILE_SAVE.Resouled_PendingBuffs then
        FILE_SAVE.Resouled_PendingBuffs = {}
    end

    local buff = Resouled:GetBuffById(buffID)
    
    if buff then
        local key = tostring(buff.Id)
        if FILE_SAVE.Resouled_PendingBuffs[key] then

            if buff.Stackable then
                FILE_SAVE.Resouled_PendingBuffs[key] = (FILE_SAVE.Resouled_PendingBuffs[key]) - 1

                if FILE_SAVE.Resouled_PendingBuffs[key] == 0 then

                    FILE_SAVE.Resouled_PendingBuffs[key] = nil
                end
            else
                FILE_SAVE.Resouled_PendingBuffs[key] = nil
            end
        end
    else
        Resouled:LogError("Provided unregistered buff while removing pending buffs. nil ID: "..tostring(buffID))
    end
end

---@param buffID ResouledBuff
function Resouled:RemoveActiveBuff(buffID)
    local FILE_SAVE = SAVE_MANAGER.GetPersistentSave()
    if not FILE_SAVE then
        FILE_SAVE = {}
    end

    if not FILE_SAVE.Resouled_ActiveBuffs then
        FILE_SAVE.Resouled_ActiveBuffs = {}
    end

    local buff = Resouled:GetBuffById(buffID)
    
    if buff then
        local key = tostring(buff.Id)
        if FILE_SAVE.Resouled_ActiveBuffs[key] then

            if buff.Stackable then
                FILE_SAVE.Resouled_ActiveBuffs[key] = (FILE_SAVE.Resouled_ActiveBuffs[key]) - 1

                if FILE_SAVE.Resouled_ActiveBuffs[key] <= 0 then

                    FILE_SAVE.Resouled_ActiveBuffs[key] = nil
                end
            else
                FILE_SAVE.Resouled_ActiveBuffs[key] = nil
            end
        end
    else
        Resouled:LogError("Provided unregistered buff while removing active buffs. nil ID: "..tostring(buffID))
    end
end

---@param buffID ResouledBuff
---@return integer
function Resouled:GetPendingBuffAmount(buffID)
    local FILE_SAVE = SAVE_MANAGER.GetPersistentSave()
    local buff = Resouled:GetBuffById(buffID)
    if buff then
        if FILE_SAVE and FILE_SAVE.Resouled_PendingBuffs and FILE_SAVE.Resouled_PendingBuffs[tostring(buffID)] then
            return FILE_SAVE.Resouled_PendingBuffs[tostring(buffID)]
        end
    end
    return 0
end

---@param buffID ResouledBuff
---@return boolean
function Resouled:ActiveBuffPresent(buffID)
    local buff = Resouled:GetBuffById(buffID)
    if buff then
        local FILE_SAVE = SAVE_MANAGER.GetPersistentSave()
        if FILE_SAVE and FILE_SAVE.Resouled_ActiveBuffs and FILE_SAVE.Resouled_ActiveBuffs[tostring(buffID)] then
            return true
        end
    end
    return false
end

function Resouled:ClearBuffSave()
    local FILE_SAVE = SAVE_MANAGER.GetPersistentSave()
    if FILE_SAVE then
        if FILE_SAVE.Resouled_PendingBuffs then
            FILE_SAVE.Resouled_PendingBuffs = nil
            FILE_SAVE.Resouled_PendingBuffs = {}
        end
        if not FILE_SAVE.Resouled_PendingBuffs then
            FILE_SAVE.Resouled_PendingBuffs = nil
            FILE_SAVE.Resouled_PendingBuffs = {}
        end
        if FILE_SAVE.Resouled_ActiveBuffs then
            FILE_SAVE.Resouled_ActiveBuffs = nil
            FILE_SAVE.Resouled_ActiveBuffs = {}
        end
        if not FILE_SAVE.Resouled_ActiveBuffs then
            FILE_SAVE.Resouled_ActiveBuffs = nil
            FILE_SAVE.Resouled_ActiveBuffs = {}
        end
    end
end

function Resouled:ActivatePendingBuffs()
    local FILE_SAVE = SAVE_MANAGER.GetPersistentSave()

    if FILE_SAVE and FILE_SAVE.Resouled_PendingBuffs then
        if not FILE_SAVE.Resouled_ActiveBuffs then
            FILE_SAVE.Resouled_ActiveBuffs = {}
        end

        for buffId, amount in pairs(FILE_SAVE.Resouled_PendingBuffs) do
            local buff = Resouled:GetBuffById(buffId)
            if buff then
                local key = tostring(buff.Id)
                if FILE_SAVE.Resouled_ActiveBuffs[key] then -- buff already present, add stackable otherwise ignore
                    if buff.Stackable then
                        FILE_SAVE.Resouled_ActiveBuffs[key] = FILE_SAVE.Resouled_ActiveBuffs[key] + amount
                    end
                else
                    if buff.Stackable then
                        FILE_SAVE.Resouled_ActiveBuffs[key] = amount
                    else
                        FILE_SAVE.Resouled_ActiveBuffs[key] = true
                    end
                end
            end
        end
        FILE_SAVE.Resouled_PendingBuffs = {} -- clear pending buffs after activation
    end
end

local function postPlayerInit() --Appearently this is THE first callback when starting a run
    local RUN_SAVE = SAVE_MANAGER.GetRunSave()
    local FileSave = SAVE_MANAGER.GetPersistentSave()

    makeSureSavesExist()

    if not FileSave then
        FileSave = {}
    end

    if not RUN_SAVE.Resouled_AddedBuffs and (not Resouled.AfterlifeShop or Resouled.AfterlifeShop and not Resouled.AfterlifeShop.Goto.Activate and not Resouled.AfterlifeShop:IsAfterlifeShop()) then
        RUN_SAVE.Resouled_AddedBuffs = true
        Resouled:ActivatePendingBuffs()
    end
end
Resouled:AddPriorityCallback(ModCallbacks.MC_POST_PLAYER_INIT, CallbackPriority.IMPORTANT, postPlayerInit)

local COMMAND = {
    Name = "addbuff",
    Description = "Adds a buff to pending pool, will be activated on next run's start",
    HelpText = "Usage: addbuff <buff_id>"
}

Console.RegisterCommand(COMMAND.Name, COMMAND.Description, COMMAND.HelpText, false, AutocompleteType.CUSTOM)

local function executeBuffAddCommand(_, command, paramsRaw)
    if command == COMMAND.Name then
        local params = {}
        for word in string.gmatch(paramsRaw, "%S+") do
            table.insert(params, word)
        end
        if #params == 0 then
            Resouled:LogError("No buff specified.")
            return
        end

        local buff = Resouled:GetBuffById(tonumber(params[1]) or params[1])

        if not buff then
            Resouled:LogError("Buff with ID: "..tostring(params[1]).." hasn't been registered.")
            return
        end

        Resouled:AddPendingBuff(buff.Id)
    end
end
Resouled:AddCallback(ModCallbacks.MC_EXECUTE_CMD, executeBuffAddCommand)

local autocompleteTable = {}

Resouled:RunAfterImports(function ()
    for _, buff in ipairs(Resouled:GetBuffs()) do
        table.insert(autocompleteTable, {tostring(buff.Id), buff.Name})
    end
end)

local function buffAddCommandAutocomplete()
    return autocompleteTable
end
---@diagnostic disable-next-line: param-type-mismatch
Resouled:AddCallback(ModCallbacks.MC_CONSOLE_AUTOCOMPLETE, buffAddCommandAutocomplete, COMMAND.Name)

---@param buffId integer
---@return string | nil
function Resouled:GetBuffEIDIcon(buffId)
    local buff = Resouled:GetBuffById(buffId)
    if buff then
        return "{{"..buff.Name..buff.FamilyName.."}}"
    end
    return nil
end

Resouled:AddCallback(ModCallbacks.MC_POST_MODS_LOADED, function() --Create EID icons
    if EID then
        local buffs = Resouled:GetBuffs()
        ---@param buff ResouledBuffDesc
        for _, buff in pairs(buffs) do
            local family = Resouled:GetBuffFamilyById(buff.Family)
            if family then
                local IconSprite = Sprite()
                IconSprite:Load("gfx/buffs/buffEID.anm2", false)
                IconSprite:ReplaceSpritesheet(0, family.Spritesheet, true)
                
                EID:addIcon(buff.Name..buff.FamilyName, Resouled:GetBuffRarityById(buff.Rarity).Name, -1, 12, 9, 3, 6, IconSprite)
            end
        end
    end
end)
