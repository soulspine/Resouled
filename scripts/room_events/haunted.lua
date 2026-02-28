local CONFIG = {
    -- in updates, how often one of the doors will be check and shut
    DoorOpenTimer = 10,
    DoorSFXs = { SoundEffect.SOUND_DOOR_HEAVY_CLOSE, SoundEffect.SOUND_DOOR_HEAVY_OPEN }
}

local CONST = {
    Ghost = Resouled:GetEntityByName("Resouled Haunted Ghost")
}

local g = Game()
local s = SFXManager()

-- handles spawning the ghost when room event is present
local function onRoomEnter()
    if Isaac.CountEnemies() == 0 or not Resouled:RoomEventPresent(Resouled.RoomEvents.HAUNTED) then return end

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

    local frameCount = g:GetFrameCount()

    -- opening and closing doors
    if frameCount % CONFIG.DoorOpenTimer == 0 then
        local check = false
        for _ = 1, math.random(#Resouled.Doors:GetRoomDoors()) do
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
                check = true
            end
        end
        if check then
            check = false
            for _, sfx in ipairs(CONFIG.DoorSFXs) do
                if check then break end
                check = s:IsPlaying(sfx)
            end
            if not check then s:Play(CONFIG.DoorSFXs[math.random(#CONFIG.DoorSFXs)]) end
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_UPDATE, onUpdate)
