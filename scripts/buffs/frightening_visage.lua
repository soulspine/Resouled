local frighteningVisage = {}
local callbacksActive = false
local mod = Resouled

local healthReducePrecent = 0.1

---@param npc EntityNPC
function frighteningVisage:onNpcInit(npc)
    if npc:IsEnemy() and npc:IsActiveEnemy() then
        npc.MaxHitPoints = npc.MaxHitPoints * (1 - healthReducePrecent)
        npc.HitPoints = npc.MaxHitPoints
    end
end

function frighteningVisage:addCallbacks()
    if not callbacksActive then
        mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, frighteningVisage.onNpcInit)
        callbacksActive = true
    end
end

function frighteningVisage:removeCallbacks()
    if callbacksActive then
        mod:RemoveCallback(ModCallbacks.MC_POST_NPC_INIT, frighteningVisage.onNpcInit)
        callbacksActive = false
    end
end

function frighteningVisage:postGameEnd()
    Resouled:RemoveActiveBuff(Resouled.Buffs.TERRIFYING_PHYSIOGNOMY)
    frighteningVisage:removeCallbacks()
end

local function postPlayerInit()
    if Resouled:ActiveBuffPresent(Resouled.Buffs.FRIGHTENING_VISAGE) then
        frighteningVisage:addCallbacks()
    end
end
mod:AddPriorityCallback(ModCallbacks.MC_POST_PLAYER_INIT, CallbackPriority.LATE, postPlayerInit)

mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, frighteningVisage.removeCallbacks)
mod:AddCallback(ModCallbacks.MC_POST_GAME_END, frighteningVisage.postGameEnd)