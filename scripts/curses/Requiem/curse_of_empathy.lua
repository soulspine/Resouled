local mapId = Resouled.CursesMapId[Resouled.Curses.CURSE_OF_EMPATHY]

MinimapAPI:AddMapFlag(
    mapId,
    function()
        return Resouled:CustomCursePresent(Resouled.Curses.CURSE_OF_EMPATHY)
    end,
    Resouled.CursesSprite,
    mapId,
    1
)

local BASE_FEAR_TIME = 1

---@param entity Entity
---@param amount integer
---@param flags DamageFlag
---@param source EntityRef
---@param countdown integer
local function entityTakeDamage(_, entity, amount, flags, source, countdown)
    if Resouled:CustomCursePresent(Resouled.Curses.CURSE_OF_EMPATHY) then
        local player = Resouled:TryFindPlayerSpawner(source.Entity)

        if entity.HitPoints - amount <= 0 and entity:IsActiveEnemy() and player then
            player:AddFear(EntityRef(entity), math.floor(BASE_FEAR_TIME * player.MaxFireDelay))
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, entityTakeDamage)