local ENTITY_NAME = "Light Switch"
local ENTITY_TYPE = Isaac.GetEntityTypeByName(ENTITY_NAME)
local ENTITY_VARIANT = Isaac.GetEntityVariantByName(ENTITY_NAME)
local ENTITY_SUBTYPE = Isaac.GetEntitySubTypeByName(ENTITY_NAME)

local SWITCH_COOLDOWN = 30 -- updates

local DARKEN_STRENGTH = 1
local DARKEN_TIMEOUT = 5

local ANIMATION_ON = "On"
local ANIMATION_OFF = "Off"
local ANIMATION_ON_TO_OFF = "OnToOff"
local ANIMATION_OFF_TO_ON = "OffToOn"

---@param pickup EntityPickup
local function onInit(_, pickup)
    local sprite = pickup:GetSprite()
    sprite:Play(sprite:GetDefaultAnimation(), true)
    pickup.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
    pickup.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
end
Resouled:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, onInit, ENTITY_VARIANT)

---@param pickup EntityPickup
local function onUpdate(_, pickup)
    if pickup.SubType == ENTITY_SUBTYPE then
        local data = pickup:GetData()

        if data.RESOULED_LIGHTSWITCH_COOLDOWN then
            data.RESOULED_LIGHTSWITCH_COOLDOWN = data.RESOULED_LIGHTSWITCH_COOLDOWN - 1
            if data.RESOULED_LIGHTSWITCH_COOLDOWN <= 0 then
                data.RESOULED_LIGHTSWITCH_COOLDOWN = nil
            end
        end

        local sprite = pickup:GetSprite()

        if sprite:IsFinished(ANIMATION_ON_TO_OFF) then
            sprite:Play(ANIMATION_OFF, true)
        elseif sprite:IsFinished(ANIMATION_OFF_TO_ON) then
            sprite:Play(ANIMATION_ON, true)
        end

        if sprite:IsPlaying(ANIMATION_OFF) then
            Game():Darken(DARKEN_STRENGTH, DARKEN_TIMEOUT)
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_PICKUP_UPDATE, onUpdate, ENTITY_VARIANT)

---@param pickup EntityPickup
---@param collider Entity
---@param low boolean
local function onCollision(_, pickup, collider, low)
    local data = pickup:GetData()
    local validNpc = collider:ToNPC() and collider:ToNPC():IsFlying()
    if not data.RESOULED_LIGHTSWITCH_COOLDOWN and (collider:ToPlayer() or validNpc) then
        local sprite = pickup:GetSprite()

        if sprite:IsPlaying(ANIMATION_ON) then
            sprite:Play(ANIMATION_ON_TO_OFF, true)
        else
            sprite:Play(ANIMATION_OFF_TO_ON, true)
        end
        data.RESOULED_LIGHTSWITCH_COOLDOWN = SWITCH_COOLDOWN
    end
    return true -- cancel collision
end
Resouled:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, onCollision, ENTITY_VARIANT)
