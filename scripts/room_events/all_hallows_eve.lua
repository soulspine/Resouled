local function postNewRoom()
    if Resouled:RoomEventPresent(Resouled.RoomEvents.ALL_HALLOWS_EVE) then
        ---@param npc EntityNPC
        Resouled.Iterators:IterateOverRoomNpcs(function(npc)
            Resouled:TryMakeRoomEventChampion(npc, ChampionColor.TRANSPARENT, true)
        end)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, postNewRoom)