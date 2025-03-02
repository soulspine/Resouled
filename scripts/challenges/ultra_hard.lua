local ULTRA_HARD = Challenge.CHALLENGE_ULTRA_HARD
local BLOAT = Isaac.GetEntityTypeByName("#THE_BLOAT")

---@param entity EntityNPC
local function onEntityInit(_, entity)
    if Isaac.GetChallenge() == ULTRA_HARD then
        entity:Morph(BLOAT, 1, 0, 0)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_INIT, onEntityInit)