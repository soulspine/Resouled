local famine = {}
local callbacksActive = false
local mod = Resouled

local itemBlacklist = {}

---@param itemID CollectibleType
local function blacklistItem(itemID)
    itemBlacklist[itemID] = true
end

blacklistItem(CollectibleType.COLLECTIBLE_LUNCH)
blacklistItem(CollectibleType.COLLECTIBLE_RAW_LIVER)
blacklistItem(CollectibleType.COLLECTIBLE_DINNER)
blacklistItem(CollectibleType.COLLECTIBLE_DESSERT)
blacklistItem(CollectibleType.COLLECTIBLE_BREAKFAST)
blacklistItem(CollectibleType.COLLECTIBLE_ROTTEN_MEAT)
blacklistItem(CollectibleType.COLLECTIBLE_BUCKET_OF_LARD)
blacklistItem(CollectibleType.COLLECTIBLE_MEAT)
blacklistItem(CollectibleType.COLLECTIBLE_SNACK)
blacklistItem(CollectibleType.COLLECTIBLE_CRACK_JACKS)
blacklistItem(CollectibleType.COLLECTIBLE_FRUIT_CAKE)
blacklistItem(CollectibleType.COLLECTIBLE_APPLE)
blacklistItem(CollectibleType.COLLECTIBLE_MIDNIGHT_SNACK)
blacklistItem(CollectibleType.COLLECTIBLE_PLAYDOUGH_COOKIE)
blacklistItem(CollectibleType.COLLECTIBLE_FREE_LEMONADE)
blacklistItem(CollectibleType.COLLECTIBLE_BIRDS_EYE)
blacklistItem(CollectibleType.COLLECTIBLE_ROTTEN_TOMATO)
blacklistItem(CollectibleType.COLLECTIBLE_RED_STEW)
blacklistItem(CollectibleType.COLLECTIBLE_BINGE_EATER)
blacklistItem(CollectibleType.COLLECTIBLE_SAUSAGE)
blacklistItem(CollectibleType.COLLECTIBLE_CANDY_HEART)
blacklistItem(CollectibleType.COLLECTIBLE_JELLY_BELLY)
blacklistItem(CollectibleType.COLLECTIBLE_SUPPER)
blacklistItem(Isaac.GetItemIdByName("Pumpkin Mask"))
blacklistItem(CollectibleType.COLLECTIBLE_SAD_ONION)
blacklistItem(CollectibleType.COLLECTIBLE_DEAD_ONION)
blacklistItem(CollectibleType.COLLECTIBLE_CHOCOLATE_MILK)
blacklistItem(CollectibleType.COLLECTIBLE_SOY_MILK)
blacklistItem(CollectibleType.COLLECTIBLE_ALMOND_MILK)
blacklistItem(CollectibleType.COLLECTIBLE_CUBE_OF_MEAT)
blacklistItem(CollectibleType.COLLECTIBLE_JESUS_JUICE)
blacklistItem(CollectibleType.COLLECTIBLE_CAFFEINE_PILL)
blacklistItem(CollectibleType.COLLECTIBLE_MILK)
blacklistItem(CollectibleType.COLLECTIBLE_GHOST_PEPPER)
blacklistItem(CollectibleType.COLLECTIBLE_LEMON_MISHAP)

mod:AddCallback(ModCallbacks.MC_POST_MODS_LOADED, function()
    local itemConfig = Isaac.GetItemConfig()
    local items = itemConfig:GetCollectibles()
    for i = 1, #items - 1 do
        local item = itemConfig:GetCollectible(i)
        if item:HasTags(ItemConfig.TAG_FOOD) then
            blacklistItem(i)
        end
    end
end)

function famine:removeItemsFromPools()
    local itemPool = Game():GetItemPool()
    for itemID, _ in pairs(itemBlacklist) do
        itemPool:RemoveCollectible(itemID)
    end
end

local function postPlayerInit()
    if Resouled:ActiveBuffPresent(Resouled.Buffs.FAMINE) and not callbacksActive then
        famine:addCallbacks()
        famine:removeItemsFromPools()
    end
end
mod:AddPriorityCallback(ModCallbacks.MC_POST_PLAYER_INIT, CallbackPriority.LATE, postPlayerInit)

function famine:postGameEnd()
    if Resouled:ActiveBuffPresent(Resouled.Buffs.FAMINE) then
        Resouled:RemoveActiveBuff(Resouled.Buffs.FAMINE)
        famine:removeCallbacks()
    end
end

function famine:preGameExit()
    if callbacksActive then
        famine:removeCallbacks()
    end
end

function famine:addCallbacks()
    if not callbacksActive then
        mod:AddCallback(ModCallbacks.MC_POST_GAME_END, famine.postGameEnd)
        mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, famine.preGameExit)
        callbacksActive = true
    end
end

function famine:removeCallbacks()
    if callbacksActive then
        mod:RemoveCallback(ModCallbacks.MC_POST_GAME_END, famine.postGameEnd)
        mod:RemoveCallback(ModCallbacks.MC_PRE_GAME_EXIT, famine.preGameExit)
        callbacksActive = false
    end
end

Resouled:AddBuffDescription(Resouled.Buffs.FAMINE, Resouled.EID:AutoIcons("Food items can not appear the whole run"))