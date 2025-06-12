local RECYCLING_STICKER = Isaac.GetTrinketIdByName("Recycling Sticker")

if EID then
    EID:addTrinket(RECYCLING_STICKER, "When leaving a room, deletes all small pickups in it and spawns a blue spider or a blue fly for it")
end

local PICKUP_WHITELIST = {
    [PickupVariant.PICKUP_BOMB] = true,
    [PickupVariant.PICKUP_COIN] = true,
    [PickupVariant.PICKUP_KEY] = true,
    [PickupVariant.PICKUP_HEART] = true,
    [PickupVariant.PICKUP_LIL_BATTERY] = true,
    [PickupVariant.PICKUP_PILL] = true,
    [PickupVariant.PICKUP_TAROTCARD] = true,
}

local function preRoomLeave()
    if PlayerManager.AnyoneHasTrinket(RECYCLING_STICKER) then
        ---@param entity Entity
        Resouled.Iterators:IterateOverRoomEntities(function(entity)
            local pickup = entity:ToPickup()
            if pickup then
                if PICKUP_WHITELIST[pickup.Variant] then
                    ---@param player EntityPlayer
                    Resouled.Iterators:IterateOverPlayers(function(player)
                        if player:HasTrinket(RECYCLING_STICKER) then
                            local randomNum = math.random(1, 2)
                            if randomNum == 1 then
                                player:AddBlueSpider(player.Position)
                            else
                                player:AddBlueFlies(1, player.Position, nil)
                            end
                        end
                    end)
                    pickup:Remove()
                end
            end
        end)
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_ROOM_EXIT, preRoomLeave)