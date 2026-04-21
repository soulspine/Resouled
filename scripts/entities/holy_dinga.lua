local HOLY_DINGA = {
    Type = Isaac.GetEntityTypeByName("Holy Dinga"),
    Variant = Isaac.GetEntityVariantByName("Holy Dinga"),
    SubType = Isaac.GetEntitySubTypeByName("Holy Dinga")
}

---@param npc EntityNPC
local function postUpdate(_, npc)
    if not Resouled:MatchesEntityDesc(npc, HOLY_DINGA) then return end

    local sprite = npc:GetSprite()

    if sprite:IsEventTriggered("ResouledAttack") then
        
    end
end
Resouled:AddCallback(ModCallbacks.MC_NPC_UPDATE, postUpdate, HOLY_DINGA.Type)


local holySquirt = Resouled:GetEntityByName("Holy Squirt")
local SPAWN_OFFSET = Vector(20, 0)
---@param npc Entity
---@param am number
local function entityTakeDMG(_, npc, am)
    if not Resouled:MatchesEntityDesc(npc, HOLY_DINGA) then return end

    if npc.HitPoints <= am then
        
        local pos = npc.Position

        Resouled.Game:Spawn(holySquirt.Type, holySquirt.Variant, pos + SPAWN_OFFSET, Vector.Zero, npc, holySquirt.SubType, Resouled:NewSeed())
        Resouled.Game:Spawn(holySquirt.Type, holySquirt.Variant, pos - SPAWN_OFFSET, Vector.Zero, npc, holySquirt.SubType, Resouled:NewSeed())
        
        npc:Remove()
    end
end
Resouled:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, entityTakeDMG)