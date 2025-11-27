local game = Game()

local Door = {
    Type = Isaac.GetEntityTypeByName("ResouledDoor"),
    Variant = Isaac.GetEntityVariantByName("ResouledDoor"),
    SubType = Isaac.GetEntitySubTypeByName("ResouledDoor"),

    Animations = {
        Open = "Idle",
        Locked = "Locked",
        Unlock = "Unlock",
        Events = {
            Sound = "Sound1",
            Flash = "Light"
        },
    },
    
    FlashFadeSpeed = 0.01,
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
    local RunSave = Resouled.SaveManager.GetRunSave()
    return RunSave.AfterlifeShop and RunSave.AfterlifeShop["LevelLayout"] and RunSave.AfterlifeShop["LevelLayout"][makeLookupKey(index)] and RunSave.AfterlifeShop["LevelLayout"][makeLookupKey(index)] > 0
end

---@param index integer
---@return boolean
local function isAnySpotAroundRoomFree(index)
    local RunSave = Resouled.SaveManager.GetRunSave()
    if RunSave.AfterlifeShop and RunSave.AfterlifeShop["LevelLayout"] and RunSave.AfterlifeShop["LevelLayout"][makeLookupKey(index)] then
        for i = 0, 3 do -- all directions
            if not Resouled:GetRoomIdxFromDir(i, index) then
                return true
            end
        end
    end
    return false
end

---@param currentIndex integer
---@param dir Direction
---@return integer
local function moveAroundMap(currentIndex, dir)
    if dir == Direction.NO_DIRECTION then
        dir = math.random(0, 3)
    end

    local RunSave = Resouled.SaveManager.GetRunSave()
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
        npc.DepthOffset = -100
        --npc:GetSprite():Play("Idle", true)
        npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_INIT, postNpcInit, Door.Type)

---@param position Vector
---@return boolean
local function ShouldDoorBeLocked(position)
    local RunSave = Resouled.SaveManager.GetRunSave()
    local nearestRoom = Resouled:GetNearestRoomIndexAndDirectionFromPos(position)
    if nearestRoom and RunSave.AfterlifeShop and RunSave.AfterlifeShop["LevelLayout"] and RunSave.AfterlifeShop["LevelLayout"][makeLookupKey(nearestRoom.RoomIndex)] and RunSave.AfterlifeShop["LevelLayout"][makeLookupKey(nearestRoom.RoomIndex)] > 0 then

        if RunSave.AfterlifeShop["LevelLayout"][makeLookupKey(nearestRoom.RoomIndex)] == (Resouled.AfterlifeShop.RoomTypes.SoulSanctum or Resouled.AfterlifeShop.RoomTypes.SpecialBuffsRoom) and not Resouled.AfterlifeShop:IsShuffleComplete()
        then
            return true
        end
    end
    return false
end

---@return boolean
function Resouled.AfterlifeShop:AreRoomsConnected(roomIdx1, roomIdx2)
    local RunSave = Resouled.SaveManager.GetRunSave()
    if RunSave.AfterlifeShop and RunSave.AfterlifeShop["LevelLayout"] and RunSave.AfterlifeShop["LevelLayout"][makeLookupKey(roomIdx2)] and RunSave.AfterlifeShop["LevelLayout"][makeLookupKey(roomIdx2)] > 0 then
        if (not Resouled.AfterlifeShop.SpecialBuffRoomsConnectionWhitelist[RunSave.AfterlifeShop["LevelLayout"][makeLookupKey(roomIdx1)]] and
        RunSave.AfterlifeShop["LevelLayout"][makeLookupKey(roomIdx2)] == Resouled.AfterlifeShop.RoomTypes.SpecialBuffsRoom) or
        (RunSave.AfterlifeShop["LevelLayout"][makeLookupKey(roomIdx1)] == Resouled.AfterlifeShop.RoomTypes.SpecialBuffsRoom and
        not Resouled.AfterlifeShop.SpecialBuffRoomsConnectionWhitelist[RunSave.AfterlifeShop["LevelLayout"][makeLookupKey(roomIdx2)]])
        then
            return false
        else
            return true
        end
    end
    return false
end

local DOOR_OFFSET = Vector(0, 4)

---@param doorSlot DoorSlot
---@param position Vector
local function trySpawnDoor(doorSlot, position)
    local RunSave = Resouled.SaveManager.GetRunSave()
    local nearestRoom = Resouled:GetNearestRoomIndexAndDirectionFromPos(position)
    local currentIndex = Game():GetLevel():GetCurrentRoomIndex()

    if nearestRoom and RunSave.AfterlifeShop and RunSave.AfterlifeShop["LevelLayout"] and RunSave.AfterlifeShop["LevelLayout"][makeLookupKey(nearestRoom.RoomIndex)] and RunSave.AfterlifeShop["LevelLayout"][makeLookupKey(nearestRoom.RoomIndex)] > 0 then

        if (not Resouled.AfterlifeShop.SpecialBuffRoomsConnectionWhitelist[RunSave.AfterlifeShop["LevelLayout"][makeLookupKey(currentIndex)]] and
        RunSave.AfterlifeShop["LevelLayout"][makeLookupKey(nearestRoom.RoomIndex)] == Resouled.AfterlifeShop.RoomTypes.SpecialBuffsRoom) or
        (RunSave.AfterlifeShop["LevelLayout"][makeLookupKey(currentIndex)] == Resouled.AfterlifeShop.RoomTypes.SpecialBuffsRoom and
        not Resouled.AfterlifeShop.SpecialBuffRoomsConnectionWhitelist[RunSave.AfterlifeShop["LevelLayout"][makeLookupKey(nearestRoom.RoomIndex)]])
        then
            return
        end

        local door = game:Spawn(Door.Type, Door.Variant, position, Vector.Zero, nil, Door.SubType, Isaac.GetFrameCount())
        local sprite = door:GetSprite()

        sprite:Play(Door.Animations.Open, true)

        if RunSave.AfterlifeShop["LevelLayout"][makeLookupKey(nearestRoom.RoomIndex)] == (Resouled.AfterlifeShop.RoomTypes.SoulSanctum or Resouled.AfterlifeShop.RoomTypes.SpecialBuffsRoom) then

            if not Resouled.AfterlifeShop:IsShuffleComplete() then
                sprite:Play(Door.Animations.Locked, true)
            end

        end

        door.SizeMulti = Vector(1, 0.001)
        door.SpriteRotation = -90 + (90 * doorSlot)
        door.SpriteOffset = door.SpriteOffset + DOOR_OFFSET:Rotated(door.SpriteRotation)
    end
end

local function spawnDoors()
    local RunSave = Resouled.SaveManager.GetRunSave()
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
    if npc.Variant == Door.Variant and npc.SubType == Door.SubType then
        if collider:ToPlayer() then
            local nearRoomTable = Resouled:GetNearestRoomIndexAndDirectionFromPos(npc.Position)
            if nearRoomTable then
                game:StartRoomTransition(nearRoomTable.RoomIndex, nearRoomTable.Direction, RoomTransitionAnim.WALK)
            end
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_COLLISION, onNpcCollision, Door.Type)

---@param npc EntityNPC
local function onNpcUpdate(_, npc)
    if npc.Variant == Door.Variant and npc.SubType == Door.SubType then
        local sprite = npc:GetSprite()

        local locked = ShouldDoorBeLocked(npc.Position)

        if sprite:IsEventTriggered(Door.Animations.Events.Flash) then
            Resouled:WhiteOverlay(Color(), Door.FlashFadeSpeed)
        end

        if sprite:IsFinished(Door.Animations.Unlock) then
            sprite:Play(Door.Animations.Open, true)
        end

        if sprite:IsPlaying(Door.Animations.Locked) and not locked then
            sprite:Play(Door.Animations.Unlock, true)
        elseif sprite:IsPlaying(Door.Animations.Open) and locked then
            sprite:Play(Door.Animations.Locked, true)
        end

        if sprite:IsPlaying(Door.Animations.Open) and npc.EntityCollisionClass ~= EntityCollisionClass.ENTCOLL_PLAYERONLY then
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
        elseif sprite:IsPlaying(Door.Animations.Locked) and npc.EntityCollisionClass ~= EntityCollisionClass.ENTCOLL_NONE  then
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        end

        if npc.SizeMulti.Y >= 1 then
            npc:Remove()
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_NPC_UPDATE, onNpcUpdate, Door.Type)

local function postFloorGenerate()
    local RunSave = Resouled.SaveManager.GetRunSave()
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

        layout[makeLookupKey(currentIndex)] = setRoomType(Resouled.AfterlifeShop.RoomTypes.StartingRoom)

        currentIndex = moveAroundMap(currentIndex, Direction.UP)

        local shopIdx = currentIndex

        layout[makeLookupKey(currentIndex)] = setRoomType(Resouled.AfterlifeShop.RoomTypes.MainShop)

        currentIndex = moveAroundMap(currentIndex, Direction.LEFT)

        layout[makeLookupKey(currentIndex)] = setRoomType(Resouled.AfterlifeShop.RoomTypes.Graveyard)

        currentIndex = moveAroundMap(shopIdx, Direction.RIGHT)

        layout[makeLookupKey(currentIndex)] = setRoomType(Resouled.AfterlifeShop.RoomTypes.SecretFight)

        currentIndex = moveAroundMap(shopIdx, Direction.UP)
        
        layout[makeLookupKey(currentIndex)] = setRoomType(Resouled.AfterlifeShop.RoomTypes.SoulSanctum)

        local soulSanctumIdx = currentIndex

        local specialBuffRooms = math.ceil(#Resouled.AfterlifeShop.Goto.SpecialBuffs / Resouled.AfterlifeShop.SpecialBuffsPerRoom)

        for _ = 1, specialBuffRooms do
            if math.random() < Resouled.AfterlifeShop.ChanceToGoBackToSoulSanctumDuringGeneration and isAnySpotAroundRoomFree(soulSanctumIdx) then
                currentIndex = soulSanctumIdx
            end

            currentIndex = moveAroundMap(currentIndex, math.random(1, 3)) -- UP, RIGHT, DOWN

            layout[makeLookupKey(currentIndex)] = setRoomType(Resouled.AfterlifeShop.RoomTypes.SpecialBuffsRoom)
        end

        --Finished
        spawnDoors()
        
        level:Update()
    end
end
Resouled:AddPriorityCallback(ModCallbacks.MC_POST_NEW_LEVEL, CallbackPriority.LATE, postFloorGenerate)

Resouled:AddCallback(ModCallbacks.MC_PRE_LEVEL_PLACE_ROOM, function()
    local RunSave = Resouled.SaveManager.GetRunSave()
    if RunSave.AfterlifeShopNext then
        RunSave.AfterlifeShop = {}
        RunSave.AfterlifeShopNext = nil
    end

    if Resouled.AfterlifeShop:IsAfterlifeShop() then
        local roomConfig = RoomConfigHolder.GetRandomRoom(1, false, StbType.CHEST, RoomType.ROOM_DEFAULT, RoomShape.ROOMSHAPE_1x1, nil, nil, nil, nil, 4)
        return roomConfig
    end
end)

---@return table|nil
function Resouled.AfterlifeShop:GetLayout()
    local RunSave = Resouled.SaveManager.GetRunSave()
    if Resouled.AfterlifeShop:IsAfterlifeShop() and RunSave.AfterlifeShop["LevelLayout"] then
        return RunSave.AfterlifeShop["LevelLayout"]
    end
    return nil
end

---@return string
function Resouled.AfterlifeShop:GetRoomLookupKey(index)
    return tostring(math.floor(index + 0.5))
end