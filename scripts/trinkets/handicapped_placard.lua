local TRINKET = Resouled.Enums.Trinkets.HANDICAPPED_PLACARD

local CONFIG = {
    AfterUseBreakChance = 0.5,
    DoorSeekDistance = 100,
    DoorActivationTime = 120,
    DoorActivationDistance = 10,
    OnDoorEffectDuration = 100,
    ActivationSFX = SoundEffect.SOUND_GOLDENKEY,
    BreakSFX = Resouled.Enums.SoundEffects.PAPER_DEATH_2,
}

local DOOR_OVERLAY_SPRITE = Sprite()
DOOR_OVERLAY_SPRITE:Load("gfx/effects/handicapped_placard_door_overlay.anm2", true)
DOOR_OVERLAY_SPRITE:Play("Idle", true)

---@param door GridEntityDoor
---@param offset Vector
local function postDoorRender(_, door, offset)
    if not PlayerManager.AnyoneHasTrinket(TRINKET) then return end
    local player0 = Isaac.GetPlayer()
    local keyNum = player0:GetNumKeys()
    local coinNum = player0:GetNumCoins()

    local whatOpensLockedDoor = Resouled.Doors:WhatOpensDoorLock(door)

    if not door:IsOpen()
        or (whatOpensLockedDoor ~= nil and ((whatOpensLockedDoor and keyNum == 0) or (not whatOpensLockedDoor and coinNum == 0))) then
        DOOR_OVERLAY_SPRITE.Rotation = Resouled.Doors:GetRotationFromDoor(door)
        DOOR_OVERLAY_SPRITE:Render(Isaac.WorldToScreen(door.Position))
    end
end
--Resouled:AddCallback(ModCallbacks.MC_POST_GRID_ENTITY_DOOR_RENDER, postDoorRender)

local function onTrinketInit(_, pickup)
    if not pickup.SubType == TRINKET then return end

    pickup:GetData().Resouled__HandicappedPlacard = {
        ActivationCountdown = CONFIG.DoorActivationTime,
        TargetDoor = nil,
    }
end
Resouled:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, onTrinketInit, PickupVariant.PICKUP_TRINKET)

---@param pickup EntityPickup
local function onTrinketUpdate(_, pickup)
    if pickup.SubType ~= TRINKET then return end
    local data = pickup:GetData().Resouled__HandicappedPlacard
    if not data then return end

    if data.ActivationCountdown > 0 then
        data.ActivationCountdown = data.ActivationCountdown - 1
    elseif data.ActivationCountdown == 0 then
        local closestDoor = Resouled.Doors:GetClosestDoor(pickup.Position)
        if closestDoor and not closestDoor:IsOpen() and closestDoor.Position:Distance(pickup.Position) <= CONFIG.DoorSeekDistance then
            data.TargetDoor = closestDoor
            pickup.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
        end
        data.ActivationCountdown = -1 -- prevent further checks until moved
    end

    if data.TargetDoor then
        ---@type GridEntityDoor
        local door = data.TargetDoor
        if door:IsOpen() then
            data.TargetDoor = nil
            return
        end

        local distanceToDoor = door.Position:Distance(pickup.Position)
        if distanceToDoor > CONFIG.DoorActivationDistance then
            pickup.Velocity = (door.Position - pickup.Position) / 3
            pickup.SpriteScale = Vector(1, 1) * distanceToDoor / CONFIG.DoorSeekDistance
        else
            pickup.Velocity = Vector.Zero
            local rng = Isaac.GetPlayer():GetTrinketRNG(TRINKET)
            local doorSprite = door:GetSprite()
            doorSprite:Play(door.OpenAnimation, true)
            door:Open()
            door:SetVariant(DoorVariant.DOOR_UNLOCKED)
            pickup:Remove()
            local sfx = SFXManager()
            if rng:RandomFloat() >= CONFIG.AfterUseBreakChance then
                local newTrinket = Game():Spawn(
                    EntityType.ENTITY_PICKUP,
                    PickupVariant.PICKUP_TRINKET,
                    door.Position,
                    Vector.Zero,
                    nil,
                    TRINKET,
                    Resouled:NewSeed()
                )
                newTrinket:GetData().Resouled__HandicappedPlacard = nil
                sfx:Play(CONFIG.ActivationSFX)
            else
                sfx:Play(CONFIG.BreakSFX)
            end
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, onTrinketUpdate, PickupVariant.PICKUP_TRINKET)
