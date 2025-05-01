local BLAST_RADIUS = 87
local DOOR_DETECTION_RADIUS = 50

---@param effect EntityEffect
local function onEffectInit(_, effect)
    if Resouled:WasSoulSpawned(Resouled.Souls.THE_CHEST) then
        return
    end

    ---@param entity Entity
    Resouled:IterateOverRoomEntities(function(entity)
        local pickup = entity:ToPickup()
        if pickup and pickup.Position:Distance(effect.Position) < BLAST_RADIUS and pickup.Variant == PickupVariant.PICKUP_LOCKEDCHEST then
            pickup:TryOpenChest()
            Resouled:TrySpawnSoulPickup(Resouled.Souls.THE_CHEST, pickup.Position)
        end
    end)
end
Resouled:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, onEffectInit, EffectVariant.BOMB_EXPLOSION)

---@param pickup EntityPickup
local function onPickupUpdate(_, pickup)
    if Resouled:WasSoulSpawned(Resouled.Souls.THE_CHEST) then
        return
    end

    local open = false

    local closestDoor = Resouled:GetClosestDoor(pickup.Position)
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
        pickup:TryOpenChest()
        Resouled:TrySpawnSoulPickup(Resouled.Souls.THE_CHEST, pickup.Position)
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_PICKUP_UPDATE, onPickupUpdate, PickupVariant.PICKUP_LOCKEDCHEST)