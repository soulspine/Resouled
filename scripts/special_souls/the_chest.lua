local BLAST_RADIUS = 87
local DOOR_DETECTION_RADIUS = 50

---@param bomb EntityBomb
local function postBombUpdate(_, bomb)
    if bomb:GetExplosionCountdown() > 0 then
        return
    end
    ---@param entity Entity
    Resouled.Iterators:IterateOverRoomEntities(function(entity)
        local pickup = entity:ToPickup()
        if pickup and pickup.Position:Distance(bomb.Position) <= BLAST_RADIUS * bomb.RadiusMultiplier and pickup.Variant == PickupVariant.PICKUP_LOCKEDCHEST and pickup.SubType == ChestSubType.CHEST_CLOSED then
            if Resouled:TrySpawnSoulPickup(Resouled.Souls.THE_CHEST, pickup.Position) then
                pickup:TryOpenChest()
            end
        end
    end)
end
Resouled:AddCallback(ModCallbacks.MC_PRE_BOMB_UPDATE, postBombUpdate)

---@param pickup EntityPickup
local function onPickupUpdate(_, pickup)
    local open = false

    local closestDoor = Resouled.Doors:GetClosestDoor(pickup.Position)
    if closestDoor and closestDoor.TargetRoomType == RoomType.ROOM_CURSE and not closestDoor:IsLocked() and not closestDoor:IsBusted() and closestDoor.Position:Distance(pickup.Position) < DOOR_DETECTION_RADIUS then
        open = true
    end

    local gridEntity = Game():GetRoom():GetGridEntityFromPos(pickup.Position)
    if gridEntity then
        if gridEntity:GetType() == GridEntityType.GRID_SPIKES or gridEntity:GetType() == GridEntityType.GRID_ROCK_SPIKED or gridEntity:GetType() == GridEntityType.GRID_SPIKES_ONOFF then
            open = true
        end
    end

    if open then
        if Resouled:TrySpawnSoulPickup(Resouled.Souls.THE_CHEST, pickup.Position) then
            pickup:TryOpenChest()
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_PICKUP_UPDATE, onPickupUpdate, PickupVariant.PICKUP_LOCKEDCHEST)