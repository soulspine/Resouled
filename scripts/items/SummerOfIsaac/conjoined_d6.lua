local CONJOINED_D6 = Isaac.GetItemIdByName("Conjoined D6")

local CONJOINED_CD6_BASE_MULTIPLIER = 1
local ON_USE_MULTIPLIER_GAIN = 0.05
local ON_USE_MULTIPLIER_LOSS = 0.05

---@param collectibleType CollectibleType
---@param rng RNG
---@param player EntityPlayer
---@param useFlags UseFlag
---@param activeSlot ActiveSlot
local function preUseItem(_, collectibleType, rng, player, useFlags, activeSlot)
    if collectibleType == CONJOINED_D6 then
        local data = player:GetData()
        data.ResouledCD6OldItems = {}
        ---@param entity Entity
        Resouled:IterateOverRoomEntities(function(entity)
            if entity.Type == EntityType.ENTITY_PICKUP and entity.Variant == PickupVariant.PICKUP_COLLECTIBLE then
                if entity.SubType ~= 0 and entity.SubType ~= nil then
                    table.insert(data.ResouledCD6OldItems, entity.SubType)
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

        if not RunSave.ResouledCD6Multiplier[player.Index] then
            RunSave.ResouledCD6Multiplier[player.Index] = CONJOINED_CD6_BASE_MULTIPLIER
        end

        local data = player:GetData()
        player:UseActiveItem(CollectibleType.COLLECTIBLE_D6)
        player:AnimateCollectible(CONJOINED_D6, "UseItem")
        data.ResouledCD6NewItems = {}
        Resouled:IterateOverRoomEntities(function(entity)
            if entity.Type == EntityType.ENTITY_PICKUP and entity.Variant == PickupVariant.PICKUP_COLLECTIBLE then
                if entity.SubType ~= 0 and entity.SubType ~= nil then
                    table.insert(data.ResouledCD6NewItems, entity.SubType)
                end
            end
        end)
        for i = 1, #data.ResouledCD6NewItems do
            if Isaac.GetItemConfig():GetCollectible(data.ResouledCD6NewItems[i]).Quality < Isaac.GetItemConfig():GetCollectible(data.ResouledCD6OldItems[i]).Quality then
                RunSave.ResouledCD6Multiplier[player.Index] = RunSave.ResouledCD6Multiplier[player.Index] + ON_USE_MULTIPLIER_GAIN
            end
            if Isaac.GetItemConfig():GetCollectible(data.ResouledCD6NewItems[i]).Quality > Isaac.GetItemConfig():GetCollectible(data.ResouledCD6OldItems[i]).Quality then
                RunSave.ResouledCD6Multiplier[player.Index] = RunSave.ResouledCD6Multiplier[player.Index] - ON_USE_MULTIPLIER_LOSS
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
    local RunSave = SAVE_MANAGER.GetRunSave()
    local data = player:GetData()
    if player:HasCollectible(CONJOINED_D6) then
        
        if cacheFlags == CacheFlag.CACHE_DAMAGE then
            player.Damage = player.Damage * RunSave.ResouledCD6Multiplier[player.Index]
        end
        if cacheFlags == CacheFlag.CACHE_FIREDELAY then
            player.MaxFireDelay = player.MaxFireDelay / RunSave.ResouledCD6Multiplier[player.Index]
        end
        if cacheFlags == CacheFlag.CACHE_SPEED then
            player.MoveSpeed = player.MoveSpeed * RunSave.ResouledCD6Multiplier[player.Index]
        end
        if cacheFlags == CacheFlag.CACHE_RANGE then
            player.TearRange = player.TearRange * RunSave.ResouledCD6Multiplier[player.Index]
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, onCacheEval)

---@param player EntityPlayer
local function postPlayerInit(_, player)
    local RunSave = SAVE_MANAGER.GetRunSave()
    local data = player:GetData()
    if player:HasCollectible(CONJOINED_D6) and RunSave.ResouledCD6Multiplier[player.Index] then
        player:AddCacheFlags(CacheFlag.CACHE_ALL)
        print(RunSave.ResouledCD6Multiplier[player.Index])
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, postPlayerInit)