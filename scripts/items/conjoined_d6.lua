local CONJOINED_D6 = Isaac.GetItemIdByName("Conjoined D6")

if EID then
    EID:addCollectible(CONJOINED_D6, "Rerolls pedestal items in the room. #{{ArrowUp}} If the quality of the pedestal after the roll is lower than the quality before roll, the player recieves stat ups. #{{ArrowDown}} If the quality of the pedestal after the roll is higher than the quality before roll, the player recieves stat downs.")
end

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
        local RunSave = SAVE_MANAGER.GetRunSave()

        if not RunSave.ResouledCD6Multiplier then
            RunSave.ResouledCD6Multiplier = {}
        end

        if not RunSave.ResouledCD6Multiplier[tostring(player:GetPlayerIndex())] then
            RunSave.ResouledCD6Multiplier[tostring(player:GetPlayerIndex())] = CONJOINED_CD6_BASE_MULTIPLIER
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
        for i = 1, #data.ResouledCD6NewItems do
            local qualityDifference = math.abs(Isaac.GetItemConfig():GetCollectible(data.ResouledCD6NewItems[i]).Quality - Isaac.GetItemConfig():GetCollectible(data.ResouledCD6OldItems[i]).Quality)
            if Isaac.GetItemConfig():GetCollectible(data.ResouledCD6NewItems[i]).Quality < Isaac.GetItemConfig():GetCollectible(data.ResouledCD6OldItems[i]).Quality then
                RunSave.ResouledCD6Multiplier[tostring(player:GetPlayerIndex())] = (RunSave.ResouledCD6Multiplier[tostring(player:GetPlayerIndex())] + ON_USE_MULTIPLIER_GAIN * qualityDifference)
            end
            if Isaac.GetItemConfig():GetCollectible(data.ResouledCD6NewItems[i]).Quality > Isaac.GetItemConfig():GetCollectible(data.ResouledCD6OldItems[i]).Quality then
                RunSave.ResouledCD6Multiplier[tostring(player:GetPlayerIndex())] = (RunSave.ResouledCD6Multiplier[tostring(player:GetPlayerIndex())] - ON_USE_MULTIPLIER_LOSS * qualityDifference)
            end
            player:AddCacheFlags(CacheFlag.CACHE_ALL)
        end
        data.ResouledCD6NewItems = nil
        data.ResouledCD6OldItems = nil
        print(RunSave.ResouledCD6Multiplier[tostring(player:GetPlayerIndex())])
    end
end
Resouled:AddCallback(ModCallbacks.MC_USE_ITEM, onItemUse)

---@param player EntityPlayer
---@param cacheFlags CacheFlag
local function onCacheEval(_, player, cacheFlags)
    local RunSave = SAVE_MANAGER.GetRunSave()
    local data = player:GetData()

    if RunSave.ResouledCD6Multiplier == nil then
        return
    end

    if RunSave.ResouledCD6Multiplier[tostring(player:GetPlayerIndex())] then
        if cacheFlags == CacheFlag.CACHE_DAMAGE then
            player.Damage = player.Damage * RunSave.ResouledCD6Multiplier[tostring(player:GetPlayerIndex())]
        end
        if cacheFlags == CacheFlag.CACHE_FIREDELAY then
            player.MaxFireDelay = player.MaxFireDelay / RunSave.ResouledCD6Multiplier[tostring(player:GetPlayerIndex())]
        end
        if cacheFlags == CacheFlag.CACHE_SPEED then
            player.MoveSpeed = player.MoveSpeed * RunSave.ResouledCD6Multiplier[tostring(player:GetPlayerIndex())]
        end
        if cacheFlags == CacheFlag.CACHE_RANGE then
            player.TearRange = player.TearRange * RunSave.ResouledCD6Multiplier[tostring(player:GetPlayerIndex())]
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, onCacheEval)

---@param player EntityPlayer
local function postPlayerInit(_, player)
    local RunSave = SAVE_MANAGER.GetRunSave()
    player:GetPlayerIndex()

    if RunSave.ResouledCD6Multiplier == nil then
        return
    end

    if RunSave.ResouledCD6Multiplier[tostring(player:GetPlayerIndex())] then
        player:AddCacheFlags(CacheFlag.CACHE_ALL)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, postPlayerInit)