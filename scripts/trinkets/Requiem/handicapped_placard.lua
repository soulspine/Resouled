local HANDICAPPED_PLACARD = Isaac.GetTrinketIdByName("Handicapped Placard")

local BREAK_CHANCE = 0.5

local OVERLAY_SPRITE = Sprite()
OVERLAY_SPRITE:Load("gfx/effects/handicapped_placard_door_overlay.anm2", true)
OVERLAY_SPRITE:Play("Idle", true)

---@param door GridEntityDoor
---@param offset Vector
local function postDoorRender(_, door, offset)
    if PlayerManager.AnyoneHasTrinket(HANDICAPPED_PLACARD) then
        local player0 = Isaac.GetPlayer()
        local keyNum = player0:GetNumKeys()
        local coinNum = player0:GetNumCoins()

        local whatOpensLockedDoor = Resouled.Doors:WhatOpensDoorLock(door)

        if not door:IsOpen()
        or (whatOpensLockedDoor ~= nil and ((whatOpensLockedDoor and keyNum == 0) or (not whatOpensLockedDoor and coinNum == 0))) then
            OVERLAY_SPRITE.Offset = Isaac.WorldToScreen(door.Position)
            OVERLAY_SPRITE.Rotation = Resouled.Doors:GetRotationFromDoor(door)
            OVERLAY_SPRITE:Render(Vector.Zero)
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_GRID_ENTITY_DOOR_RENDER, postDoorRender)