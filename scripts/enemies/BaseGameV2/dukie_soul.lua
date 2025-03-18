local DUKIE_SOUL_TYPE = Isaac.GetEntityTypeByName("Dukie's Soul")
local DUKIE_SOUL_VARIANT = Isaac.GetEntityVariantByName("Dukie's Soul")

local NORMAL = true

---@param npc EntityNPC
local function onNpcInit(_, npc)
    if npc.Variant == DUKIE_SOUL_VARIANT then
        local sprite = npc:GetSprite()
        if NORMAL then
            sprite:ReplaceSpritesheet(0, "gfx/souls/dukie_soul_normal.png")
            sprite:LoadGraphics()
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_INIT, onNpcInit, DUKIE_SOUL_TYPE)