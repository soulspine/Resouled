local IsaacEnemy = {
    Type = Isaac.GetEntityTypeByName("Isaac Enemy"),
    Variant = Isaac.GetEntityVariantByName("Isaac Enemy"),
    SubType = Isaac.GetEntitySubTypeByName("Isaac Enemy"),
}

local function postNewRoom()
    if Resouled:RoomEventPresent(Resouled.RoomEvents.THE_ISAAC_OF_ISAAC_ISAAC) then
        ---@param npc EntityNPC
        Resouled.Iterators:IterateOverRoomNpcs(function(npc)
            Game():Spawn(IsaacEnemy.Type, IsaacEnemy.Variant, npc.Position, Vector.Zero, nil, IsaacEnemy.SubType, npc.InitSeed)

            npc:Remove()
        end)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, postNewRoom)