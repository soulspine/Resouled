Resouled.StatTracker = {}
Resouled.StatTracker.CursedEnemies = {}

---@return table
function Resouled.StatTracker:GetSave()
    if Resouled.SaveManager.IsLoaded() then
        local save = Resouled.SaveManager.GetPersistentSave()
        if not save then save = {} end
        if not save["ResouledStatTracker"] then save["ResouledStatTracker"] = {} end
        return save["ResouledStatTracker"]
    end
    return table
end

---@enum ResouledStatTrackerFields
Resouled.StatTracker.Fields = {
    CursedEnemiesKilled = "Cursed Enemies Killed",
    SoulsCollected = "Souls Collected",
    BuffsPickedUp = "Buffs Picked Up",
    RoomEventsEncountered = "Room Events Encountered",
}

Resouled.StatTracker.FiledsSorted = {
    [1] = Resouled.StatTracker.Fields.CursedEnemiesKilled,
    [2] = Resouled.StatTracker.Fields.SoulsCollected,
    [3] = Resouled.StatTracker.Fields.BuffsPickedUp,
    [4] = Resouled.StatTracker.Fields.RoomEventsEncountered
}

---@param id integer
---@param variant integer
---@param subType integer
function Resouled.StatTracker:RegisterCursedEnemy(id, variant, subType)
    Resouled.StatTracker.CursedEnemies[tostring(id) .. " " .. tostring(variant) .. " " .. tostring(subType)] = true
end

---@param npc EntityNPC
local function postNpcDeath(_, npc)
    local key = tostring(npc.Type) .. " " .. tostring(npc.Variant) .. " " .. tostring(npc.SubType)
    if Resouled.StatTracker.CursedEnemies[key] then
        local save = Resouled.StatTracker:GetSave()
        if not save[Resouled.StatTracker.Fields.CursedEnemiesKilled] then save[Resouled.StatTracker.Fields.CursedEnemiesKilled] = 0 end
        save[Resouled.StatTracker.Fields.CursedEnemiesKilled] = save[Resouled.StatTracker.Fields.CursedEnemiesKilled] + 1
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, postNpcDeath)
