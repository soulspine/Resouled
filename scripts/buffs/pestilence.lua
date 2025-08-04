local pestilence = {}
local mod = Resouled
local callbacksActive = false

pestilence.CharmChance = 0.5

local enemiesWhitelist = {}

---@param param1 integer
---@param param2 integer
---@param param3 integer
local function makeLookupKey(param1, param2, param3)
    return tostring(param1).." "..tostring(param2).." "..tostring(param3)
end

---@param id EntityType
---@param variant integer
---@param subType integer
local function whitelistEnemy(id, variant, subType)
    enemiesWhitelist[makeLookupKey(id, variant, subType)] = true
end

whitelistEnemy(EntityType.ENTITY_MAGGOT, 0, 0)
whitelistEnemy(EntityType.ENTITY_CHARGER, 0, 0)
whitelistEnemy(EntityType.ENTITY_CHARGER, 1, 0)
whitelistEnemy(EntityType.ENTITY_CHARGER, 2, 0)
whitelistEnemy(EntityType.ENTITY_CHARGER, 3, 0)
whitelistEnemy(EntityType.ENTITY_SPITTY, 0, 0)
whitelistEnemy(EntityType.ENTITY_SPITTY, 1, 0)
whitelistEnemy(EntityType.ENTITY_CONJOINED_SPITTY, 0, 0)
whitelistEnemy(EntityType.ENTITY_SMALL_MAGGOT, 0, 0)
whitelistEnemy(EntityType.ENTITY_CHARGER_L2, 0, 0)
whitelistEnemy(EntityType.ENTITY_ADULT_LEECH, 0, 0)
whitelistEnemy(EntityType.ENTITY_SMALL_LEECH, 0, 0)

---@param npc EntityNPC
function pestilence:onNpcInit(npc)
    if RNG(npc.InitSeed):RandomFloat() < pestilence.CharmChance and enemiesWhitelist[makeLookupKey(npc.Type, npc.Variant, npc.SubType)] then
        npc:AddCharmed(EntityRef(nil), -1)
        npc:AddEntityFlags(EntityFlag.FLAG_PERSISTENT)
    end
end

function pestilence:onGameEnd()
    if Resouled:ActiveBuffPresent(Resouled.Buffs.PESTILENCE) then
        Resouled:RemoveActiveBuff(Resouled.Buffs.PESTILENCE)
        pestilence:removeCallbacks()
    end
end

function pestilence:preGameExit()
    pestilence:removeCallbacks()
end


function pestilence:addCallbacks()
    if not callbacksActive then
        mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, pestilence.onNpcInit)
        mod:AddCallback(ModCallbacks.MC_POST_GAME_END, pestilence.onGameEnd)
        mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, pestilence.preGameExit)
        callbacksActive = true
    end
end

function pestilence:removeCallbacks()
    if callbacksActive then
        mod:RemoveCallback(ModCallbacks.MC_POST_NPC_INIT, pestilence.onNpcInit)
        mod:RemoveCallback(ModCallbacks.MC_POST_GAME_END, pestilence.onGameEnd)
        mod:RemoveCallback(ModCallbacks.MC_PRE_GAME_EXIT, pestilence.preGameExit)
        callbacksActive = false
    end
end


local function postPlayerInit()
    if Resouled:ActiveBuffPresent(Resouled.Buffs.PESTILENCE) then
        pestilence:addCallbacks()
    else
        pestilence:removeCallbacks()
    end
end
mod:AddPriorityCallback(ModCallbacks.MC_POST_PLAYER_INIT, CallbackPriority.LATE, postPlayerInit)

Resouled:AddBuffDescription(Resouled.Buffs.PESTILENCE, Resouled.EID:AutoIcons("All maggot enemies have 50% chance to become charmed"))