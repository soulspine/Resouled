local SLEIGHT_OF_HAND = Isaac.GetItemIdByName("Sleight of Hand")
local FOREVER_ALONE = CollectibleType.COLLECTIBLE_FOREVER_ALONE
local SPINDOWN_DICE = CollectibleType.COLLECTIBLE_SPINDOWN_DICE
local KEEPERS_BARGAIN = TrinketType.TRINKET_KEEPERS_BARGAIN
local CEREMONIAL_BLADE = Isaac.GetItemIdByName("Ceremonial Blade")
local SIBLING_RIVALRY = Isaac.GetItemIdByName("Sibling Rivalry")

---@param player EntityPlayer
local function onPlayerInit(_, player)
    local playerType = player:GetPlayerType()
    --BaseGameV2
    if playerType == PlayerType.PLAYER_CAIN then
        if player:GetActiveItem(ActiveSlot.SLOT_PRIMARY) == CollectibleType.COLLECTIBLE_NULL then
            player:AddCollectible(SLEIGHT_OF_HAND, 0, true, ActiveSlot.SLOT_PRIMARY, 0)
        end
    end

    if playerType == PlayerType.PLAYER_BLUEBABY then
        player:AddCollectible(FOREVER_ALONE)
        player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS)
        player:CheckFamiliar(FamiliarVariant.FOREVER_ALONE, 1, player:GetCollectibleRNG(FOREVER_ALONE))
    end
    --FourSoulsV2

    --Requiem
    if playerType == PlayerType.PLAYER_JACOB then
        if player:GetActiveItem(ActiveSlot.SLOT_PRIMARY) == CollectibleType.COLLECTIBLE_NULL then
            player:AddCollectible(SIBLING_RIVALRY, 0, true, ActiveSlot.SLOT_PRIMARY, 0)
        end
    end

    if playerType == PlayerType.PLAYER_ISAAC_B then
        if player:GetActiveItem(ActiveSlot.SLOT_POCKET) == CollectibleType.COLLECTIBLE_NULL then
            player:SetPocketActiveItem(SPINDOWN_DICE, ActiveSlot.SLOT_POCKET, false)
        end
    end

    if playerType == PlayerType.PLAYER_JUDAS_B then
        player:AddCollectible(CEREMONIAL_BLADE)
    end
    
    if playerType == PlayerType.PLAYER_KEEPER_B then
        player:AddTrinket(KEEPERS_BARGAIN, true)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, onPlayerInit)