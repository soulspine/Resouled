local AUCTION_GAVEL = Isaac.GetItemIdByName("Auction Gavel")

if EID then
    EID:addCollectible(AUCTION_GAVEL, "Not implemented yet", "Auction Gavel")
end

local CHANCE = 0.5

local SFX_AUCTION_GAVEL_SOLD = Isaac.GetSoundIdByName("Auction Gavel Sold")
local SFX_SOLD_VOLUME = 1.5

---@param itemID CollectibleType
---@param rng RNG
---@param player EntityPlayer
---@param useFlags number
---@param activeSlot ActiveSlot
---@param customVarData any
local function onActiveUse(_, itemID, rng, player, useFlags, activeSlot, customVarData)
    local activated = false
    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        if entity.Type == EntityType.ENTITY_PICKUP and entity:ToPickup():IsShopItem() then
            if rng:RandomFloat() < CHANCE then
                entity:ToPickup():Morph(entity.Type, entity.Variant, entity.SubType, false, true, true)
                activated = true
            end
        end
    end 

    if activated then
        SFXManager():Play(SFX_AUCTION_GAVEL_SOLD, SFX_SOLD_VOLUME)
    end

    return true
end
MOD:AddCallback(ModCallbacks.MC_USE_ITEM, onActiveUse, AUCTION_GAVEL)