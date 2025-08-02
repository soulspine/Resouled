local terrifyingPhysiognomy = {}
local callbacksActive = false
local mod = Resouled

local healthReducePrecent = 0.15

---@param npc EntityNPC
function terrifyingPhysiognomy:onNpcInit(npc)
    if npc:IsEnemy() and npc:IsActiveEnemy() then
        npc.MaxHitPoints = npc.MaxHitPoints * (1 - healthReducePrecent)
        npc.HitPoints = npc.MaxHitPoints
    end
end

function terrifyingPhysiognomy:addCallbacks()
    if not callbacksActive then
        mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, terrifyingPhysiognomy.onNpcInit)
        callbacksActive = true
    end
end

function terrifyingPhysiognomy:removeCallbacks()
    if callbacksActive then
        mod:RemoveCallback(ModCallbacks.MC_POST_NPC_INIT, terrifyingPhysiognomy.onNpcInit)
        callbacksActive = false
    end
end

function terrifyingPhysiognomy:postGameEnd()
    Resouled:RemoveActiveBuff(Resouled.Buffs.TERRIFYING_PHYSIOGNOMY)
    terrifyingPhysiognomy:removeCallbacks()
end

local function postPlayerInit()
    if Resouled:ActiveBuffPresent(Resouled.Buffs.TERRIFYING_PHYSIOGNOMY) then
        terrifyingPhysiognomy:addCallbacks()
    end
end
mod:AddPriorityCallback(ModCallbacks.MC_POST_PLAYER_INIT, CallbackPriority.LATE, postPlayerInit)

mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, terrifyingPhysiognomy.removeCallbacks)
mod:AddCallback(ModCallbacks.MC_POST_GAME_END, terrifyingPhysiognomy.postGameEnd)

Resouled:AddBuffDescription(Resouled.Buffs.TERRIFYING_PHYSIOGNOMY,
"Reduces enemy health by 15%")