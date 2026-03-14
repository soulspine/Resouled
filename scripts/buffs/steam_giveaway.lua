local function postNewRoom()
    if Resouled.Game:GetRoom():GetType() == RoomType.ROOM_SHOP and Resouled.Game:GetLevel():GetStage() == 1 then
        ---@param entity Entity
        Resouled.Iterators:IterateOverRoomEntities(function(entity)
            local pickup = entity:ToPickup()
            if pickup then
                if pickup.Price > 0 then
                    pickup:Morph(pickup.Type, pickup.Variant, pickup.SubType, false, true, false)
                end
            end
        end)
        Resouled:RemoveActiveBuff(Resouled.Buffs.STEAM_GIVEAWAY)
        Resouled:RemoveCallback(ModCallbacks.MC_POST_NEW_ROOM, postNewRoom)
    end
end

Resouled:AddBuffCallbackConfig(Resouled.Buffs.STEAM_GIVEAWAY, {
    {
        CallbackID = ModCallbacks.MC_POST_NEW_ROOM,
        Function = postNewRoom
    }
})