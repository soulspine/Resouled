local SPLIT_CHANCE = 0.05

local mapId = Resouled.CursesMapId[Resouled.Curses.CURSE_OF_ENVY]

MinimapAPI:AddMapFlag(
    mapId,
    function()
        return Resouled:CustomCursePresent(Resouled.Curses.CURSE_OF_ENVY)
    end,
    Resouled.CursesSprite,
    mapId,
    1
)

---@param entity Entity
---@param amount integer
---@param flags DamageFlag
---@param source EntityRef
---@param countdown integer
local function entityTakeDamage(_, entity, amount, flags, source, countdown)
    local npc = entity:ToNPC()
    if npc and Resouled:CustomCursePresent(Resouled.Curses.CURSE_OF_ENVY) and entity:IsActiveEnemy() and (entity.HitPoints - amount) <= 0  then
        local rng = npc:GetDropRNG()
        if rng:RandomFloat() < SPLIT_CHANCE then
            npc:TrySplit(0, source, false)
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, entityTakeDamage)