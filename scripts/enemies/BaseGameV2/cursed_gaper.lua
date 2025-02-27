local CURSED_GAPER_VARIANT = Isaac.GetEntityVariantByName("Cursed Gaper")
local CURSED_GAPER_TYPE = Isaac.GetEntityTypeByName("Cursed Gaper")
local HALO_SUBTYPE = 3

local HALO_OFFSET = Vector(0, -15)
local HALO_SCALE = Vector(1.5, 1.5)

---@param npc EntityNPC
local function onNpcInit(_, npc)
    if npc.Variant == CURSED_GAPER_VARIANT then
        Resouled:AddHaloToNpc(npc, HALO_SUBTYPE, HALO_SCALE, HALO_OFFSET)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_INIT, onNpcInit, CURSED_GAPER_TYPE)