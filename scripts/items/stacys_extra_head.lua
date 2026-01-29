local CONFIG = {
    Pool = Isaac.GetPoolIdByName("Resouled_stacyHeadPool"),
    DefaultItem = CollectibleType.COLLECTIBLE_SAD_ONION,
}

local CONSTANTS = {
    Item = Resouled.Enums.Items.STACYS_EXTRA_HEAD,
    TileMoveDistance = Vector(200, 0),
}

---@param pickup EntityPickup
local function onPickupFirstUpdate(_, pickup)
    if pickup.FrameCount ~= 1 then return end

    local room = Game():GetRoom()
    if not (room:GetType() == RoomType.ROOM_BOSS or room:GetType() == RoomType.ROOM_BOSSRUSH) or
        not room:IsClear() or
        not PlayerManager.AnyoneHasCollectible(CONSTANTS.Item) then
        return
    end

    local g = Game()
    local roomSave = Resouled.SaveManager.GetRoomFloorSave()
    if roomSave.Stacy_Head_Proc_Done then return end

    roomSave.Stacy_Head_Proc_Done = true

    local originalPos = pickup.Position
    local originalGridIndex = room:GetGridIndex(originalPos)

    local gridToTheLeftPos = room:GetGridPosition(originalGridIndex - 1)
    local gridToTheRightPos = room:GetGridPosition(originalGridIndex + 1)

    pickup.TargetPosition = room:FindFreePickupSpawnPosition(gridToTheLeftPos)
    pickup:Update()

    local selectionId = pickup.OptionsPickupIndex == 0 and pickup:SetNewOptionsPickupIndex()
        or pickup.OptionsPickupIndex

    local newItem = g:GetItemPool():GetCollectible(
        CONFIG.Pool,
        nil,
        pickup.InitSeed,
        CONFIG.DefaultItem
    )

    g:Spawn(
        EntityType.ENTITY_PICKUP,
        PickupVariant.PICKUP_CHEST,
        room:FindFreePickupSpawnPosition(originalPos),
        Vector.Zero,
        nil,
        0,
        pickup.InitSeed
    )

    if newItem == CONFIG.DefaultItem then return end

    local newPickup = g:Spawn(
        EntityType.ENTITY_PICKUP,
        PickupVariant.PICKUP_COLLECTIBLE,
        room:FindFreePickupSpawnPosition(gridToTheRightPos),
        Vector.Zero,
        nil,
        newItem,
        Resouled:NewSeed()
    ):ToPickup()

    if newPickup then
        newPickup.OptionsPickupIndex = selectionId
    end

    local pickupData = Resouled.SaveManager.GetRoomFloorSave(newPickup).RerollSave
    pickupData.Stacy_Head_Delete = true
end
Resouled:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, onPickupFirstUpdate, PickupVariant.PICKUP_COLLECTIBLE)

---@param pickup EntityPickup
---@param collider Entity
---@param low boolean
local function onPickupContact(_, pickup, collider, low)
    local player = collider:ToPlayer()
    if not player then return end

    local pickupData = Resouled.SaveManager.GetRoomFloorSave(pickup).RerollSave
    if not pickupData.Stacy_Head_Delete then return end
    local deleted = false
    Resouled.Iterators:IterateOverPlayers(function(player)
        if not deleted and player:HasCollectible(CONSTANTS.Item) then
            player:RemoveCollectible(CONSTANTS.Item)
            deleted = true
        end
    end)
end
Resouled:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, onPickupContact)
