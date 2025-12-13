local CONFIG = {
    SpawnSfx = {
        SFX = SoundEffect.SOUND_MOM_VOX_EVILLAUGH,
        Volume = 0.5,
    },
    Descend = {
        CooldownRange = { 90, 135 }, -- minimum, maximum updates it can wait before descending after coming up / spawning
        ShadowBreakpoint = 50,       -- at this number of updates left, its shadow will start to expand following the player and it will be the biggest upon landing
    },
    Pulling = {
        Duration = 180,
        Radius = 300,
        Color = Color(255, 0, 255),
    },
    TeleportRoomsWhitelist = {
        [RoomType.ROOM_DEFAULT] = true,
        [RoomType.ROOM_BOSS] = true,
        [RoomType.ROOM_MINIBOSS] = true,
        [RoomType.ROOM_CURSE] = true,
        [RoomType.ROOM_CHALLENGE] = true,
        [RoomType.ROOM_SACRIFICE] = true,
    },
}

local CONST = {
    Entity = Resouled:GetEntityByName("Cursed Mom's Hand"),
    Events = {
        Land = "ResouledLand",
        Jump = "ResouledJump",
        Grab = "ResouledGrab",
        Teleport = "ResouledTeleport",
    },
    Animations = {
        Idle = "Idle",
        JumpDown = "JumpDown",
        JumpUp = "JumpUp",
        Stunned = "Stunned",
        Grab = "Grab",
    },
}

Resouled:RegisterCursedEnemyMorph(EntityType.ENTITY_MOMS_HAND, nil, nil, CONST.Entity.Type, CONST.Entity.Variant,
    CONST.Entity.SubType)

---@param npc EntityNPC
local function onNpcInit(_, npc)
    if not Resouled:MatchesEntityDesc(npc, CONST.Entity) then return end
    npc:GetData().Resouled__Cursed_Moms_Hand = {
        DescendCooldown = math.random(CONFIG.Descend.CooldownRange[1], CONFIG.Descend.CooldownRange[2]),
        PullingDurationLeft = 0,
        DefaultShadowSize = npc:GetShadowSize(),
        LockedPosition = nil,
        Victim = nil,
    }
    npc:SetShadowSize(0)
    npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
    npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
    SFXManager():Play(CONFIG.SpawnSfx.SFX, CONFIG.SpawnSfx.Volume)
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_INIT, onNpcInit, CONST.Entity.Type)

---@param npc EntityNPC
local function onNpcUpdate(_, npc)
    if not Resouled:MatchesEntityDesc(npc, CONST.Entity) then return end
    local data = npc:GetData().Resouled__Cursed_Moms_Hand
    local sprite = npc:GetSprite()

    local animName = sprite:GetAnimation()

    if data.LockedPosition then
        npc.Position = data.LockedPosition
    end

    if animName == CONST.Animations.Idle then
        if data.DescendCooldown > 0 then
            data.DescendCooldown = data.DescendCooldown - 1
            if not npc.Target then
                npc.Target = npc:GetPlayerTarget()
            end
        elseif data.DescendCooldown == 0 then
            sprite:Play(CONST.Animations.JumpDown, true)
            data.LockedPosition = npc.Target.Position
        end
        npc.Position = npc.Target.Position
        npc:SetShadowSize(
            (1 - math.min(data.DescendCooldown, CONFIG.Descend.ShadowBreakpoint) / CONFIG.Descend.ShadowBreakpoint) *
            data.DefaultShadowSize)
    elseif animName == CONST.Animations.JumpDown then
        if sprite:IsFinished() then
            data.PullingDurationLeft = CONFIG.Pulling.Duration
            Resouled.Pulling:TryEnableCustomPlayerPulling(npc, CONFIG.Pulling.Radius, CONFIG.Pulling.Color)
            sprite:Play(CONST.Animations.Stunned)
        end

        if sprite:IsEventTriggered(CONST.Events.Land) then
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
        end
    elseif animName == CONST.Animations.Stunned then
        if data.PullingDurationLeft > 0 then
            data.PullingDurationLeft = data.PullingDurationLeft - 1
        elseif data.PullingDurationLeft == 0 then
            Resouled.Pulling:TryDisableCustomPlayerPulling(npc)
            sprite:Play(CONST.Animations.JumpUp)
        end
    elseif animName == CONST.Animations.JumpUp then
        if sprite:IsEventTriggered(CONST.Events.Jump) then
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        end

        npc:SetShadowSize(
            data.DefaultShadowSize *
            (1 - sprite:GetFrame() / sprite:GetAnimationData(CONST.Animations.JumpUp):GetLength())
        )

        if sprite:IsFinished() then
            sprite:Play(CONST.Animations.Idle)
            data.LockedPosition = nil
            data.DescendCooldown = math.random(CONFIG.Descend.CooldownRange[1], CONFIG.Descend.CooldownRange[2])
        end
    elseif animName == CONST.Animations.Grab then
        if sprite:IsEventTriggered(CONST.Events.Grab) then
            Isaac.GetPlayer(data.Victim).Visible = false
        end

        if sprite:IsFinished() then
            local validRoomSafeGridIndexes = {}

            local game = Game()
            local level = game:GetLevel()
            local currentRoomSafeIndex = level:GetCurrentRoomDesc()
                .SafeGridIndex -- i get it here to exclude it from possible destination rooms
            local rooms = level:GetRooms()
            for i = 0, rooms.Size - 1 do
                local roomDesc = rooms:Get(i)
                if roomDesc.SafeGridIndex ~= currentRoomSafeIndex and CONFIG.TeleportRoomsWhitelist[roomDesc.Data.Type] then
                    table.insert(validRoomSafeGridIndexes, roomDesc.SafeGridIndex)
                end
            end

            local player = Isaac.GetPlayer(data.Victim)
            player.Visible = true

            local rng = RNG()
            rng:SetSeed(npc.DropSeed, 14) -- random shift number

            local targetRoom = validRoomSafeGridIndexes[rng:RandomInt(#validRoomSafeGridIndexes) + 1]
            game:StartRoomTransition(targetRoom, Direction.NO_DIRECTION, RoomTransitionAnim.FADE, player)
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, onNpcUpdate, CONST.Entity.Type)

---@param npc EntityNPC
---@param collider Entity
---@param low boolean
local function onNpcCollision(_, npc, collider, low)
    local player = collider:ToPlayer()
    if not player or not Resouled:MatchesEntityDesc(npc, CONST.Entity) then return end

    Resouled.Pulling:TryDisableCustomPlayerPulling(npc)
    player:AddControlsCooldown(1)
    npc:GetSprite():Play(CONST.Animations.Grab)
    npc:GetData().Resouled__Cursed_Moms_Hand.Victim = player.Index
end
Resouled:AddCallback(ModCallbacks.MC_PRE_NPC_COLLISION, onNpcCollision, CONST.Entity.Type)

Resouled.StatTracker:RegisterCursedEnemy(CONST.Entity.Type, CONST.Entity.Variant, CONST.Entity.SubType)
