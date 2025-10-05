---@class ResouledEID
local eid = {}

---@enum ResouledEID_Languages
eid.Languages = {
    English = "en_us",
    EnglishDetailed = "en_us_detailed",
    Russian = "ru",
    French = "fr",
    Portuguese = "pt",
    Spanish = "spa",
    Polish = "pl",
    Bulgarian = "bul",
    Turkish = "turkish"
}

---@enum ResouledEID_CommonConditions
eid.CommonConditions = {
    ---@param descObj ResouledEID_Description
    HigherTrinketMult = function(descObj)
        if descObj.Entity then
            ---@diagnostic disable-next-line: param-type-mismatch
            return Resouled.Collectiblextension:GetPotentialTrinketPickupMultiplier(descObj.Entity) > 1
        else
            if descObj.ObjType ~= EntityType.ENTITY_PICKUP
                or descObj.ObjVariant ~= PickupVariant.PICKUP_TRINKET then
                return false
            end
            local golden = descObj.ObjSubType & TrinketType.TRINKET_GOLDEN_FLAG ~= 0

            local applyBox = false
            Resouled.Iterators:IterateOverPlayers(function(player)
                if player:GetTrinketMultiplier(descObj.ObjSubType & ~TrinketType.TRINKET_GOLDEN_FLAG) >= 1
                    and player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_BOX) then
                    applyBox = true
                end
            end)

            return golden or applyBox
        end
    end
}

---@param desc ResouledEID_Description
function eid.GetTrinketMultFromDesc(desc)
    if desc.Entity then
        ---@diagnostic disable-next-line: param-type-mismatch
        return Resouled.Collectiblextension:GetPotentialTrinketPickupMultiplier(desc.Entity)
    else
        if desc.ObjType ~= EntityType.ENTITY_PICKUP
            or desc.ObjVariant ~= PickupVariant.PICKUP_TRINKET then
            return 0
        end
        local mult = 1

        -- golden
        if desc.ObjSubType & TrinketType.TRINKET_GOLDEN_FLAG ~= 0 then
            mult = mult + 1
        end

        local applyBox = false
        Resouled.Iterators:IterateOverPlayers(function(player)
            if player:GetTrinketMultiplier(desc.ObjSubType & ~TrinketType.TRINKET_GOLDEN_FLAG) >= 1
                and player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_BOX) then
                applyBox = true
            end
        end)

        if applyBox then
            mult = mult + 1
        end

        return mult
    end
end

--- Formats a float to remove trailing zeros, e.g. 1.00 -> 1, 1.50 -> 1.5
function eid:FormatFloat(num)
    local s = string.format("%.2f", num)
    s = s:gsub("(%..-)0+$", "%1")
    s = s:gsub("%.$", "")
    return s
end

--- https://github.com/wofsauge/External-Item-Descriptions/wiki/Description-Modifiers#description-object-attributes
---@class ResouledEID_Description
---@field ObjType EntityType | integer Type of described entity
---@field ObjVariant integer Variant of described entity
---@field ObjSubType integer Subtype of described entity
---@field fullItemString string  For example sad onion: "5.100.1"
---@field Name string Translated object name; example: "Sad Onion" or "悲伤洋葱"
---@field Description string Translated object description; example: "↑ +0.7 Tears up" or "↑ +0.7射速"
---@field Transformation table Transformation data, unused for purposes of resouled
---@field ModName string | nil Name of the mod adding this description
---@field Quality integer | nil Quality of displayed object, 0-4/ Set `nil` to remove it
---@field Icon table Icon data, unused for purposes of resouled
---@field Entity Entity | nil Entity that is currently described
---@field ShowWhenUnidentified boolean Whether to show the description even if item is unidentified like a pill or card

---@class ResouledEID_Container
---@field DefaultName string|nil A custom name for the item, if any.
---@field DefaultDescription string|nil A default description for the item, if any.
---@field Translations ResouledEID_TranslationData[] A table to store translated descriptions.
---@field Conditionals table A table to store conditional logic or data for descriptions.

---@class ResouledEID_TranslationData
---@field Language ResouledEID_Languages
---@field Description string
---@field ItemName string|nil

---@class ResouledEID_Conditional
---@field Name string Name for the conditional
---@field Condition fun(descObj:ResouledEID_Description):boolean Condition function that return true when the conditional is supposed to apply
---@field Callback fun(descObj:ResouledEID_Description):ResouledEID_Description Callback function that modifies the description object when the condition is met

---Constructor for ResouledEID_Container
---@return ResouledEID_Container
local function ResouledEID_Container()
    return {
        DefaultName = nil,
        DefaultDescription = nil,
        Translations = {},
        Conditionals = {}
    }
end


---Constructor for ResouledEID_TranslationData
---@param language ResouledEID_Languages
---@param description string
---@param itemName string|nil
---@return ResouledEID_TranslationData
local function ResouledEID_TranslationData(language, description, itemName)
    return {
        Language = language,
        Description = description,
        ItemName = itemName
    }
end

-- populated at runtime
---@type table<CollectibleType, ResouledEID_Container>
local collectibleData = {}
---@type table<TrinketType, ResouledEID_Container>
local trinketData = {}

---@param id CollectibleType
---@param description string
---@param itemName? string
---@param language? string
function eid:AddCollectible(id, description, itemName, language)

end

---@param id TrinketType
---@param description string
---@param itemName? string
---@param language? ResouledEID_Languages
function eid:AddTrinket(id, description, itemName, language)
    if not trinketData[id] then
        trinketData[id] = ResouledEID_Container()
    end
    local data = trinketData[id]

    if language then
        table.insert(data.Translations, ResouledEID_TranslationData(language, description, itemName))
    else
        data.DefaultDescription = description
        data.DefaultName = itemName
    end
end

---@param id TrinketType
---@param name string
---@param condition fun(descObj:ResouledEID_Description):boolean
---@param callback fun(descObj:ResouledEID_Description):ResouledEID_Description
function eid:AddTrinketConditional(id, name, condition, callback)
    if not trinketData[id] then
        Resouled:LogError("EID: Tried to add conditional to trinket ID " ..
            tostring(id) .. " but its container does not exist!")
        return
    end

    local data = trinketData[id]

    ---@param desc ResouledEID_Description
    local newCondition = function(desc)
        return condition(desc)
            and desc.ObjType == EntityType.ENTITY_PICKUP
            and desc.ObjVariant == PickupVariant.PICKUP_TRINKET
            and desc.ObjSubType & ~TrinketType.TRINKET_GOLDEN_FLAG == id
    end

    table.insert(data.Conditionals, { Name = name, Condition = newCondition, Callback = callback })
end

Resouled:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function()
    if not EID then return end

    for id, data in pairs(trinketData) do
        EID:addTrinket(
            id,
            data.DefaultDescription,
            data.DefaultName
        )

        for _, conditional in ipairs(data.Conditionals) do
            EID:addDescriptionModifier(
                conditional.Name,
                conditional.Condition,
                conditional.Callback
            )
        end

        for _, translation in ipairs(data.Translations) do
            EID:addTrinket(
                id,
                translation.Description,
                translation.ItemName,
                translation.Language
            )
        end
    end
end)

return eid
