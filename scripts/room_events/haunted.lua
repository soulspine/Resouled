local CONFIG = {
    -- in updates, how often one of the doors will be check and shut
    -- in updates, how often one of the doors will be check and shut
    DoorOpenTimer = 10,
    ThunderChance = 0.1,
    LilGhostSpawnChance = 0.05,
    DoorSFX = SoundEffect.SOUND_DOOR_HEAVY_CLOSE,
    LevitateMaxOffset = 6,
    LevitateStrength = 2,
    MaximumLevitateSpeed = 2,
    MinimumLevitateSpeed = 0.3,
}

local CONST = {
    Ghost = Resouled:GetEntityByName("Resouled Haunted Ghost"),
    LilGhost = Resouled:EntityDescConstructor(EntityType.ENTITY_EFFECT, EffectVariant.LIL_GHOST, 0, "Lil Ghost"),
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
    local room = g:GetRoom()
    -- opening and closing doors
    if frameCount % CONFIG.DoorOpenTimer == 0 then
        if math.random() > CONFIG.LilGhostSpawnChance then
            Game():Spawn(EntityType.ENTITY_EFFECT,
                EffectVariant.LIL_GHOST,
                room:GetRandomPosition(67),
                Vector.Zero,
                nil,
                0,
                Resouled:NewSeed()
            )
        end

        g:Darken(Resouled:RandomFloatInRanges(1, 0.9), 10)
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
            room:DoLightningStrike()
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_UPDATE, onUpdate)

---@param effect EntityEffect
local function onSmallGhostEffectInit(_, effect)
    if not Resouled:MatchesEntityDesc(effect, CONST.LilGhost) or not Resouled:RoomEventPresent(Resouled.RoomEvents.HAUNTED) then return end
    effect:GetSprite().Color.A = 0
end
Resouled:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, onSmallGhostEffectInit)

---@param effect EntityEffect
local function onSmallGhostEffectUpdate(_, effect)
    if not Resouled:MatchesEntityDesc(effect, CONST.LilGhost) or not Resouled:RoomEventPresent(Resouled.RoomEvents.HAUNTED) then return end
    effect:GetSprite().Color.A = math.min(0.4, effect:GetSprite().Color.A + 0.05)
end
Resouled:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, onSmallGhostEffectUpdate)


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
    return spriteOffset +
        Vector(
            0,
            math.sin(
                math.rad((g:GetFrameCount() + originalGridInt * 3) * 12 * speedMod % 360)) * CONFIG.LevitateStrength
        )
end


Resouled:AddCallback(ModCallbacks.MC_PRE_GRID_ENTITY_ROCK_RENDER, gridLevitate)
Resouled:AddCallback(ModCallbacks.MC_PRE_GRID_ENTITY_TNT_RENDER, gridLevitate)
Resouled:AddCallback(ModCallbacks.MC_PRE_GRID_ENTITY_LOCK_RENDER, gridLevitate)
Resouled:AddCallback(ModCallbacks.MC_PRE_GRID_ENTITY_FIRE_RENDER, gridLevitate)
Resouled:AddCallback(ModCallbacks.MC_PRE_GRID_ENTITY_POOP_RENDER, gridLevitate)
