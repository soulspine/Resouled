---@class DoorsModule
local doorsModule = {}

--- Shuts all doors in the room
--- borrowed from epiphany
---@param filter? fun(door: GridEntityDoor): boolean? @Filter which doors should be closed
function doorsModule:ForceShutDoors(filter)
	local room = Game():GetRoom()
	for doorSlot = DoorSlot.LEFT0, DoorSlot.NUM_DOOR_SLOTS - 1 do
		local door = room:GetDoor(doorSlot)
		if door
			and door:IsOpen()
			and door:GetSprite():GetAnimation() ~= door.CloseAnimation
			and (filter == nil or filter(door) == true)
		then
			door:Close(true)
			door:GetSprite():Play(door.CloseAnimation, true)
			door:SetVariant(DoorVariant.DOOR_HIDDEN)
			local grid_save = SAVE_MANAGER.GetRoomFloorSave(room:GetGridPosition(door:GetGridIndex()))
			if not grid_save.Doors__HasForcedShut then
				grid_save.Doors__HasForcedShut = true
			else
				door:GetSprite():SetLastFrame()
			end
		end
	end
end

--- Opens all doors in the room
---@param filter? fun(door: GridEntityDoor): boolean? @Filter which doors should be opened
function doorsModule:ForceOpenDoors(filter)
    local room = Game():GetRoom()
    for doorSlot = DoorSlot.LEFT0, DoorSlot.NUM_DOOR_SLOTS - 1 do
        local door = room:GetDoor(doorSlot)
        if door and not door:IsOpen() and (filter == nil or filter(door) == true) then
            local validAnimation = false
            local currentAnimation = door:GetSprite():GetAnimation()
            if  currentAnimation == door.CloseAnimation
            or  currentAnimation == door.LockedAnimation
            or  currentAnimation == "Hidden"
            then
                validAnimation = true
            end

            if validAnimation then
                door:Open()
                door:GetSprite():Play(door.OpenAnimation, true)
                door:SetVariant(DoorVariant.DOOR_UNLOCKED)
                local grid_save = SAVE_MANAGER.GetRoomFloorSave(room:GetGridPosition(door:GetGridIndex()))
                if grid_save.Doors__HasForcedShut then
                    grid_save.Doors__HasForcedShut = nil
                else
                    door:GetSprite():SetLastFrame()
                end
            end
        end
    end
end

---@param doorSlot DoorSlot
---@param persistent boolean -- Whether to keep the door open always, even after events like leaving the room or using glowing hourglass
function doorsModule:ForceOpenDoor(doorSlot, persistent)
end

--- Returns a table of all doors in current room
--- @return GridEntityDoor[]
function doorsModule:GetRoomDoors()
    local doors = {}
    local room = Game():GetRoom()
    for i = DoorSlot.LEFT0, DoorSlot.NUM_DOOR_SLOTS - 1  do
        local door = room:GetDoor(i)
        if door then
            table.insert(doors, door)
        end
    end
    return doors
end

--- Returns the closest door to the given position. If no doors are found, returns nil.
---@param position Vector
---@return GridEntityDoor | nil
function doorsModule:GetClosestDoor(position)
    local doors = doorsModule:GetRoomDoors()
    local closestDoor = nil
    for _, door in ipairs(doors) do
        if not closestDoor or position:Distance(door.Position) < position:Distance(closestDoor.Position) then
            closestDoor = door
        end
    end
    return closestDoor
end

--- Returns rotation of the door based on its direction
---@param door GridEntityDoor
---@return number
function doorsModule:GetRotationFromDoor(door)
    return (door.Direction - 1) * 90
end

--- Returns what type of resource opens said door.
--- Returns `true` if by a key,  `false` if by a coin and `nil` if door is not locked.
---@param door GridEntityDoor
---@return boolean | nil
function doorsModule:WhatOpensDoorLock(door)
    if not door:IsOpen() and door:IsLocked() then
        local sprite = door:GetSprite()
        local lockedAnim = door.LockedAnimation
        if door:IsTargetRoomArcade() or lockedAnim == "CoinClosed" then
            return false
        elseif lockedAnim == "KeyClosed" then
            return true
        end
    end
    return nil
end

return doorsModule