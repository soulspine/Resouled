local RESOULED_DUMMY_TYPE = Isaac.GetEntityTypeByName("ResouledDummy")
local RESOULED_DUMMY_VARIANT = Isaac.GetEntityVariantByName("ResouledDummy")
local RESOULED_DUMMY_SUBTYPE = Isaac.GetEntitySubTypeByName("ResouledDummy")

---@param npc EntityNPC
local function postNpcInit(_, npc)
    if npc.Variant == RESOULED_DUMMY_VARIANT and npc.SubType == RESOULED_DUMMY_SUBTYPE then
        npc:Remove()
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_INIT, postNpcInit, RESOULED_DUMMY_TYPE)