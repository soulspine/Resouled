local CURSED_MOMS_HAND_TYPE = EntityType.ENTITY_MOMS_HAND
local CURSED_MOMS_HAND_VARIANT = Isaac.GetEntityVariantByName("Cursed Mom's Hand")
local CURSED_MOMS_HAND_SUBTYPE = Isaac.GetEntitySubTypeByName("Cursed Mom's Hand")

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

local GRAB_TELEPORT_ROOM_TYPE_WHITELIST = {
    [RoomType.ROOM_DEFAULT] = true,
    [RoomType.ROOM_BOSS] = true,
    [RoomType.ROOM_MINIBOSS] = true,
    [RoomType.ROOM_CURSE] = true,
    [RoomType.ROOM_CHALLENGE] = true,
    [RoomType.ROOM_SACRIFICE] = true,
}

local CURSED_ENEMY_MORPH_CHANCE = Resouled.Stats.CursedEnemyMorphChance

---@param npc EntityNPC
local function onNpcInit(_, npc)
    if Game():GetLevel():GetCurses() > 0 then
        Resouled:TryEnemyMorph(npc, CURSED_ENEMY_MORPH_CHANCE, CURSED_MOMS_HAND_TYPE, CURSED_MOMS_HAND_VARIANT, CURSED_MOMS_HAND_SUBTYPE)
    end
    if npc.Variant == CURSED_MOMS_HAND_VARIANT then
        npc.Mass = math.huge
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
                    Resouled.Pulling:TryDisableCustomPlayerPulling(npc)
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
                    local currentRoomSafeIndex = level:GetCurrentRoomDesc().SafeGridIndex -- i get it here to exclude it from possible destination rooms

                    local validRoomSafeGridIndexes = {}
                    local rooms = level:GetRooms()
                    for i = 0, rooms.Size - 1 do
                        local roomDesc = rooms:Get(i)
                        if roomDesc.SafeGridIndex ~= currentRoomSafeIndex and GRAB_TELEPORT_ROOM_TYPE_WHITELIST[roomDesc.Data.Type] then
                            table.insert(validRoomSafeGridIndexes, roomDesc.SafeGridIndex)
                        end
                    end

                    local rng = RNG()
                    rng:SetSeed(npc.DropSeed, 14) -- random shift number

                    local targetRoom = validRoomSafeGridIndexes[rng:RandomInt(#validRoomSafeGridIndexes) + 1]

                    local player = Isaac.GetPlayer(data.ResouledCursedMomsHand.GrabbedPlayerId)
                    player.Visible = true
                    game:StartRoomTransition(targetRoom, Direction.NO_DIRECTION, RoomTransitionAnim.FADE, player)
                end
            end

            if sprite:IsEventTriggered(EVENT_TRIGGER_RESOULED_LAND) then
                npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
            end

            if sprite:IsPlaying(ANIMATION_STUNNED) then
                data.ResouledCursedMomsHand.StunLock = PULLING_DURATION
                Resouled.Pulling:TryEnableCustomPlayerPulling(npc, PULLING_RADIUS, PULLING_COLOR)
            end
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, onNpcUpdate, CURSED_MOMS_HAND_TYPE)

---@param npc EntityNPC
---@param collider Entity
---@param low boolean
local function onNpcCollision(_, npc, collider, low)
    local player = collider:ToPlayer()
    if npc.Variant == CURSED_MOMS_HAND_VARIANT and player then
        local sprite = npc:GetSprite()
        local data = npc:GetData()
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        data.ResouledCursedMomsHand.StunLock = nil
        sprite:Play(ANIMATION_GRAB, true)
        data.ResouledCursedMomsHand.GrabbedPlayerId = player.Index
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_NPC_COLLISION, onNpcCollision, CURSED_MOMS_HAND_TYPE)

Resouled.StatTracker:RegisterCursedEnemy(CURSED_MOMS_HAND_TYPE, CURSED_MOMS_HAND_VARIANT, CURSED_MOMS_HAND_SUBTYPE)