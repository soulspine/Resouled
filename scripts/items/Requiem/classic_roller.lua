local CLASSIC_ROLLER = Isaac.GetItemIdByName("Classic Roller")

---@param type CollectibleType
---@param rng RNG
---@param player EntityPlayer
---@param flags UseFlag
---@param slot ActiveSlot
---@param data integer
local function onActiveUse(_, type, rng, player, flags, slot, data)
    player:AnimateCollectible(CLASSIC_ROLLER, "UseItem", "PlayerPickupSparkle")
    ---@param entity Entity
    Resouled:IterateOverRoomEntities(function(entity)
        local pickup = entity:ToPickup()
        if pickup then
            if pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE then
                local targetQuality = Isaac.GetItemConfig():GetCollectible(pickup.SubType).Quality
                local itemsFromCurrectPool = Game():GetItemPool():GetCollectiblesFromPool(Game():GetRoom():GetItemPool(Game():GetRoom():GetAwardSeed()))
                local validItems = {}
                for i = 1, #itemsFromCurrectPool do
                    local id = itemsFromCurrectPool[i].itemID
                    if Isaac.GetItemConfig():GetCollectible(id).Quality == targetQuality and Game():GetItemPool():CanSpawnCollectible(id, false) then
                        table.insert(validItems, id)
                    end
                end

                local randomNum = rng:RandomInt(#validItems) + 1
                local newItemID = validItems[randomNum]

                Game():Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, pickup.Position, Vector.Zero, nil, 0, pickup.InitSeed)
                if newItemID then
                    pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, newItemID, true, true, false)
                    Game():GetItemPool():RemoveCollectible(newItemID)
                    Resouled:NewSeed()
                end
            end
        end
    end)
end
Resouled:AddCallback(ModCallbacks.MC_USE_ITEM, onActiveUse, CLASSIC_ROLLER)