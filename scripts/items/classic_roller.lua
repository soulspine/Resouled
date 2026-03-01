local g = Game()
local itemConfig = Isaac.GetItemConfig()

local CLASSIC_ROLLER = Resouled.Enums.Items.CLASSIC_ROLLER

local DEFAULT_ITEM = CollectibleType.COLLECTIBLE_BREAKFAST

---@param type CollectibleType
---@param rng RNG
---@param player EntityPlayer
---@param flags UseFlag
---@param slot ActiveSlot
---@param data integer
local function onActiveUse(_, type, rng, player, flags, slot, data)

    player:AnimateCollectible(CLASSIC_ROLLER, "UseItem", "PlayerPickupSparkle")

    local itemPool = g:GetItemPool()
    local room = g:GetRoom()

    ---@param pickup EntityPickup
    Resouled.Iterators:IterateOverRoomPickups(function(pickup)

        if pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE and pickup.SubType ~= 0 and not itemConfig:GetCollectible(pickup.SubType):HasTags(ItemConfig.TAG_QUEST) then

            local targetQuality = itemConfig:GetCollectible(pickup.SubType).Quality
            local pool = math.max(room:GetItemPool(room:GetAwardSeed()), 0)
            
            local itemsFromCurrectPool = itemPool:GetCollectiblesFromPool(pool)
            local validItems = {}

            for i = 1, #itemsFromCurrectPool do
                local id = itemsFromCurrectPool[i].itemID
                local config = itemConfig:GetCollectible(id)
                if config and config.Quality == targetQuality and itemPool:CanSpawnCollectible(id, false) then
                    table.insert(validItems, id)
                end
            end

            local newItemID = #validItems > 0 and validItems[rng:RandomInt(#validItems) + 1] or DEFAULT_ITEM
            
            g:Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, pickup.Position, Vector.Zero, nil, 0, Resouled:NewSeed())

            if newItemID then
                pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, newItemID, true, true, false)
                itemPool:RemoveCollectible(newItemID)
            end

        end
    end)
end
Resouled:AddCallback(ModCallbacks.MC_USE_ITEM, onActiveUse, CLASSIC_ROLLER)