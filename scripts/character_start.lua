local CAIN = PlayerType.PLAYER_CAIN
local BLUE_BABY = PlayerType.PLAYER_BLUEBABY

local SLEIGHT_OF_HAND = Isaac.GetItemIdByName("Sleight of Hand")
local FOREVER_ALONE = CollectibleType.COLLECTIBLE_FOREVER_ALONE

---@param player EntityPlayer
local function onPlayerInit(_, player)
    --BaseGameV2
    if player:GetPlayerType() == CAIN then
        if player:GetActiveItem(ActiveSlot.SLOT_PRIMARY) == CollectibleType.COLLECTIBLE_NULL then
            player:AddCollectible(SLEIGHT_OF_HAND, 0, true, ActiveSlot.SLOT_PRIMARY, 0)
        end
    end

    if player:GetPlayerType() == BLUE_BABY then
        player:AddCollectible(FOREVER_ALONE)
        player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS)
        player:CheckFamiliar(FamiliarVariant.FOREVER_ALONE, 1, player:GetCollectibleRNG(FOREVER_ALONE))
    end
    --FourSoulsV2
end
Resouled:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, onPlayerInit)