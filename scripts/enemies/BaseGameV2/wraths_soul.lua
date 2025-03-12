local WRATHS_SOUL_TYPE = Isaac.GetEntityTypeByName("Wrath's Soul")
local WRATHS_SOUL_VARIANT = Isaac.GetEntityVariantByName("Wrath's Soul")
local WRATHS_SOUL_SUBTYPE = 0

---@param npc EntityNPC
local function onNpcUpdate(_, npc)
    if npc.Variant == WRATHS_SOUL_VARIANT and npc.SubType == WRATHS_SOUL_SUBTYPE then
        
    end
end
Resouled:AddCallback(ModCallbacks.MC_NPC_UPDATE, onNpcUpdate, WRATHS_SOUL_TYPE)