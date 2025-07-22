local game = Game()

local Door = {
    Type = Isaac.GetEntityTypeByName("ResouledDoor"),
    Variant = Isaac.GetEntityVariantByName("ResouledDoor"),
    SubType = Isaac.GetEntitySubTypeByName("ResouledDoor"),
}

---@return table
local function getDoorsPositions()
    local room = game:GetRoom()

    local topLeft = room:GetTopLeftPos()
    local bottomRight = room:GetBottomRightPos()

    local positions = {
        [1] = Vector(topLeft.X, (topLeft.Y + bottomRight.Y)/2),
        [2] = Vector((topLeft.X + bottomRight.X)/2, topLeft.Y),
        [3] = Vector(bottomRight.X, (topLeft.Y + bottomRight.Y)/2),
        [4] = Vector((topLeft.X + bottomRight.X)/2, bottomRight.Y)
    }

    return positions
end

---@param npc EntityNPC
local function postNpcInit(_, npc)
    if npc.Variant == Door.Variant and npc.SubType == Door.SubType then
        npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        npc:AddEntityFlags(EntityFlag.FLAG_FRIENDLY)
        npc:AddEntityFlags(EntityFlag.FLAG_NO_TARGET)
        npc:AddEntityFlags(EntityFlag.FLAG_NO_BLOOD_SPLASH)
        npc:AddEntityFlags(EntityFlag.FLAG_DONT_OVERWRITE)
        npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK)
        npc:AddEntityFlags(EntityFlag.FLAG_HIDE_HP_BAR)
        npc:AddEntityFlags(EntityFlag.FLAG_BACKDROP_DETAIL)
        npc.DepthOffset = -1000
        npc:GetSprite():Play("Idle", true)
        npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_INIT, postNpcInit, Door.Type)

---@param doorSlot DoorSlot
---@param position Vector
local function trySpawnDoor(doorSlot, position)
    if Resouled:GetNearestRoomIndexAndDirectionFromPos(position) then
        local door = game:Spawn(Door.Type, Door.Variant, position, Vector.Zero, nil, Door.SubType, Isaac.GetFrameCount())
        door.SizeMulti = Vector(1, 0.05)
        door.SpriteRotation = -90 + (90 * doorSlot)
    end
end

local function postNewRoom()
    local room = Game():GetRoom()
    local doorsPos = getDoorsPositions()
    for i = 0, DoorSlot.NUM_DOOR_SLOTS do
        local door = room:GetDoor(i)
        if door then
            room:RemoveDoor(i)

        end
        if i < 4 then
            trySpawnDoor(i, doorsPos[i + 1])
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, postNewRoom)

---@param npc EntityNPC
---@param collider Entity
local function onNpcCollision(_, npc, collider)
    if collider:ToPlayer() then
        local nearRoomTable = Resouled:GetNearestRoomIndexAndDirectionFromPos(npc.Position)
        if nearRoomTable then
            game:StartRoomTransition(nearRoomTable.RoomIndex, nearRoomTable.Direction, RoomTransitionAnim.WALK)
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_COLLISION, onNpcCollision, Door.Type)

local function postFloorGenerate()
    local level = game:GetLevel()
    for i = 0, 12 do
        for j = 0, 12 do
                    
            local levelGen = Isaac.LevelGeneratorEntry()
            levelGen:SetColIdx(i)
            levelGen:SetLineIdx(j)
            levelGen:SetAllowedDoors(4)
                    
            local roomConfig = RoomConfigHolder.GetRandomRoom(1, false, StbType.CHEST, RoomType.ROOM_DEFAULT, RoomShape.ROOMSHAPE_1x1, nil, nil, nil, nil, 4)
                    
            level:PlaceRoom(levelGen, roomConfig, 1)
        end
    end
    local rooms = level:GetRooms()

    for i = 1, rooms.Size do
        local room = rooms:Get(i)

        if room then
            room.Clear = true
            room.DisplayFlags = RoomDescriptor.DISPLAY_NONE
        end
    end

    level:Update()
end
Resouled:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, postFloorGenerate)

Resouled:AddCallback(ModCallbacks.MC_PRE_LEVEL_PLACE_ROOM, function()
    local roomConfig = RoomConfigHolder.GetRandomRoom(1, false, StbType.CHEST, RoomType.ROOM_DEFAULT, RoomShape.ROOMSHAPE_1x1, nil, nil, nil, nil, 4)
    return roomConfig
end)