local scaryFace = {}
local callbacksActive = false
local mod = Resouled

local healthReducePrecent = 0.05

---@param npc EntityNPC
function scaryFace:onNpcInit(npc)
    if npc:IsEnemy() and npc:IsActiveEnemy() then
        npc.MaxHitPoints = npc.MaxHitPoints * (1 - healthReducePrecent)
        npc.HitPoints = npc.MaxHitPoints
    end
end

function scaryFace:addCallbacks()
    if not callbacksActive then
        mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, scaryFace.onNpcInit)
        callbacksActive = true
    end
end

function scaryFace:removeCallbacks()
    if callbacksActive then
        mod:RemoveCallback(ModCallbacks.MC_POST_NPC_INIT, scaryFace.onNpcInit)
        callbacksActive = false
    end
end

function scaryFace:postGameEnd()
    Resouled:RemoveActiveBuff(Resouled.Buffs.TERRIFYING_PHYSIOGNOMY)
    scaryFace:removeCallbacks()
end

local function postPlayerInit()
    if Resouled:ActiveBuffPresent(Resouled.Buffs.SCARY_FACE) then
        scaryFace:addCallbacks()
    end
end
mod:AddPriorityCallback(ModCallbacks.MC_POST_PLAYER_INIT, CallbackPriority.LATE, postPlayerInit)

mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, scaryFace.removeCallbacks)
mod:AddCallback(ModCallbacks.MC_POST_GAME_END, scaryFace.postGameEnd)

Resouled:AddBuffDescription(Resouled.Buffs.SCARY_FACE,
"Reduces enemy health by 5%")