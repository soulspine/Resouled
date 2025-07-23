local game = Game()

local Door = {
    Type = Isaac.GetEntityTypeByName("ResouledDoor"),
    Variant = Isaac.GetEntityVariantByName("ResouledDoor"),
    SubType = Isaac.GetEntitySubTypeByName("ResouledDoor"),
}

---@param integer integer
---@return string
local function makeLookupKey(integer)
    return tostring(math.floor(integer + 0.5))
end

---@param type AfterlifeShopRoomType
local function setRoomType(type)
    return type
end

---@param index integer
---@return boolean
local function roomExists(index)
    local RunSave = SAVE_MANAGER.GetRunSave()
    return RunSave.AfterlifeShop and RunSave.AfterlifeShop["LevelLayout"] and RunSave.AfterlifeShop["LevelLayout"][makeLookupKey(index)] and RunSave.AfterlifeShop["LevelLayout"][makeLookupKey(index)] > 0
end

---@param currentIndex integer
---@param dir Direction
---@return integer
local function moveAroundMap(currentIndex, dir)
    local RunSave = SAVE_MANAGER.GetRunSave()
    if RunSave.AfterlifeShop and RunSave.AfterlifeShop["LevelLayout"] then

        local newIndex = Resouled:GetRoomIdxFromDir(dir, currentIndex)
        
        if newIndex and not roomExists(newIndex) then
            return newIndex
        elseif not newIndex or (newIndex and roomExists(newIndex)) then
            local freeSpot = nil
            local i = 0
            while i < 4 and not freeSpot do
                local newIndex2 = Resouled:GetRoomIdxFromDir(i, currentIndex)
                if newIndex2 and not roomExists(newIndex2) then
                    freeSpot = newIndex2
                end
                i = i + 1
            end
            if freeSpot then
                return freeSpot
            end
        else
            return currentIndex
        end
    end
    return currentIndex
end

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
        npc:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS)
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
    local RunSave = SAVE_MANAGER.GetRunSave()
    local nearestRoom = Resouled:GetNearestRoomIndexAndDirectionFromPos(position)
    if nearestRoom and RunSave.AfterlifeShop and RunSave.AfterlifeShop["LevelLayout"] and RunSave.AfterlifeShop["LevelLayout"][makeLookupKey(nearestRoom.RoomIndex)] and RunSave.AfterlifeShop["LevelLayout"][makeLookupKey(nearestRoom.RoomIndex)] > 0 then
        local door = game:Spawn(Door.Type, Door.Variant, position, Vector.Zero, nil, Door.SubType, Isaac.GetFrameCount())
        door.SizeMulti = Vector(1, 0.001)
        door.SpriteRotation = -90 + (90 * doorSlot)
    end
end

local function spawnDoors()
    local RunSave = SAVE_MANAGER.GetRunSave()
    if RunSave.AfterlifeShop then
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
end

local function postNewRoom()
    if Resouled.AfterlifeShop:IsAfterlifeShop() then
        spawnDoors()
    end
end
Resouled:AddPriorityCallback(ModCallbacks.MC_POST_NEW_ROOM, CallbackPriority.LATE, postNewRoom)

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
    local RunSave = SAVE_MANAGER.GetRunSave()
    if Resouled.AfterlifeShop:IsAfterlifeShop() then
        local level = game:GetLevel()
        
        RunSave.AfterlifeShop["LevelLayout"] = {}
        local layout = RunSave.AfterlifeShop["LevelLayout"]

        for i = 0, 12 do
            for j = 0, 12 do
                
                local levelGen = Isaac.LevelGeneratorEntry()
                levelGen:SetColIdx(i)
                levelGen:SetLineIdx(j)
                levelGen:SetAllowedDoors(4)
                
                local roomConfig = RoomConfigHolder.GetRandomRoom(1, false, StbType.CHEST, RoomType.ROOM_DEFAULT, RoomShape.ROOMSHAPE_1x1, nil, nil, nil, nil, 4)
                
                level:PlaceRoom(levelGen, roomConfig, 1)

                local roomIdx = 13 * i + j

                layout[makeLookupKey(roomIdx)] = setRoomType(Resouled.AfterlifeShop.RoomTypes.None)
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

        local currentIndex = level:GetCurrentRoomIndex()

        --Generate the afterlife shop layout

        --Placeholder generator (example how it to make rooms)
        layout[makeLookupKey(currentIndex)] = setRoomType(Resouled.AfterlifeShop.RoomTypes.MainShop)


        local roomCount = 0
        local failedCount = 0

        ::generate::
        currentIndex = moveAroundMap(currentIndex, math.random(0, 3))

        if not roomExists(currentIndex) then
            roomCount = roomCount + 1
            layout[makeLookupKey(currentIndex)] = setRoomType(math.random(2, 3))
        else
            failedCount = failedCount + 1
        end

        if failedCount < 2 and roomCount < 100 then
            goto generate
        end

        spawnDoors()
        --Finished
        
        level:Update()
    end
end
Resouled:AddPriorityCallback(ModCallbacks.MC_POST_NEW_LEVEL, CallbackPriority.LATE, postFloorGenerate)

Resouled:AddCallback(ModCallbacks.MC_PRE_LEVEL_PLACE_ROOM, function()
    local RunSave = SAVE_MANAGER.GetRunSave()
    if RunSave.AfterlifeShopNext then
        RunSave.AfterlifeShop = {}
        RunSave.AfterlifeShopNext = nil
    end

    if Resouled.AfterlifeShop:IsAfterlifeShop() then
        local roomConfig = RoomConfigHolder.GetRandomRoom(1, false, StbType.CHEST, RoomType.ROOM_DEFAULT, RoomShape.ROOMSHAPE_1x1, nil, nil, nil, nil, 4)
        return roomConfig
    end
end)