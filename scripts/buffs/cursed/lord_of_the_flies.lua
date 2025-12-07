local BASE_CHANCE = 0.2
local CHANCE_PER_FLOOR = 0.1

local function curseActive()
    return Resouled:ActiveBuffPresent(Resouled.Buffs.LORD_OF_THE_FLIES) or Resouled:IsSpecialSeedEffectActive(Resouled.SpecialSeedEffects.EverythingIsCursed)
end

local getCurrentChance = function()
    return BASE_CHANCE + (CHANCE_PER_FLOOR * (Game():GetLevel():GetStage() - 1))
end

local getMaxFlies = function()
    return math.ceil(Game():GetLevel():GetStage()/6)
end

local getFlyNum = function(seed)
    return RNG(seed):RandomInt(1, getMaxFlies())
end

---@param en Entity
local attachFly = function(en)
    local fly = Game():Spawn(96, 0, en.Position, Vector.Zero, en, 0, Random())
    fly.Parent = en
end

---@param npc EntityNPC
local function onNpcInit(_, npc)

    if (not curseActive()) or (npc.Type == 96 and npc.Variant == 0 and npc.SubType == 0) then return end

    if Resouled:IsValidEnemy(npc) and RNG(npc.InitSeed):RandomFloat() < getCurrentChance() then
        for _ = 1, getFlyNum(npc.InitSeed) do
            attachFly(npc)
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_INIT, onNpcInit)

Resouled:AddBuffToRemoveOnRunEnd(Resouled.Buffs.LORD_OF_THE_FLIES)

Resouled:AddBuffDescription(Resouled.Buffs.LORD_OF_THE_FLIES, "Enemies have a chance to have eternal flies orbiting them //endl// The chance increases each floor")