local function postNewRoom()
    if Resouled:RoomEventPresent(Resouled.RoomEvents.BUM_BO_IS_LOOSE) then
        local bumbo = Game():Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BUMBO, Isaac.GetFreeNearPosition(Game():GetRoom():GetCenterPos(), 0), Vector.Zero, nil, 0, Game():GetRoom():GetAwardSeed())
        bumbo:GetData().Resouled_BumBoDelete = true
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, postNewRoom)

local function preNewRoom()
    ---@param entity Entity
    Resouled.Iterators:IterateOverRoomEntities(function(entity)
        local data = entity:GetData()
        if data.Resouled_BumBoDelete then
            entity:Remove()
        end
    end)
end
Resouled:AddCallback(ModCallbacks.MC_PRE_NEW_ROOM, preNewRoom)