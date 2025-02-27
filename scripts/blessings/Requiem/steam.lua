local PRICE_DECREASE = 5
local MIN_PRICE = 1
local GRANT_MIN_COINS = 5
local GRANT_ROOM_VALUE_PERCENTAGE = 0.25

local GREED_PRICE_DECREASE = 2
local GREED_MIN_PRICE = 1
local GREED_GRANT_MIN_COINS = 12
local GREED_ROOM_VALUE_PERCENTAGE = 0.25

-- if player has less coins than roomValue * GRANT_ROOM_VALUE_PERCENTAGE,
-- they will be granted this blessing

local function onRoomEnter()
    local room = Game():GetRoom()
    local player0 = Isaac.GetPlayer()
    if not Resouled:HasBlessing(player0, Resouled.Blessings.Steam) and room:GetType() == RoomType.ROOM_SHOP then
        local shopValue = Resouled:GetRoomPickupsValue()
        print(shopValue, shopValue * GRANT_ROOM_VALUE_PERCENTAGE)
        local coins = player0:GetNumCoins()
        local grantMinCoins = 0
        local grantRoomValuePercentage = 0

        if Game():IsGreedMode() then
            grantMinCoins = GREED_GRANT_MIN_COINS
            grantRoomValuePercentage = GREED_ROOM_VALUE_PERCENTAGE
        else
            grantMinCoins = GRANT_MIN_COINS
            grantRoomValuePercentage = GRANT_ROOM_VALUE_PERCENTAGE
        end


        if coins >= grantMinCoins and coins <= shopValue * grantRoomValuePercentage then
            Resouled:GrantBlessing(player0, Resouled.Blessings.Steam)
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, onRoomEnter)

---@param pickup EntityPickup
local function onPickupUpdate(_, pickup)
    if Resouled:HasBlessing(Isaac.GetPlayer(), Resouled.Blessings.Steam) and pickup:IsShopItem() and pickup.Price > 0 then
        local data = pickup:GetData()

        if pickup.AutoUpdatePrice == true then
            local decrease = 0
            local minPrice = 0
            if Game():IsGreedMode() then
                decrease = GREED_PRICE_DECREASE
                minPrice = GREED_MIN_PRICE
            else
                decrease = PRICE_DECREASE
                minPrice = MIN_PRICE
            end
            data.OriginalPrice = pickup.Price
            pickup.AutoUpdatePrice = false
            data.BlessingOfSteamTargetPrice = data.OriginalPrice - decrease
            pickup.Price = math.max(minPrice, data.BlessingOfSteamTargetPrice)
        else
            pickup.AutoUpdatePrice = true
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, onPickupUpdate)