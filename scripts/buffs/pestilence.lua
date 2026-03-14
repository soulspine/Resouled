local charmChance = 0.5

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
local function onNpcInit(npc)
    if RNG(npc.InitSeed):RandomFloat() < charmChance and enemiesWhitelist[makeLookupKey(npc.Type, npc.Variant, npc.SubType)] then
        npc:AddCharmed(EntityRef(nil), -1)
        npc:AddEntityFlags(EntityFlag.FLAG_PERSISTENT)
    end
end

Resouled:AddBuffToRemoveOnRunEnd(Resouled.Buffs.PESTILENCE, true)

Resouled:AddBuffCallbackConfig(Resouled.Buffs.PESTILENCE, {
    {
        CallbackID = ModCallbacks.MC_POST_NPC_INIT,
        Function = onNpcInit
    }
})