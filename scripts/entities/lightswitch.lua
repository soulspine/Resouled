local ENTITY_NAME = "Light Switch"
local ENTITY_TYPE = Isaac.GetEntityTypeByName(ENTITY_NAME)
local ENTITY_VARIANT = Isaac.GetEntityVariantByName(ENTITY_NAME)
local ENTITY_SUBTYPE = Isaac.GetEntitySubTypeByName(ENTITY_NAME)

local SWITCH_COOLDOWN = 30 -- updates

local ANIMATION_ON = "On"
local ANIMATION_OFF = "Off"
local ANIMATION_ON_TO_OFF = "OnToOff"
local ANIMATION_OFF_TO_ON = "OffToOn"

local ANIMATION_EVENT_ON = "SwitchOn"
local ANIMATION_EVENT_OFF = "SwitchOff"

local function isPitchBlack()
    local roomDesc = Game():GetLevel():GetCurrentRoomDesc()
    return roomDesc.Flags & RoomDescriptor.FLAG_PITCH_BLACK > 0
end

local function setPitchBlack(state)
    local roomDesc = Game():GetLevel():GetCurrentRoomDesc()
    if state then
        roomDesc.Flags = roomDesc.Flags | RoomDescriptor.FLAG_PITCH_BLACK
    else
        roomDesc.Flags = roomDesc.Flags & ~RoomDescriptor.FLAG_PITCH_BLACK
    end
end

---@param pickup EntityPickup
local function onInit(_, pickup)
    if pickup.SubType == ENTITY_SUBTYPE then
        local sprite = pickup:GetSprite()
        local targetAnimation = isPitchBlack() and ANIMATION_OFF or ANIMATION_ON
        sprite:Play(targetAnimation, true)
        pickup.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
        pickup.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
    end
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
        local isPitchBlack = isPitchBlack()
        local transitioning = sprite:IsPlaying(ANIMATION_ON_TO_OFF) or sprite:IsPlaying(ANIMATION_OFF_TO_ON)

        -- syncing other light switches
        if isPitchBlack and sprite:IsPlaying(ANIMATION_ON) then
            sprite:Play(ANIMATION_ON_TO_OFF, true)
            data.RESOULED_LIGHTSWITCH_IGNORE_NEXT_EVENT = true
        elseif not isPitchBlack and sprite:IsPlaying(ANIMATION_OFF) then
            sprite:Play(ANIMATION_OFF_TO_ON, true)
            data.RESOULED_LIGHTSWITCH_IGNORE_NEXT_EVENT = true
        end

        if sprite:IsFinished(ANIMATION_ON_TO_OFF) then
            sprite:Play(ANIMATION_OFF, true)
        elseif sprite:IsFinished(ANIMATION_OFF_TO_ON) then
            sprite:Play(ANIMATION_ON, true)
        end

        local eventTriggered = sprite:IsEventTriggered(ANIMATION_EVENT_ON) or
            sprite:IsEventTriggered(ANIMATION_EVENT_OFF)

        if eventTriggered then
            if data.RESOULED_LIGHTSWITCH_IGNORE_NEXT_EVENT then
                data.RESOULED_LIGHTSWITCH_IGNORE_NEXT_EVENT = nil
            else
                setPitchBlack(not isPitchBlack)
            end
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_PICKUP_UPDATE, onUpdate, ENTITY_VARIANT)

---@param pickup EntityPickup
---@param collider Entity
---@param low boolean
local function onCollision(_, pickup, collider, low)
    if pickup.SubType == ENTITY_SUBTYPE then
        local data = pickup:GetData()
        local validNpc = collider:ToNPC() and not collider:ToNPC():IsFlying()
        if pickup.SubType == ENTITY_SUBTYPE
            and not data.RESOULED_LIGHTSWITCH_COOLDOWN
            and (collider:ToPlayer() or validNpc)
        then
            local sprite = pickup:GetSprite()

            if sprite:IsPlaying(ANIMATION_ON) then
                sprite:Play(ANIMATION_ON_TO_OFF, true)
            else
                sprite:Play(ANIMATION_OFF_TO_ON, true)
            end
            data.RESOULED_LIGHTSWITCH_COOLDOWN = SWITCH_COOLDOWN
        end
        return true -- prevent collision
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, onCollision, ENTITY_VARIANT)
