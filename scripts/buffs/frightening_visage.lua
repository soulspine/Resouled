local healthReducePrecent = 0.1

---@param npc EntityNPC
local function onNpcInit(npc)
    if npc:IsEnemy() and npc:IsActiveEnemy() then
        npc.MaxHitPoints = npc.MaxHitPoints * (1 - healthReducePrecent)
        npc.HitPoints = npc.MaxHitPoints
    end
end

Resouled:AddBuffToRemoveOnRunEnd(Resouled.Buffs.FRIGHTENING_VISAGE, true)

Resouled:AddBuffCallbackConfig(Resouled.Buffs.FRIGHTENING_VISAGE, {
    {
        CallbackID = ModCallbacks.MC_POST_NPC_INIT,
        Function = onNpcInit
    }
})