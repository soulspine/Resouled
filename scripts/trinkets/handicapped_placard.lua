local TRINKET = Resouled.Enums.Trinkets.HANDICAPPED_PLACARD

local CONFIG = {
    AfterUseBreakChance = 0.5,
    DoorSeekDistance = 100,
    DoorActivationTime = 120,
    DoorActivationDistance = 10,
    OnDoorEffectDuration = 100,
    ActivationSFX = SoundEffect.SOUND_GOLDENKEY,
    BreakSFX = Resouled.Enums.SoundEffects.PAPER_DEATH_2,
    EidDescriptionPreFormat =
    "Dropping it close to a locked door will open said door#Has %s%% chance to break after each use",
    EidGoldenDescriptionAppend =
    "Can mark {{SecretRoom}} Secret and {{SuperSecretRoom}} Super Secret Rooms"
}

local DOOR_OVERLAY_SPRITE = Sprite()
DOOR_OVERLAY_SPRITE:Load("gfx_resouled/effects/handicapped_placard_door_overlay.anm2", true)
DOOR_OVERLAY_SPRITE:Play("Idle", true)

Resouled.EID:AddTrinket(TRINKET,
    string.format(CONFIG.EidDescriptionPreFormat, Resouled.EID:FormatFloat(CONFIG.AfterUseBreakChance * 100))
)
Resouled.EID:AddTrinketConditional(TRINKET, "Resouled__HandicappedPlacard_Golden",
    Resouled.EID.CommonConditions.HigherTrinketMult,
    function(desc)
        local newChance = (CONFIG.AfterUseBreakChance ^ Resouled.EID:GetTrinketMultFromDesc(desc)) * 100

        desc.Description = string.format(
                CONFIG.EidDescriptionPreFormat,
                "{{ColorGold}}" .. Resouled.EID:FormatFloat(newChance) .. "{{ColorText}}"
            ) ..
            "#{{ColorGold}}" .. CONFIG.EidGoldenDescriptionAppend .. "{{ColorText}}"

        return desc
    end
)

---@param door GridEntityDoor
---@param offset Vector
local function postDoorRender(_, door, offset)
    if door:IsOpen() then return end
    local trinketMult = 0
    Resouled.Iterators:IterateOverPlayers(function(player)
        trinketMult = math.max(trinketMult, player:GetTrinketMultiplier(TRINKET))
    end)
    if trinketMult == 0 then return end

    local reveal = true

    if trinketMult < 2 and (door.TargetRoomType == RoomType.ROOM_SECRET or door.TargetRoomType == RoomType.ROOM_SUPERSECRET) then
        reveal = false
    end

    if reveal then
        DOOR_OVERLAY_SPRITE.Rotation = Resouled.Doors:GetRotationFromDoor(door)
        DOOR_OVERLAY_SPRITE:Render(Isaac.WorldToScreen(door.Position))
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_GRID_ENTITY_DOOR_RENDER, postDoorRender)

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
    if Resouled.Collectiblextension:GetTrinketPickupSubType(pickup) ~= TRINKET then return end
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
            local trinketMult = Resouled.Collectiblextension:GetPotentialTrinketPickupMultiplier(pickup)
            if rng:RandomFloat() >= (CONFIG.AfterUseBreakChance) ^ trinketMult then
                local newTrinket = Game():Spawn(
                    EntityType.ENTITY_PICKUP,
                    PickupVariant.PICKUP_TRINKET,
                    door.Position,
                    Vector.Zero,
                    nil,
                    pickup.SubType,
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
