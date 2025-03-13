local WRATHS_SOUL_TYPE = Isaac.GetEntityTypeByName("Wrath's Soul")
local WRATHS_SOUL_VARIANT = Isaac.GetEntityVariantByName("Wrath's Soul")
local WRATHS_SOUL_SUBTYPE = 0

local NORMAL = true

---@param npc EntityNPC
local function onNpcInit(_, npc)
    if npc.Variant == WRATHS_SOUL_VARIANT and npc.SubType == WRATHS_SOUL_SUBTYPE then
        local sprite = npc:GetSprite()
        if NORMAL then
            sprite:ReplaceSpritesheet(0, "gfx/souls/wraths_soul_body_normal.png")
            sprite:ReplaceSpritesheet(1, "gfx/souls/wraths_soul_head_normal.png")
            sprite:LoadGraphics()
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_INIT, onNpcInit, WRATHS_SOUL_TYPE)

---@param npc EntityNPC
local function onNpcUpdate(_, npc)
    if npc.Variant == WRATHS_SOUL_VARIANT and npc.SubType == WRATHS_SOUL_SUBTYPE then
        local sprite = npc:GetSprite()

    end
end
Resouled:AddCallback(ModCallbacks.MC_NPC_UPDATE, onNpcUpdate, WRATHS_SOUL_TYPE)