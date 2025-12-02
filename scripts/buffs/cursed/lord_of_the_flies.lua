local BASE_CHANCE = 0.2
local CHANCE_PER_FLOOR = 0.1
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
    Game():Spawn(96, 0, en.Position, Vector.Zero, en, 0, Random())
end

---@param npc EntityNPC
local function onNpcInit(_, npc)

    if not Resouled:ActiveBuffPresent(Resouled.Buffs.LORD_OF_THE_FLIES) then return end

    if npc:IsEnemy() and npc:IsActiveEnemy() and RNG(npc.InitSeed):RandomFloat() < getCurrentChance() then
        for _ = 1, getFlyNum(npc.InitSeed) do
            attachFly(npc)
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_INIT, onNpcInit)

Resouled:AddBuffDescription(Resouled.Buffs.LORD_OF_THE_FLIES, "Enemies have a chance to have eternal flies orbiting them //endl// The chance increases each floor")