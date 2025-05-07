local function postNewRoom()
    if Resouled:RoomEventPresent(Resouled.RoomEvents.RED_CHAMPIONS) then
        ---@param entity Entity
        Resouled.Iterators:IterateOverRoomEntities(function(entity)
            if entity:IsEnemy() and entity:IsActiveEnemy() and not entity:IsBoss() then
                local npc = entity:ToNPC()
                if npc then
                    npc:MakeChampion(npc.InitSeed, ChampionColor.RED, false)
                end
            end
        end)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, postNewRoom)