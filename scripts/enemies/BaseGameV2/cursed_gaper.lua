local CURSED_GAPER_VARIANT = 4
local HALO_SUBTYPE = 3

local HALO_OFFSET = Vector(0, -15)
local HALO_SCALE = Vector(1.5, 1.5)

---@param npc EntityNPC
local function onNpcInit(_, npc)
    if npc.Variant == CURSED_GAPER_VARIANT then
        local entity = Game():Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HALO, npc.Position, Vector(0, 0), npc, HALO_SUBTYPE, 0)
        local halo = entity:ToEffect()
        halo.Parent = npc
        halo.SpriteScale = HALO_SCALE
        halo.ParentOffset = HALO_OFFSET
        npc:GetData().Halo = halo
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_INIT, onNpcInit, EntityType.ENTITY_GAPER)

---@param npc EntityNPC
local function preNpcUpdate(_, npc)
    if npc.Variant == CURSED_GAPER_VARIANT then
        ---@type EntityEffect
        local halo = npc:GetData().Halo
        if halo then
            --halo.Position = npc.Position + HALO_OFFSET
            halo.Position = npc.Position + HALO_OFFSET
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, preNpcUpdate, EntityType.ENTITY_GAPER)