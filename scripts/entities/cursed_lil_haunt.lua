local ID = Isaac.GetEntityTypeByName("Cursed Lil Haunt")
local VARIANT = Isaac.GetEntityVariantByName("Cursed Lil Haunt")
local SUBTYPE = Isaac.GetEntitySubTypeByName("Cursed Lil Haunt")

Resouled:RegisterCursedEnemyMorph(ID, 10, nil, ID, VARIANT, SUBTYPE)

local TP_UP = "ResouledTeleportUp"
local TP_DOWN = "ResouledTeleportDown"
local TP_UP_END = "ResouledTeleportUpEnd"
local TP_DOWN_END = "ResouledTeleportDownEnd"

local DISTANCE_TO_TELEPORT = 150
local POST_TELEPORT_DISTANCE = 125

local PROJECTILE_PARAMS = Resouled.Stats:GetCursedProjectileParams()
local PROJECTILE_SPEED = 10

local DEFAULT_ENTITY_COLLISION_CLASS = EntityCollisionClass.ENTCOLL_ALL

---@param pos Vector
---@param velocity Vector
---@param rotation number
local function createSmoke(pos, velocity, rotation, alpha, size)
    local smoke = Game():Spawn(EntityType.ENTITY_EFFECT, EffectVariant.DARK_BALL_SMOKE_PARTICLE, pos, velocity:Rotated(rotation), nil, 0, Random() + 1):ToEffect()
    smoke.Timeout = 100
    smoke.SpriteOffset = Vector(0, -16)
    smoke.Color = Color(1, 1, 1, alpha, 0.5, 0, 1)
    smoke.SpriteScale = Vector(size, size)
end

local SMOKE_AMOUNT = 5
local SMOKE_SPEED = 5
local SMOKE_SIZE = 1
local SMOKE_ALPHA = 0.25

---@param npc EntityNPC
local function doTpSmoke(npc)
    for i = 0, SMOKE_AMOUNT - 1 do
        createSmoke(npc.Position, Vector(0, SMOKE_SPEED), (360/SMOKE_AMOUNT) * i, SMOKE_ALPHA, SMOKE_SIZE)
    end
end

---@param npc EntityNPC
local function onNpcUpdate(_, npc)
    if npc.Variant == VARIANT and npc.SubType == SUBTYPE then
        local sprite = npc:GetSprite()
        local player = npc:GetPlayerTarget()

        if sprite:IsEventTriggered("ResouledShoot")  then
            npc:FireProjectiles(npc.Position, (player.Position - npc.Position):Resized(PROJECTILE_SPEED), 0, PROJECTILE_PARAMS)
            SFXManager():Play(SoundEffect.SOUND_WORM_SPIT, nil, nil, nil, 1.25)
        end
        
        if sprite:IsFinished("Shoot") then
            npc.State = NpcState.STATE_IDLE
        end

        if player.Position:Distance(npc.Position) >= DISTANCE_TO_TELEPORT and not sprite:IsPlaying("TeleportUp") and not sprite:IsPlaying("TeleportDown") then
            npc.State = NpcState.STATE_SPECIAL
            SFXManager():Play(SoundEffect.SOUND_HELL_PORTAL2, 0.75)
            sprite:Play("TeleportUp", true)
        end

        if sprite:IsPlaying("TeleportUp") or sprite:IsPlaying("TeleportDown") then
            npc.Velocity = Vector.Zero
        end
        
        if sprite:IsEventTriggered(TP_UP) then
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
            doTpSmoke(npc)
        end
        
        if sprite:IsEventTriggered(TP_DOWN) then
            npc.EntityCollisionClass = DEFAULT_ENTITY_COLLISION_CLASS
            doTpSmoke(npc)
        end

        if sprite:IsEventTriggered(TP_UP_END) then
            npc.Position = player.Position + player.Velocity:Resized(POST_TELEPORT_DISTANCE)
            sprite:Play("TeleportDown", true)
        end

        if sprite:IsEventTriggered(TP_DOWN_END) then
            npc.State = NpcState.STATE_IDLE
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_NPC_UPDATE, onNpcUpdate, ID)

Resouled.StatTracker:RegisterCursedEnemy(ID, VARIANT, SUBTYPE)