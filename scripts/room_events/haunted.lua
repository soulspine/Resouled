local CONFIG = {
    -- in updates, how often one of the doors will be opened and shut
    DoorOpenTimer = 10,
}

local CONST = {
    Ghost = Resouled:GetEntityByName("Resouled Haunted Ghost")
}

-- handles spawning the ghost when room event is present
local function onRoomEnter()
    if Isaac.CountEnemies() == 0 or not Resouled:RoomEventPresent(Resouled.RoomEvents.HAUNTED) then return end

    local g = Game()
    g:Spawn(
        CONST.Ghost.Type,
        CONST.Ghost.Variant,
        g:GetRoom():GetRandomPosition(67),
        Vector.Zero,
        nil,
        CONST.Ghost.SubType,
        Resouled:NewSeed()
    )
end
Resouled:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, onRoomEnter)

-- this function handles all the visual effects happening within that room
local function onUpdate()
    if not Resouled:RoomEventPresent(Resouled.RoomEvents.HAUNTED) then return end

    local g = Game()
    local frameCount = g:GetFrameCount()

    -- opening and closing doors
    if frameCount % CONFIG.DoorOpenTimer == 0 then
        ---@type GridEntityDoor[]
        local closedDoors = {}
        for _, door in ipairs(Resouled.Doors:GetRoomDoors()) do
            if not door:IsOpen() and not door:IsLocked() then
                table.insert(closedDoors, door)
            end
        end

        if #closedDoors > 0 then
            local selectedDoor = closedDoors[math.random(#closedDoors)]
            selectedDoor:Open()
            selectedDoor:Close()
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_UPDATE, onUpdate)
