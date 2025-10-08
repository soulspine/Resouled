local TRINKET = Isaac.GetTrinketIdByName("Recycling Sticker")

local CONFIG = {
    AffectedPickups = {
        [PickupVariant.PICKUP_BOMB] = true,
        [PickupVariant.PICKUP_COIN] = true,
        [PickupVariant.PICKUP_KEY] = true,
        [PickupVariant.PICKUP_HEART] = true,
        [PickupVariant.PICKUP_LIL_BATTERY] = true,
        [PickupVariant.PICKUP_PILL] = true,
        [PickupVariant.PICKUP_TAROTCARD] = true,
    },
    EidDescription = "Upon leaving a room, converts all small pickups into either a blue spider or a blue fly",
    EidDescriptionGolden = "Upon leaving a room, converts all small pickups into %s blue spiders or blue flies"
}

Resouled.EID:AddTrinket(TRINKET, CONFIG.EidDescription)
Resouled.EID:AddTrinketConditional(TRINKET, "Resouled__RecyclingSticker_Golden",
    Resouled.EID.CommonConditions.HigherTrinketMult,
    function(desc)
        desc.Description = string.format(CONFIG.EidDescriptionGolden,
            "{{ColorGold}}" .. Resouled.EID:GetTrinketMultFromDesc(desc) .. "{{ColorText}}")
        return desc
    end
)

local function preRoomLeave()
    if not PlayerManager.AnyoneHasTrinket(TRINKET) then return end

    local pickupCount = 0

    Resouled.Iterators:IterateOverRoomEntities(function(entity)
        local pickup = entity:ToPickup()
        if not pickup then return end
        if not CONFIG.AffectedPickups[pickup.Variant] then return end
        pickupCount = pickupCount + 1
        pickup:Remove()
    end)

    if pickupCount == 0 then return end

    Resouled.Iterators:IterateOverPlayers(function(player)
        local playerMult = player:GetTrinketMultiplier(TRINKET)
        if playerMult == 0 then return end
        local rng = player:GetTrinketRNG(TRINKET)
        local totalSpawns = pickupCount * playerMult
        local spiderCount = rng:RandomInt(totalSpawns + 1)
        local flyCount = totalSpawns - spiderCount
        for _ = 1, spiderCount do
            player:AddBlueSpider(player.Position)
        end
        player:AddBlueFlies(flyCount, player.Position, nil)
    end)
end
Resouled:AddCallback(ModCallbacks.MC_PRE_ROOM_EXIT, preRoomLeave)
