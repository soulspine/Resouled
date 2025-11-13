local mapId = Resouled.CursesMapId[Resouled.Curses.CURSE_OF_AMNESIA]

MinimapAPI:AddMapFlag(
    mapId,
    function()
        return Resouled:CustomCursePresent(Resouled.Curses.CURSE_OF_AMNESIA)
    end,
    Resouled.CursesSprite,
    mapId,
    1
)

local pickupsBlacklist = {
    [PickupVariant.PICKUP_BED] = true,
    [PickupVariant.PICKUP_BIGCHEST] = true,
    [PickupVariant.PICKUP_SHOPITEM] = true,
    [PickupVariant.PICKUP_TROPHY] = true,
}

local function preRoomExit()
    if Resouled:CustomCursePresent(Resouled.Curses.CURSE_OF_AMNESIA) then
        local RoomSave = Resouled.SaveManager.GetRoomFloorSave()
        if not RoomSave.CurseOfAmnesia then
            RoomSave.CurseOfAmnesia = {
                Pickups = {},
                Grid = {}
            }
        end
        
        ---@param pickup EntityPickup
        Resouled.Iterators:IterateOverRoomPickups(function(pickup)
            if not pickupsBlacklist[pickup.Variant] or (pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE and pickup.SubType ~= 0) then
                if math.random() < Resouled.Stats.CurseOfAmnesia.DisappearChance then
                    local pickupSave = {
                        Variant = pickup.Variant,
                        SubType = pickup.SubType,
                        InitSeed = pickup.InitSeed,
                        Position = pickup.Position,
                    }
                    RoomSave.CurseOfAmnesia.Pickups[tostring(pickup.InitSeed)] = pickupSave
                    pickup:Remove()
                end
            end
        end)
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_ROOM_EXIT, preRoomExit)

local function postNewRoom()
    local RoomSave = Resouled.SaveManager.GetRoomFloorSave()
    if RoomSave.CurseOfAmnesia then

        if RoomSave.CurseOfAmnesia.Pickups then
            for k, pickupSave in pairs(RoomSave.CurseOfAmnesia.Pickups) do

                if pickupSave and
                pickupSave.Variant and
                pickupSave.SubType and
                pickupSave.InitSeed and
                pickupSave.Position then
                    
                    local randomFloat = math.random()
                    
                    if randomFloat < Resouled.Stats.CurseOfAmnesia.AppearChance then
                        local pickup = Game():Spawn(EntityType.ENTITY_PICKUP, pickupSave.Variant, pickupSave.Position, Vector.Zero, nil, pickupSave.SubType, pickupSave.InitSeed)
                        pickup:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                        RoomSave.CurseOfAmnesia.Pickups[k] = nil
                    end
                end
            end
        end

    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, postNewRoom)