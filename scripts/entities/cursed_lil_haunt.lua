local ID = Isaac.GetEntityTypeByName("Cursed Lil Haunt")
local VARIANT = Isaac.GetEntityVariantByName("Cursed Lil Haunt")
local SUBTYPE = Isaac.GetEntitySubTypeByName("Cursed Lil Haunt")

local TP_UP = "ResouledTeleportUp"
local TP_DOWN = "ResouledTeleportDown"
local TP_UP_END = "ResouledTeleportUpEnd"
local TP_DOWN_END = "ResouledTeleportDownEnd"

local DISTANCE_TO_TELEPORT = 150
local POST_TELEPORT_DISTANCE = 125

local PROJECTILE_PARAMS = ProjectileParams()
PROJECTILE_PARAMS.Color = Color(0.5, 0, 0.75, 1, 0.5 * 0.55, 0, 0.75 * 0.55)
PROJECTILE_PARAMS.Variant = ProjectileVariant.PROJECTILE_TEAR
local PROJECTILE_SPEED = 10

local DEFAULT_ENTITY_COLLISION_CLASS = EntityCollisionClass.ENTCOLL_ALL

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
            SFXManager():Play(SoundEffect.SOUND_HELL_PORTAL2)
            sprite:Play("TeleportUp", true)
        end

        if sprite:IsPlaying("TeleportUp") or sprite:IsPlaying("TeleportDown") then
            npc.Velocity = Vector.Zero
        end
        
        if sprite:IsEventTriggered(TP_UP) then
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        end
        
        if sprite:IsEventTriggered(TP_UP_END) then
            npc.Position = player.Position + player.Velocity:Resized(POST_TELEPORT_DISTANCE)
            sprite:Play("TeleportDown", true)
        end

        if sprite:IsEventTriggered(TP_DOWN_END) then
            npc.State = NpcState.STATE_IDLE
        end
        
        if sprite:IsEventTriggered(TP_DOWN) then
            npc.EntityCollisionClass = DEFAULT_ENTITY_COLLISION_CLASS
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_NPC_UPDATE, onNpcUpdate, ID)