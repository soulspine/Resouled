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

local LIGHT_PICKUPS = {
    [PickupVariant.PICKUP_BOMB] = true,
    [PickupVariant.PICKUP_COIN] = true,
    [PickupVariant.PICKUP_HEART] = true,
    [PickupVariant.PICKUP_KEY] = true,
    [PickupVariant.PICKUP_LIL_BATTERY] = true,
    [PickupVariant.PICKUP_POOP] = true,
}

local HEAVY_PICKUPS = {
    [PickupVariant.PICKUP_PILL] = true,
    [PickupVariant.PICKUP_TAROTCARD] =  true,
    [PickupVariant.PICKUP_TRINKET] = true,
}

local LIGHT_PICKUPS_PICKUP_LIMIT = 10 --coins, bombs, poop, keys, hearts
local HEAVY_PICKUPS_PICKUP_LIMIT = 5 --trinkets, runes, cards, pills
local PICKUP_LIMIT_TO_ADD_PER_PLAYER = 2

local function postUpdate()
    local floorSave = Resouled.SaveManager.GetFloorSave()
    if Resouled:CustomCursePresent(Resouled.Curses.CURSE_OF_TINY_HANDS) and not floorSave.CurseOfTinyHands then
        local extraPlayersNum = #PlayerManager.GetPlayers() - 1
        floorSave.CurseOfTinyHands = {
            Light = LIGHT_PICKUPS_PICKUP_LIMIT + PICKUP_LIMIT_TO_ADD_PER_PLAYER * extraPlayersNum,
            Heavy = HEAVY_PICKUPS_PICKUP_LIMIT + PICKUP_LIMIT_TO_ADD_PER_PLAYER * extraPlayersNum
        }
    elseif not Resouled:CustomCursePresent(Resouled.Curses.CURSE_OF_TINY_HANDS) and floorSave.CurseOfTinyHands then
        floorSave.CurseOfTinyHands = nil
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_UPDATE, postUpdate)

---@param pickup EntityPickup
---@param collider Entity
local function prePickupCollision(_, pickup, collider)
    local floorSave = Resouled.SaveManager.GetFloorSave()
    if floorSave.CurseOfTinyHands then
        if LIGHT_PICKUPS[pickup.Variant] then
            if floorSave.CurseOfTinyHands.Light > 0 then
                floorSave.CurseOfTinyHands.Light = floorSave.CurseOfTinyHands.Light - 1
            else
                return false
            end
        elseif HEAVY_PICKUPS[pickup.Variant] then
            if floorSave.CurseOfTinyHands.Heavy > 0 then
                floorSave.CurseOfTinyHands.Heavy = floorSave.CurseOfTinyHands.Heavy - 1
            else
                return false
            end
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, prePickupCollision)