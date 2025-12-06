local CHANCE = 0.1125

local function curseActive()
    return Resouled:ActiveBuffPresent(Resouled.Buffs.LIFE_OF_LUST) or Resouled:IsSpecialSeedEffectActive(Resouled.SpecialSeedEffects.EverythingIsCursed)
end

---@param npc EntityNPC
local function pair(npc)
    if npc:GetData().Resouled_LifeOfLustSplit then return end

    local posAdd = Vector(npc.Size/2, 0)
    npc.Position = npc.Position + posAdd

    local other = Game():Spawn(npc.Type, npc.Variant, npc.Position - posAdd, npc.Velocity, npc.SpawnerEntity, npc.SubType, Random())
    other:GetData().Resouled_LifeOfLustSplit = true
end

---@param npc EntityNPC
local function onNpcInit(_, npc)
    if not curseActive() or not (npc:IsEnemy() and npc:IsActiveEnemy()) or npc:IsBoss() then return end

    if RNG(npc.InitSeed):RandomFloat() < CHANCE then pair(npc) end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_INIT, onNpcInit)

Resouled:AddBuffToRemoveOnRunEnd(Resouled.Buffs.LIFE_OF_LUST)