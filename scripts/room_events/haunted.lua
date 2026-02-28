local CONFIG = {
    -- in updates, how often one of the doors will be check and shut
    -- in updates, how often one of the doors will be check and shut
    DoorOpenTimer = 10,
    ThunderChance = 0.05,
    DoorSFX = SoundEffect.SOUND_DOOR_HEAVY_CLOSE,
    LevitateMaxOffset= 6,
    LevitateStrength = 2,
    MaximumLevitateSpeed = 2,
    MinimumLevitateSpeed = 0.3,
}

local CONST = {
    Ghost = Resouled:GetEntityByName("Resouled Haunted Ghost")
}

local g = Game()
local s = SFXManager()

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

local preventSFX = false
-- this function handles all the visual effects happening within that room
local function onUpdate()
    if not Resouled:RoomEventPresent(Resouled.RoomEvents.HAUNTED) then return end

    local frameCount = g:GetFrameCount()

    -- opening and closing doors
    if frameCount % CONFIG.DoorOpenTimer == 0 then
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
                preventSFX = true
            end
        end

        if math.random() < CONFIG.ThunderChance then
            s:Play(SoundEffect.SOUND_THUNDER)
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_UPDATE, onUpdate)

---@param sfx SoundEffect
Resouled:AddCallback(ModCallbacks.MC_PRE_SFX_PLAY, function(_, sfx)
    if not preventSFX or not (sfx == SoundEffect.SOUND_DOOR_HEAVY_CLOSE or sfx == SoundEffect.SOUND_DOOR_HEAVY_OPEN) then return end
    preventSFX = false
    return false
end)

local levitateRng = RNG()
---@param en GridEntity
---@param spriteOffset Vector
local function gridLevitate(_, en, spriteOffset)
    if not Resouled:RoomEventPresent(Resouled.RoomEvents.HAUNTED) then return end

    levitateRng:SetSeed(math.floor(67 * en.Position.Y + en.Position.X * 1.7) * 42069)

    local originalGridInt = levitateRng:PhantomInt(CONFIG.LevitateMaxOffset)
    local speedMod = Resouled:RandomFloatInRanges(CONFIG.MinimumLevitateSpeed, CONFIG.MaximumLevitateSpeed, levitateRng)
    return spriteOffset + Vector(0, math.sin(math.rad((g:GetFrameCount() + originalGridInt * 3) * 12 * speedMod % 360)) * CONFIG.LevitateStrength)
end


Resouled:AddCallback(ModCallbacks.MC_PRE_GRID_ENTITY_ROCK_RENDER, gridLevitate)
Resouled:AddCallback(ModCallbacks.MC_PRE_GRID_ENTITY_TNT_RENDER, gridLevitate)
Resouled:AddCallback(ModCallbacks.MC_PRE_GRID_ENTITY_LOCK_RENDER, gridLevitate)
Resouled:AddCallback(ModCallbacks.MC_PRE_GRID_ENTITY_FIRE_RENDER, gridLevitate)
Resouled:AddCallback(ModCallbacks.MC_PRE_GRID_ENTITY_POOP_RENDER, gridLevitate)