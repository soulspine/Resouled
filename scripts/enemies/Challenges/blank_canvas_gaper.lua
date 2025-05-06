local GAPER_TYPE = Isaac.GetEntityTypeByName("Blank Canvas Gaper")
local GAPER_VARIANT = Isaac.GetEntityVariantByName("Blank Canvas Gaper")

local IDLE = "Idle"
local WALK = "Walk"
local FLIP = "Flip"
local DEATH = "Death"

local FLIP_TRIGGER = "ResouledFlip"
local FLIP_START_TRIGGER = "ResouledFlip"
local CAN_FLIP_CHECK = "ResouledCanFlip"

local VELOCITY_MULTIPLIER = 0.75

---@param npc EntityNPC
local function postNpcInit(_, npc)
    if npc.Variant == GAPER_VARIANT then
        local sprite = npc:GetSprite()
        sprite:Play(IDLE, true)
        npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_INIT, postNpcInit, GAPER_TYPE)

---@param npc EntityNPC
local function npcUpdate(_, npc)
    if npc.Variant == GAPER_VARIANT then
        local sprite = npc:GetSprite()

        if sprite:IsFinished(DEATH) then
            npc:Die()
        end

        if npc.Velocity:LengthSquared() < 0.01 and not sprite:IsPlaying(IDLE) and not sprite:IsPlaying(FLIP) and not sprite:IsPlaying(DEATH) then
            sprite:Play(IDLE, true)
        elseif npc.Velocity:LengthSquared() > 0.01 and not sprite:IsPlaying(WALK) and not sprite:IsPlaying(FLIP) and not sprite:IsPlaying(DEATH) then
            sprite:Play(WALK, true)
        end

        if npc:GetPlayerTarget().Position.X - npc.Position.X > 0 and sprite.FlipX and not sprite:IsPlaying(FLIP) and sprite:IsEventTriggered(CAN_FLIP_CHECK) and not sprite:IsPlaying(DEATH) then
            sprite:Play(FLIP, true)
        elseif npc:GetPlayerTarget().Position.X - npc.Position.X < 0 and not sprite.FlipX and not sprite:IsPlaying(FLIP) and sprite:IsEventTriggered(CAN_FLIP_CHECK) and not sprite:IsPlaying(DEATH) then
            sprite:Play(FLIP, true)
        end

        if sprite:IsEventTriggered("FlipStep") and not sprite:IsPlaying(DEATH) then
            sprite:Play(FLIP, true)
        end

        if sprite:IsEventTriggered(FLIP_TRIGGER) and not sprite:IsPlaying(DEATH) then
            if sprite.FlipX then
                sprite.FlipX = false
            else
                sprite.FlipX = true
            end
        end

        if sprite:IsEventTriggered(FLIP_START_TRIGGER) and not sprite:IsPlaying(DEATH) then
            SFXManager():Play(SoundEffect.SOUND_PAPER_OUT)
        end

        if not sprite:IsPlaying(DEATH) then
            npc.Velocity = (npc.Velocity + (npc:GetPlayerTarget().Position - npc.Position):Normalized()) * VELOCITY_MULTIPLIER
        else
            npc.Velocity = npc.Velocity * VELOCITY_MULTIPLIER
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_NPC_UPDATE, npcUpdate, GAPER_TYPE)

---@param entity Entity
local function entityTakeDamage(_, entity, amount)
    if entity.Variant == GAPER_VARIANT then
        if entity.HitPoints - amount <= 0 then
            entity:GetSprite():Play(DEATH, true)
            entity.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
            entity.CollisionDamage = 0
            SFXManager():Play(SoundEffect.SOUND_MENU_NOTE_HIDE, 10)
            return false
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, entityTakeDamage, GAPER_TYPE)