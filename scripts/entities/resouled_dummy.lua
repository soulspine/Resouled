local dummy = Resouled.Stats.Dummy

---@param npc EntityNPC
local function postNpcInit(_, npc)
    if npc.Variant == dummy.Variant and npc.SubType == dummy.SubType then
        npc:Remove()
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_INIT, postNpcInit, dummy.Type)