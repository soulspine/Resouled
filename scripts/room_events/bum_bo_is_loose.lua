local function postNewRoom()
    if Resouled:RoomEventPresent(Resouled.RoomEvents.BUM_BO_IS_LOOSE) then
        Game():Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BUMBO, Isaac.GetFreeNearPosition(Game():GetRoom():GetCenterPos(), 0), Vector.Zero, nil, 0, Game():GetRoom():GetAwardSeed())
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, postNewRoom)

local function preNewRoom()
    if Resouled:RoomEventPresent(Resouled.RoomEvents.BUM_BO_IS_LOOSE) then
        ---@param player EntityPlayer
        Resouled.Iterators:IterateOverPlayers(function(player)
            player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS, true)
        end)
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_NEW_ROOM, preNewRoom)