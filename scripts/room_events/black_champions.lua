local function postNewRoom()
    if Resouled:RoomEventPresent(Resouled.RoomEvents.BLACK_CHAMPIONS) then
        ---@param npc EntityNPC
        Resouled.Iterators:IterateOverRoomNpcs(function(npc)
            Resouled:TryMakeRoomEventChampion(npc, ChampionColor.BLACK, true)
        end)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, postNewRoom)