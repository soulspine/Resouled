local CAIN = PlayerType.PLAYER_CAIN
local BLUE_BABY = PlayerType.PLAYER_BLUEBABY
local JACOB = PlayerType.PLAYER_JACOB
local ESAU = PlayerType.PLAYER_ESAU
local TISAAC = PlayerType.PLAYER_ISAAC_B
local TJUDAS = PlayerType.PLAYER_JUDAS_B
local TEDEN = PlayerType.PLAYER_EDEN_B
local TLOST = PlayerType.PLAYER_THELOST_B
local TKEEPER = PlayerType.PLAYER_KEEPER_B

local SLEIGHT_OF_HAND = Isaac.GetItemIdByName("Sleight of Hand")
local FOREVER_ALONE = CollectibleType.COLLECTIBLE_FOREVER_ALONE
local SPINDOWN_DICE = CollectibleType.COLLECTIBLE_SPINDOWN_DICE
local KEEPERS_BARGAIN = TrinketType.TRINKET_KEEPERS_BARGAIN
local CEREMONIAL_BLADE = Isaac.GetItemIdByName("Ceremonial Blade")

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

    --Requiem
    if player:GetPlayerType() == TISAAC then
        if player:GetActiveItem(ActiveSlot.SLOT_POCKET) == CollectibleType.COLLECTIBLE_NULL then
            player:SetPocketActiveItem(SPINDOWN_DICE, ActiveSlot.SLOT_POCKET, false)
        end
    end
    
    if player:GetPlayerType() == TKEEPER then
        player:AddTrinket(KEEPERS_BARGAIN, true)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, onPlayerInit)