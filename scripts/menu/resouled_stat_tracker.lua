Resouled.StatTracker = {}
Resouled.StatTracker.CursedEnemies = {}

---@return table
function Resouled.StatTracker:GetSave()
    local save = SAVE_MANAGER.GetPersistentSave()
    if not save then save = {} end
    if not save["ResouledStatTracker"] then save["ResouledStatTracker"] = {} end
    return save["ResouledStatTracker"]
end

---@param field ResouledStatTrackerFields
---@return any
function Resouled.StatTracker:GetSaveField(field)
    return Resouled.StatTracker:GetSave()[field]
end

---@enum ResouledStatTrackerFields
Resouled.StatTracker.Fields = {
    CursedEnemiesKilled = "CursedEnemiesKilled",
    SoulsCollected = "SoulsCollected",
    BuffsPickedUp = "BuffsPickedUp",
    RoomEventsEncountered = "RoomEventsEncountered",
}

---@param id integer
---@param variant integer
---@param subType integer
function Resouled.StatTracker:RegisterCursedEnemy(id, variant, subType)
    Resouled.StatTracker.CursedEnemies[tostring(id).." "..tostring(variant).." "..tostring(subType)] = true
end

---@param npc EntityNPC
local function postNpcDeath(_, npc)
    if Resouled.StatTracker.CursedEnemies[tostring(npc.Type)..tostring(npc.Variant)..tostring(npc.SubType)] then
        local save = Resouled.StatTracker:GetSaveField(Resouled.StatTracker.Fields.CursedEnemiesKilled)
        if not save then save = 0 end
        save = save + 1
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, postNpcDeath)