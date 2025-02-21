local OBTAIN_ITEM_THRESHOLD = 6
local SPAWN_CHANCE_PER_PEDESTAL = 0.33

---@param player EntityPlayer
local function onPlayerInit(_, player)
    local playerRunSave = SAVE_MANAGER.GetRunSave(player)
    playerRunSave.Blessings.Isaac = {
        ItemCount = 0,
        QualityCount = Resouled:GetCollectibleQualityNum(player),
    }
end
Resouled:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, onPlayerInit)

---@param player EntityPlayer
---@param cacheFlag CacheFlag
local function onPlayerUpdate(_, player, cacheFlag)
    local playerRunSave = SAVE_MANAGER.GetRunSave(player)
    if player:GetCollectibleCount() ~= playerRunSave.Blessings.Isaac.ItemCount then
        playerRunSave.Blessings.Isaac.ItemCount = player:GetCollectibleCount()
        playerRunSave.Blessings.Isaac.QualityCount = Resouled:GetCollectibleQualityNum(player)

        local q0count = playerRunSave.Blessings.Isaac.QualityCount[0]
        local q1count = playerRunSave.Blessings.Isaac.QualityCount[1]

        if q0count + q1count >= OBTAIN_ITEM_THRESHOLD then
            Resouled:GrantBlessing(player, Resouled.Blessings.Isaac)
        end

    end
end
Resouled:AddPriorityCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, CallbackPriority.LATE, onPlayerUpdate)

local function spawnOneRoomDiceShard()
    ---@param player EntityPlayer
    Resouled:IterateOverPlayers(function(player, playerId)
        if Resouled:HasBlessing(player, Resouled.Blessings.Isaac) then
            local playerRunSave = SAVE_MANAGER.GetRunSave(player)
            local room = Game():GetRoom()
            if room:IsFirstVisit() then
                local rng = RNG()
                rng:SetSeed(room:GetSpawnSeed(), 0)

                local roomPedestalCount = Isaac.CountEntities(nil, EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)
                local grantChance = SPAWN_CHANCE_PER_PEDESTAL * roomPedestalCount

                if player:GetActiveItem(ActiveSlot.SLOT_POCKET2) == CollectibleType.COLLECTIBLE_NULL and rng:RandomFloat() < grantChance then
                    player:SetPocketActiveItem(CollectibleType.COLLECTIBLE_D6, ActiveSlot.SLOT_POCKET2, true)
                end
            end
        end
    end)
end
Resouled:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, spawnOneRoomDiceShard)