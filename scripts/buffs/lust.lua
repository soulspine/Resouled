local DURATION = 60

local function postNewRoom()
    local ref = EntityRef(Isaac.GetPlayer())
    Resouled.Iterators:IterateOverRoomNpcs(function(npc)
        npc:AddCharmed(ref, DURATION)
    end)
end

Resouled:AddBuffCallbackConfig(Resouled.Buffs.LUST, {
    {
        CallbackID = ModCallbacks.MC_POST_NEW_ROOM,
        Function = postNewRoom
    }
})

Resouled:AddBuffToRemoveOnRunEnd(Resouled.Buffs.LUST, true)