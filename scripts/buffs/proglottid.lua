---@param pic EntityPickup
Resouled:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, function(_, pic)
    if not Resouled:ActiveBuffPresent(Resouled.Buffs.PROGLOTTID) or pic.Variant ~= PickupVariant.PICKUP_COLLECTIBLE or Game():GetRoom():GetType() ~= RoomType.ROOM_BOSS then return end

    pic:AddCollectibleCycle(Resouled.Enums.Items.RED_PROGLOTTID)
    pic:AddCollectibleCycle(Resouled.Enums.Items.PINK_PROGLOTTID)
    pic:AddCollectibleCycle(Resouled.Enums.Items.WHITE_PROGLOTTID)
    pic:AddCollectibleCycle(Resouled.Enums.Items.BLACK_PROGLOTTID)

    Resouled:RemoveActiveBuff(Resouled.Buffs.PROGLOTTID)
end)