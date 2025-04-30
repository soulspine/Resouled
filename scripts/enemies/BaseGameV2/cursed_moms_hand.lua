local CURSED_MOMS_HAND_TYPE = EntityType.ENTITY_MOMS_HAND
local CURSED_MOMS_HAND_VARIANT = Isaac.GetEntityVariantByName("Cursed Mom's Hand")

local PULLING_DURATION = 180
local PULLING_RADIUS = 300
local PULLING_COLOR = Color(255, 0, 255)

local EVENT_TRIGGER_RESOULED_LAND = "ResouledLand"
local EVENT_TRIGGER_RESOULED_JUMP = "ResouledJump"
local EVENT_TRIGGER_RESOULED_GRAB = "ResouledGrab"
local EVENT_TRIGGER_RESOULED_TELEPOT = "ResouledTeleport"

local ANIMATION_JUMP_DOWN = "JumpDown"
local ANIMATION_JUMP_UP = "JumpUp"
local ANIMATION_STUNNED = "Stunned"
local ANIMATION_GRAB = "Grab"

---@param npc EntityNPC
local function onNpcInit(_, npc)
    if npc.Variant == CURSED_MOMS_HAND_VARIANT then
        npc.Mass = 999999
        npc:GetData().ResouledCursedMomsHand = {
            StunLock = nil,
            GrabbedPlayerId = nil,
        }
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_INIT, onNpcInit, CURSED_MOMS_HAND_TYPE)

---@param npc EntityNPC
local function onNpcUpdate(_, npc)
    if npc.Variant == CURSED_MOMS_HAND_VARIANT then
        local data = npc:GetData()
        local sprite = npc:GetSprite()
        if data.ResouledCursedMomsHand then
            if data.ResouledCursedMomsHand.StunLock then
                if data.ResouledCursedMomsHand.StunLock > 0 then
                    data.ResouledCursedMomsHand.StunLock = data.ResouledCursedMomsHand.StunLock - 1
                else
                    data.ResouledCursedMomsHand.StunLock = nil
                    Resouled:TryDisableCustomPlayerPulling(npc)
                    npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
                    sprite:Play(ANIMATION_JUMP_UP, true)
                end
                return true -- ignore internal AI
            end

            if sprite:IsPlaying(ANIMATION_GRAB) then
                if sprite:IsEventTriggered(EVENT_TRIGGER_RESOULED_GRAB) then
                    Isaac.GetPlayer(data.ResouledCursedMomsHand.GrabbedPlayerId).Visible = false
                end

                if sprite:IsEventTriggered(EVENT_TRIGGER_RESOULED_TELEPOT) then
                    local game = Game()
                    local level = game:GetLevel()
                    local room = game:GetRoom()
                    local door = room:GetDoor(level.EnterDoor)
                    local targetRoom = level:GetRoomByIdx(level.EnterDoor ~= DoorSlot.NO_DOOR_SLOT and door.TargetRoomIndex or level:GetCurrentRoomIndex()).SafeGridIndex
                    local player = Isaac.GetPlayer(data.ResouledCursedMomsHand.GrabbedPlayerId)
                    player.Visible = true
                    game:StartRoomTransition(targetRoom, Direction.NO_DIRECTION, RoomTransitionAnim.FADE, player)
                end

            end

            if sprite:IsPlaying(ANIMATION_STUNNED) then
                data.ResouledCursedMomsHand.StunLock = PULLING_DURATION
                npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
                Resouled:TryEnableCustomPlayerPulling(npc, PULLING_RADIUS, PULLING_COLOR)
            end
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, onNpcUpdate, CURSED_MOMS_HAND_TYPE)

---@param npc EntityNPC
---@param collider Entity
---@param low boolean
local function onNpcCollision(_, npc, collider, low)
    if npc.Variant == CURSED_MOMS_HAND_VARIANT and collider.Type == EntityType.ENTITY_PLAYER then
        local sprite = npc:GetSprite()
        local data = npc:GetData()
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        data.ResouledCursedMomsHand.StunLock = nil
        sprite:Play(ANIMATION_GRAB, true)
        data.ResouledCursedMomsHand.GrabbedPlayerId = collider:ToPlayer().Index
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_NPC_COLLISION, onNpcCollision, CURSED_MOMS_HAND_TYPE)