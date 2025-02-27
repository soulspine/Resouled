local PRICE_DECREASE = 5
local MIN_PRICE = 1

local GRANT_MIN_COINS = 5
local GRANT_ROOM_VALUE_PERCENTAGE = 0.25
-- if player has less coins than roomValue * GRANT_ROOM_VALUE_PERCENTAGE,
-- they will be granted this blessing

local function onRoomEnter()
    local room = Game():GetRoom()
    local player0 = Isaac.GetPlayer()
    if not Resouled:HasBlessing(player0, Resouled.Blessings.Steam) and room:GetType() == RoomType.ROOM_SHOP then
        local shopValue = Resouled:GetRoomPickupsValue()
        print(shopValue, shopValue * GRANT_ROOM_VALUE_PERCENTAGE)
        local coins = player0:GetNumCoins()
        if coins >= GRANT_MIN_COINS and coins < shopValue * GRANT_ROOM_VALUE_PERCENTAGE then
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
            if Game():IsGreedMode() then
                PRICE_DECREASE = 1
                MIN_PRICE = 0
            end
            data.OriginalPrice = pickup.Price
            pickup.AutoUpdatePrice = false
            data.BlessingOfSteamTargetPrice = data.OriginalPrice - PRICE_DECREASE
            pickup.Price = math.max(MIN_PRICE, data.BlessingOfSteamTargetPrice)
        else
            pickup.AutoUpdatePrice = true
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, onPickupUpdate)