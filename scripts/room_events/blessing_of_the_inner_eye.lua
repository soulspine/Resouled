---@param index integer
local function revealRoomsAround(index)
    local level = Game():GetLevel()
    local roomDir = Vector(1, 0)

    for i = 1, 8 do
        local vert = roomDir.X > 0 and Direction.RIGHT or roomDir.X < 0 and Direction.LEFT or Direction.NO_DIRECTION
        local hori = roomDir.Y > 0 and Direction.DOWN or roomDir.Y < 0 and Direction.UP or Direction.NO_DIRECTION
        local targetIndex = Resouled:GetRoomIdxFromDir(hori, Resouled:GetRoomIdxFromDir(vert, index) or index) or index

        local desc = level:GetRoomByIdx(targetIndex)
        if desc.DisplayFlags ~= RoomDescriptor.DISPLAY_ALL then
            desc.DisplayFlags = RoomDescriptor.DISPLAY_ALL
        end

        roomDir = roomDir:Rotated(45)
    end
end

local function postNewRoom()
    if Resouled:RoomEventPresent(Resouled.RoomEvents.BLESSING_OF_INNER_EYE) then
        local level = Game():GetLevel()
        local currentIndex = level:GetCurrentRoomIndex()

        for i = Direction.LEFT, Direction.DOWN do
            revealRoomsAround(Resouled:GetRoomIdxFromDir(i, currentIndex) or currentIndex)
        end

        level:UpdateVisibility()
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, postNewRoom)