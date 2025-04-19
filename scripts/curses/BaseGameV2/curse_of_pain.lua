local mapId = Resouled.CursesMapId[Resouled.Curses.CURSE_OF_PAIN]

MinimapAPI:AddMapFlag(
    mapId,
    function()
        return Resouled:CustomCursePresent(Resouled.Curses.CURSE_OF_PAIN)
    end,
    Resouled.CursesSprite,
    mapId,
    1
)

---@param entity Entity
---@param amount number
---@param flags integer
---@param source EntityRef
---@param countdown integer
local function onPlayerHit(_, entity, amount, flags, source, countdown)
    local entityData = entity:GetData()
    if entity.Type == EntityType.ENTITY_PLAYER and Resouled:CustomCursePresent(Resouled.Curses.CURSE_OF_PAIN) and amount == 1 and not entityData.ResouledCurseOfPainDamage then
        entityData.ResouledCurseOfPainDamage = true
        entity:TakeDamage(2, flags, source, countdown)
        return false
    end

    if entityData.ResouledCurseOfPainDamage then
        entityData.ResouledCurseOfPainDamage = false
    end
end
Resouled:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, onPlayerHit, EntityType.ENTITY_PLAYER)