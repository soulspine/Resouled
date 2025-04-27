local mapId = Resouled.CursesMapId[Resouled.Curses.CURSE_OF_TINY_HANDS]

MinimapAPI:AddMapFlag(
    mapId,
    function()
        return Resouled:CustomCursePresent(Resouled.Curses.CURSE_OF_TINY_HANDS)
    end,
    Resouled.CursesSprite,
    mapId,
    1
)

local PICKUP_BLACKLIST = {
    [PickupVariant.PICKUP_TAROTCARD] = true,
    [PickupVariant.PICKUP_PILL] = true,
}

local PICKUP_CHANCE = 0.001

---@param pickup EntityPickup
---@param collider Entity
local function prePickupCollision(_, pickup, collider)
    if Resouled:CustomCursePresent(Resouled.Curses.CURSE_OF_TINY_HANDS) then
        if collider.Type == EntityType.ENTITY_PLAYER then
            local randomNum = math.random()
            if PICKUP_BLACKLIST[pickup.Variant] and randomNum > PICKUP_CHANCE then
                return false
            end
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, prePickupCollision)