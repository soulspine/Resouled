local FLY_TYPE = Isaac.GetEntityTypeByName("Blank Canvas Fly")
local FLY_VARIANT = Isaac.GetEntityVariantByName("Blank Canvas Fly")

local VELOCITY_MULTIPLIER = 0.75

---@param npc EntityNPC
local function postNpcInit(_, npc)
    if npc.Variant == FLY_VARIANT then
        npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
        npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_INIT, postNpcInit, FLY_TYPE)

---@param npc EntityNPC
local function npcUpdate(_, npc)
    if npc.Variant == FLY_VARIANT then
        npc.Pathfinder:MoveRandomly(false)
        npc.Velocity = (npc.Velocity + (npc:GetPlayerTarget().Position - npc.Position):Normalized()) * VELOCITY_MULTIPLIER
    end
end
Resouled:AddCallback(ModCallbacks.MC_NPC_UPDATE, npcUpdate, FLY_TYPE)