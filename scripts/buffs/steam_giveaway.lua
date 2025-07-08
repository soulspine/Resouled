local function postNewRoom()
    if Resouled:ActiveBuffPresent(Resouled.Buffs.STEAM_GIVEAWAY) and Game():GetRoom():GetType() == RoomType.ROOM_SHOP and Game():GetLevel():GetStage() == 1 then
        ---@param entity Entity
        Resouled.Iterators:IterateOverRoomEntities(function(entity)
            local pickup = entity:ToPickup()
            if pickup then
                if pickup.Price > 0 then
                    pickup:Morph(pickup.Type, pickup.Variant, pickup.SubType, false, true, false)
                    Resouled:RemoveActiveBuff(Resouled.Buffs.STEAM_GIVEAWAY)
                end
            end
        end)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, postNewRoom)