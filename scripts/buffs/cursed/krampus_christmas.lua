local function curseActive()
    return Resouled:ActiveBuffPresent(Resouled.Buffs.KRAMPUS_CHRISTMAS) or Resouled:IsSpecialSeedEffectActive(Resouled.SpecialSeedEffects.EverythingIsCursed)
end

---@return RoomConfigRoom
local function randomKrampusRoom(seed)
    local x = 2300 + RNG(seed):RandomInt(7)
    local roomDesc = RoomConfig.GetRandomRoom(1, false, StbType.SPECIAL_ROOMS, RoomType.ROOM_MINIBOSS, nil, x, x, nil, nil, nil, RoomSubType.MINIBOSS_KRAMPUS)

    return roomDesc
end


local CHANCE = 1/3
local SPRITESHEET = "gfx/grid/door_07_devilroomdoor.png"
local TARGET = "gfx/grid/door_01_normaldoor.png"

local function fixDoors()
    local room = Game():GetRoom()
    for i = 0, DoorSlot.NUM_DOOR_SLOTS - 1 do
        local door = room:GetDoor(i)
    
        if door then
            local sprite = door:GetSprite()
                
            for j = 0, sprite:GetLayerCount() - 1 do
                if sprite:GetLayer(j):GetSpritesheetPath():find(TARGET) then
                    sprite:ReplaceSpritesheet(j, SPRITESHEET, false)
                end
            end
            sprite:LoadGraphics()
        end
    end
end

local function postNewFloor()
    if not curseActive() then return end

    local level = Game():GetLevel()
    --if level:GetDevilAngelRoomRNG():PhantomFloat() < CHANCE then
    
    level:InitializeDevilAngelRoom(false, false)
    local room = level:GetRoomByIdx(GridRooms.ROOM_DEVIL_IDX)

    local desc = randomKrampusRoom(room.SpawnSeed)
    
    room.Data = desc

    local save = Resouled.SaveManager.GetRoomFloorSave(nil, nil, room.ListIndex)

    save.Krampus_Christmas = true
    --end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, postNewFloor)

local function postNewRoom()
    local room = Game():GetLevel():GetCurrentRoomDesc()
    local save = Resouled.SaveManager.GetRoomFloorSave(nil, nil, room.ListIndex)
    local room1 = Game():GetRoom()

    if save.Krampus_Christmas then
        room1:SetBackdropType(BackdropType.SHEOL, 1)
        fixDoors()
    end

    if room.Data.Type == RoomType.ROOM_BOSS then
        fixDoors()
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, postNewRoom)

local function clearAward()
    if Game():GetLevel():GetCurrentRoomDesc().Data.Type == RoomType.ROOM_BOSS then
        fixDoors()
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_ROOM_TRIGGER_CLEAR, clearAward)