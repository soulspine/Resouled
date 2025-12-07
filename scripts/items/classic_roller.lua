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
    local itemConfig = Isaac.GetItemConfig()
    ---@param pickup EntityPickup
    Resouled.Iterators:IterateOverRoomPickups(function(pickup)
        if pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE and pickup.SubType ~= 0 and not itemConfig:GetCollectible(pickup.SubType):HasTags(ItemConfig.TAG_QUEST) then
            local targetQuality = itemConfig:GetCollectible(pickup.SubType).Quality
            local itemsFromCurrectPool = Game():GetItemPool():GetCollectiblesFromPool(Game():GetRoom():GetItemPool(Game():GetRoom():GetAwardSeed()))
            local validItems = {}
            for i = 1, #itemsFromCurrectPool do
                local id = itemsFromCurrectPool[i].itemID
                if  itemConfig:GetCollectible(id) and itemConfig:GetCollectible(id).Quality == targetQuality and Game():GetItemPool():CanSpawnCollectible(id, false) then
                    table.insert(validItems, id)
                end
            end
            
            local newItemID = #validItems > 0 and validItems[rng:RandomInt(#validItems) + 1] or DEFAULT_ITEM
            
            Game():Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, pickup.Position, Vector.Zero, nil, 0, Resouled:NewSeed())
            if newItemID then
                pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, newItemID, true, true, false)
                Game():GetItemPool():RemoveCollectible(newItemID)
                Resouled:NewSeed()
            end
        end
    end)
end
Resouled:AddCallback(ModCallbacks.MC_USE_ITEM, onActiveUse, CLASSIC_ROLLER)