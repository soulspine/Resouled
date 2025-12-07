local CONJOINED_D6 = Resouled.Enums.Items.CONJOINED_D6

local CONJOINED_CD6_BASE_MULTIPLIER = 1
local ON_USE_MULTIPLIER_GAIN = 0.035
local ON_USE_MULTIPLIER_LOSS = 0.035

---@param collectibleType CollectibleType
---@param rng RNG
---@param player EntityPlayer
---@param useFlags UseFlag
---@param activeSlot ActiveSlot
local function preUseItem(_, collectibleType, rng, player, useFlags, activeSlot)
    if collectibleType == CONJOINED_D6 then
        local data = player:GetData()
        data.ResouledCD6OldItems = {}
        ---@param pickup EntityPickup
        Resouled.Iterators:IterateOverRoomPickups(function(pickup)
            if pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE then
                if pickup.SubType ~= 0 and pickup.SubType ~= nil then
                    table.insert(data.ResouledCD6OldItems, pickup.SubType)
                end
            end
        end)
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, preUseItem)

---@param collectibleType CollectibleType
---@param rng RNG
---@param player EntityPlayer
---@param useFlags UseFlag
---@param activeSlot ActiveSlot
local function onItemUse(_, collectibleType, rng, player, useFlags, activeSlot)
    if collectibleType == CONJOINED_D6 then
        local RunSave = Resouled.SaveManager.GetRunSave()

        local indexKey = tostring(player:GetPlayerIndex())
        local formKey = tostring(player:GetCollectibleRNG(CONJOINED_D6):GetSeed())

        if not RunSave.ResouledCD6Multiplier then
            RunSave.ResouledCD6Multiplier = {}
        end

        if not RunSave.ResouledCD6Multiplier[indexKey] then
            RunSave.ResouledCD6Multiplier[indexKey] = {}
        end

        if not RunSave.ResouledCD6Multiplier[indexKey][formKey] then
            RunSave.ResouledCD6Multiplier[indexKey][formKey] = CONJOINED_CD6_BASE_MULTIPLIER
        end

        local data = player:GetData()
        player:UseActiveItem(CollectibleType.COLLECTIBLE_D6)
        player:AnimateCollectible(CONJOINED_D6, "UseItem")
        data.ResouledCD6NewItems = {}
        Resouled.Iterators:IterateOverRoomPickups(function(pickup)
            if pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE then
                if pickup.SubType ~= 0 and pickup.SubType ~= nil then
                    table.insert(data.ResouledCD6NewItems, pickup.SubType)
                end
            end
        end)
        local itemConfig = Isaac.GetItemConfig()
        for i = 1, #data.ResouledCD6NewItems do
            local q1 = itemConfig:GetCollectible(data.ResouledCD6NewItems[i]).Quality
            local q2 = itemConfig:GetCollectible(data.ResouledCD6OldItems[i]).Quality
            local qualityDifference = math.abs(q1 - q2)
            if q1 < q2 then
                RunSave.ResouledCD6Multiplier[indexKey][formKey] = (RunSave.ResouledCD6Multiplier[indexKey][formKey] + ON_USE_MULTIPLIER_GAIN * qualityDifference)
            end
            if q1 > q2 then
                RunSave.ResouledCD6Multiplier[indexKey][formKey] = (RunSave.ResouledCD6Multiplier[indexKey][formKey] - ON_USE_MULTIPLIER_LOSS * qualityDifference)
            end
            player:AddCacheFlags(CacheFlag.CACHE_ALL)
        end
        data.ResouledCD6NewItems = nil
        data.ResouledCD6OldItems = nil
    end
end
Resouled:AddCallback(ModCallbacks.MC_USE_ITEM, onItemUse)

---@param player EntityPlayer
---@param cacheFlags CacheFlag
local function onCacheEval(_, player, cacheFlags)
    local RunSave = Resouled.SaveManager.GetRunSave()

    if RunSave.ResouledCD6Multiplier == nil then
        return
    end

    local indexKey = tostring(player:GetPlayerIndex())
    local formKey = tostring(player:GetCollectibleRNG(CONJOINED_D6):GetSeed())

    if RunSave.ResouledCD6Multiplier[indexKey] and RunSave.ResouledCD6Multiplier[indexKey][formKey] then
        if cacheFlags == CacheFlag.CACHE_DAMAGE then
            player.Damage = player.Damage * RunSave.ResouledCD6Multiplier[indexKey][formKey]
        end
        if cacheFlags == CacheFlag.CACHE_FIREDELAY then
            player.MaxFireDelay = player.MaxFireDelay / RunSave.ResouledCD6Multiplier[indexKey][formKey]
        end
        if cacheFlags == CacheFlag.CACHE_SPEED then
            player.MoveSpeed = player.MoveSpeed * RunSave.ResouledCD6Multiplier[indexKey][formKey]
        end
        if cacheFlags == CacheFlag.CACHE_RANGE then
            player.TearRange = player.TearRange * RunSave.ResouledCD6Multiplier[indexKey][formKey]
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, onCacheEval)

---@param player EntityPlayer
local function postPlayerInit(_, player)
    local RunSave = Resouled.SaveManager.GetRunSave()
    player:GetPlayerIndex()

    if RunSave.ResouledCD6Multiplier == nil then
        return
    end
    
    local indexKey = tostring(player:GetPlayerIndex())
    local formKey = tostring(player:GetCollectibleRNG(CONJOINED_D6):GetSeed())

    if RunSave.ResouledCD6Multiplier[indexKey] and RunSave.ResouledCD6Multiplier[indexKey][formKey] then
        player:AddCacheFlags(CacheFlag.CACHE_ALL)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, postPlayerInit)