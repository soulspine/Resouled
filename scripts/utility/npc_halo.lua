---@class NpcHaloModule
local npcHalo = {}

local MOD = Resouled

--- Adds a following halo to the specified npc. Returns the halo entity or `nil` if it could not be spawned.
---@param npc EntityNPC
---@param haloSubtype integer
---@param scale Vector
---@param offset Vector
---@return EntityEffect | nil
function npcHalo:AddHaloToNpc(npc, haloSubtype, scale, offset)
    local haloEntity = Game():Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HALO, npc.Position, Vector(0, 0), npc, haloSubtype, 0)
    local halo = haloEntity:ToEffect()

    if not halo then
        return nil
    end

    halo.Parent = npc
    halo.SpriteScale = scale
    npc:GetData().Halo = halo
    halo:GetData().Offset = offset
    return halo
end

-- DO NOT TOUCH THIS UNLESS CHANGING SOMETHING IN AddHaloToNpc
MOD:AddCallback(ModCallbacks.MC_NPC_UPDATE,
---@param npc EntityNPC
function(_, npc)
    local data = npc:GetData()
    if data.Halo then
        ---@type EntityEffect
        local halo = data.Halo
        halo.Position = halo.Parent.Position + halo:GetData().Offset
    end
end)

--- Removes the halo from the specified npc.
function npcHalo:RemoveHaloFromNpc(npc)
    local data = npc:GetData()
    if data.Halo then
        data.Halo:Remove()
        data.Halo = nil
    end
end

return npcHalo