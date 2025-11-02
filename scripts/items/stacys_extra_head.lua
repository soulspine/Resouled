local CONFIG = {
    Pool = Isaac.GetPoolIdByName("stacyHeadPool"),
}

local CONSTANTS = {
    Item = Resouled.Enums.Items.STACYS_EXTRA_HEAD
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
    local roomSave = SAVE_MANAGER.GetRoomFloorSave()
    if roomSave.Stacy_Head_Proc_Done then return end

    roomSave.Stacy_Head_Proc_Done = true

    local selectionId = pickup.OptionsPickupIndex == 0 and pickup:SetNewOptionsPickupIndex()
        or pickup.OptionsPickupIndex

    local defaultItem = CollectibleType.COLLECTIBLE_SAD_ONION

    local newItem = g:GetItemPool():GetCollectible(
        CONFIG.Pool,
        nil,
        pickup.InitSeed,
        defaultItem
    )

    local chest = g:Spawn(
        EntityType.ENTITY_PICKUP,
        PickupVariant.PICKUP_CHEST,
        room:FindFreePickupSpawnPosition(pickup.Position),
        Vector.Zero,
        nil,
        0,
        pickup.InitSeed
    ):ToPickup()

    if chest then
        chest.OptionsPickupIndex = selectionId
    end

    if newItem == defaultItem then return end

    local newPickup = g:Spawn(
        EntityType.ENTITY_PICKUP,
        PickupVariant.PICKUP_COLLECTIBLE,
        room:FindFreePickupSpawnPosition(pickup.Position),
        Vector.Zero,
        nil,
        newItem,
        Resouled:NewSeed()
    ):ToPickup()

    if newPickup then
        newPickup.OptionsPickupIndex = selectionId
    end

    local pickupData = SAVE_MANAGER.GetRoomFloorSave(newPickup).RerollSave
    pickupData.Stacy_Head_Delete = true
end
Resouled:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, onPickupFirstUpdate, PickupVariant.PICKUP_COLLECTIBLE)

---@param pickup EntityPickup
---@param collider Entity
---@param low boolean
local function onPickupContact(_, pickup, collider, low)
    local player = collider:ToPlayer()
    if not player then return end

    local pickupData = SAVE_MANAGER.GetRoomFloorSave(pickup).RerollSave
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
