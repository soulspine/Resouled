local FLY_TYPE = Isaac.GetEntityTypeByName("Blank Canvas Fly")
local FLY_VARIANT = Isaac.GetEntityVariantByName("Blank Canvas Fly")

local VELOCITY_MULTIPLIER = 0.75

local IDLE = "Idle"
local DEATH = "Death"

---@param npc EntityNPC
local function postNpcInit(_, npc)
    if npc.Variant == FLY_VARIANT then
        local sprite = npc:GetSprite()
        sprite:Play(IDLE, true)
        npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
        npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_INIT, postNpcInit, FLY_TYPE)

---@param npc EntityNPC
local function npcUpdate(_, npc)
    if npc.Variant == FLY_VARIANT then
        local sprite = npc:GetSprite()
        npc.Pathfinder:MoveRandomly(false)
        if not sprite:IsPlaying(DEATH) then
            npc.Velocity = (npc.Velocity + (npc:GetPlayerTarget().Position - npc.Position):Normalized()) * VELOCITY_MULTIPLIER
        else
            npc.Velocity = npc.Velocity * VELOCITY_MULTIPLIER
        end

        if sprite:IsFinished(DEATH) then
            npc:Die()
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_NPC_UPDATE, npcUpdate, FLY_TYPE)

---@param entity Entity
local function entityTakeDamage(_, entity, amount)
    if entity.Variant == FLY_VARIANT then
        if entity.HitPoints - amount <= 0 then
            entity:GetSprite():Play(DEATH, true)
            entity.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
            entity.CollisionDamage = 0
            SFXManager():Play(SoundEffect.SOUND_MENU_NOTE_HIDE, 10)
            return false
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, entityTakeDamage, FLY_TYPE)