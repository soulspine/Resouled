local mapId = Resouled.CursesMapId[Resouled.Curses.CURSE_OF_LOSS]

local SOUL_LOSS_CHANCE = 0.1

MinimapAPI:AddMapFlag(
    mapId,
    function()
        return Resouled:CustomCursePresent(Resouled.Curses.CURSE_OF_LOSS)
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
    if entity.Type == EntityType.ENTITY_PLAYER and Resouled:CustomCursePresent(Resouled.Curses.CURSE_OF_LOSS) then
        local rng = RNG()
        rng:SetSeed(Resouled:NewSeed())
        if rng:RandomFloat() < SOUL_LOSS_CHANCE then
            Resouled:SetPossessedSoulsNum(Resouled:GetPossessedSoulsNum() - 1)
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, onPlayerHit, EntityType.ENTITY_PLAYER)