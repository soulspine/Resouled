---@param pic EntityPickup
local function onPickupInit(_, pic)
    if not Resouled:ActiveBuffPresent(Resouled.Buffs.PROGLOTTID) or pic.Variant ~= PickupVariant.PICKUP_COLLECTIBLE or Resouled.Game:GetRoom():GetType() ~= RoomType.ROOM_BOSS then return end

    pic:AddCollectibleCycle(Resouled.Enums.Items.RED_PROGLOTTID)
    pic:AddCollectibleCycle(Resouled.Enums.Items.PINK_PROGLOTTID)
    pic:AddCollectibleCycle(Resouled.Enums.Items.WHITE_PROGLOTTID)
    pic:AddCollectibleCycle(Resouled.Enums.Items.BLACK_PROGLOTTID)

    Resouled:RemoveActiveBuff(Resouled.Buffs.PROGLOTTID)
    Resouled:RemoveCallback(ModCallbacks.MC_POST_PICKUP_INIT, onPickupInit)
end

Resouled:AddBuffCallbackConfig(Resouled.Buffs.PROGLOTTID, {
    {
        CallbackID = ModCallbacks.MC_POST_PICKUP_INIT,
        Function = onPickupInit
    }
})