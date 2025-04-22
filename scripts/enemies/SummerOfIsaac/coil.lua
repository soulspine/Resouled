local COIL = Isaac.GetEntityTypeByName("Coil")

---@param npc EntityNPC
local function postNpcInit(_, npc)
    local sprite = npc:GetSprite()
    sprite:Play("Idle", true)
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_INIT, postNpcInit, COIL)

---@param npc EntityNPC
local function onNpcUpdate(_, npc)
    if npc:GetPlayerTarget().Position:Distance(npc.Position) > 100 then
        npc.Velocity = npc.Velocity*0.9 + (npc:GetPlayerTarget().Position - npc.Position)*0.005
    else
        npc.Velocity = npc.Velocity*1.1 + -(npc:GetPlayerTarget().Position - npc.Position)*0.001
    end
    npc.Pathfinder:EvadeTarget(npc:GetPlayerTarget().Position)
end
Resouled:AddCallback(ModCallbacks.MC_NPC_UPDATE, onNpcUpdate, COIL)