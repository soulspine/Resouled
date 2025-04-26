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

local FEAR_TIME = 10

---@param entity Entity
---@param amount integer
---@param flags DamageFlag
---@param source EntityRef
---@param countdown integer
local function entityTakeDamage(_, entity, amount, flags, source, countdown)
    if Resouled:CustomCursePresent(Resouled.Curses.CURSE_OF_EMPATHY) then
        if entity.HitPoints - amount <= 0 and source.Type == EntityType.ENTITY_PLAYER then
            source.Entity:ToPlayer():AddFear(EntityRef(entity), FEAR_TIME)
        end

        if entity.HitPoints - amount <= 0 and source.Entity.SpawnerEntity then
            if source.Entity.SpawnerEntity.Type == EntityType.ENTITY_PLAYER then
                source.Entity.SpawnerEntity:ToPlayer():AddFear(EntityRef(entity), FEAR_TIME)
            end
            
            if source.Entity.SpawnerEntity.SpawnerEntity then
                if source.Entity.SpawnerEntity.SpawnerEntity.Type == EntityType.ENTITY_PLAYER then
                    source.Entity.SpawnerEntity.SpawnerEntity:ToPlayer():AddFear(EntityRef(entity), FEAR_TIME)
                end
            end
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, entityTakeDamage)