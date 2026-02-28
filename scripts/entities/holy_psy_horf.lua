local HOLY_PSY_HORF_TYPE = Isaac.GetEntityTypeByName("Holy Psy Horf")
local HOLY_PSY_HORF_VARIANT = Isaac.GetEntityVariantByName("Holy Psy Horf")
local HOLY_PSY_HORF_SUBTYPE = Isaac.GetEntitySubTypeByName("Holy Psy Horf")

local ATTACK_COOLDOWN = 50

local LASER_TIMEOUT = 5

---@param npc EntityNPC
local function postNpcInit(_, npc)
    if npc.Variant == HOLY_PSY_HORF_VARIANT and npc.SubType == HOLY_PSY_HORF_SUBTYPE then
        local sprite = npc:GetSprite()
        local data = npc:GetData()

        npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
        
        data.Resouled_Attack = {
            Cooldown = ATTACK_COOLDOWN,
            Count = 0,
        }

        sprite:Play("Appear", true)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_INIT, postNpcInit, HOLY_PSY_HORF_TYPE)

---@param npc EntityNPC
local function onNpcUpdate(_, npc)
    if npc.Variant == HOLY_PSY_HORF_VARIANT and npc.SubType == HOLY_PSY_HORF_SUBTYPE then
        local sprite = npc:GetSprite()
        local data = npc:GetData()

        npc.Velocity = npc.Velocity * 0.25

        if sprite:IsFinished("Appear") then
            sprite:Play("Idle", true)
        end

        if sprite:IsFinished("TeleportDown") then
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
            sprite:Play("Idle", true)
        end

        if sprite:IsFinished("Attack") then
            if data.Resouled_Attack.Count >= 2 then
                sprite:Play("TeleportUp", true)
                SFXManager():Play(SoundEffect.SOUND_HELL_PORTAL1)
                npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
                data.Resouled_Attack.Count = 0
            else
                sprite:Play("Idle", true)
            end
        end

        if sprite:IsEventTriggered("Teleport") then
            ::RollPos::
            local newPos = Isaac.GetFreeNearPosition(Game():GetRoom():GetRandomPosition(0), 0)
            if newPos:Distance(npc:GetPlayerTarget().Position) < 100 then
                goto RollPos
            end
            npc.Position = newPos
        end

        if sprite:IsFinished("TeleportUp") then
            SFXManager():Play(SoundEffect.SOUND_HELL_PORTAL2)
            sprite:Play("TeleportDown", true)
        end

        if not data.Resouled_Attack.Cooldown and not sprite:IsPlaying("Attack") then
            sprite:Play("Attack", true)
            data.Resouled_Attack.Count = data.Resouled_Attack.Count + 1
        end

        if data.Resouled_Attack.Cooldown and not sprite:IsPlaying("Attack") then
            data.Resouled_Attack.Cooldown = data.Resouled_Attack.Cooldown - 1
            if data.Resouled_Attack.Cooldown <= 0 then
                data.Resouled_Attack.Cooldown = nil
            end
        end

        if sprite:IsEventTriggered("Laser") then
            local toTargetVector = npc:GetPlayerTarget().Position - npc.Position - npc:GetPlayerTarget().Velocity * 10
            data.Resouled_Laser = Game():Spawn(EntityType.ENTITY_LASER, LaserVariant.LIGHT_BEAM, npc.Position + Vector(0, 1) + toTargetVector:Resized(10), Vector.Zero, npc, 0, npc.InitSeed):ToLaser()
            data.Resouled_Laser.PositionOffset = Vector(0, -40)
            data.Resouled_Laser.DepthOffset = npc.DepthOffset + 100
            data.Resouled_Laser:SetTimeout(LASER_TIMEOUT)
            data.Resouled_Laser:SetColor(Color(0.65, 0.65, 1, 0.75, 0.75, 0.75, 0.75), 99999, 10000, false, false)
            data.Resouled_Laser.Angle = toTargetVector:GetAngleDegrees()
            data.Resouled_Laser:GetData().Resouled_DamagePlayer = true
        end

        if data.Resouled_Laser and sprite:IsEventTriggered("LaserDie") then
            data.Resouled_Attack.Cooldown = ATTACK_COOLDOWN
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_NPC_UPDATE, onNpcUpdate, HOLY_PSY_HORF_TYPE)

---@param entity Entity
---@param amount number
local function entityTakeDmg(_, entity, amount)
    if entity.Variant == HOLY_PSY_HORF_VARIANT and entity.SubType == HOLY_PSY_HORF_SUBTYPE and entity.HitPoints - amount <= 0 then
        if entity:GetData().Resouled_Laser then
            entity:GetData().Resouled_Laser:SetTimeout(1)
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, entityTakeDmg, HOLY_PSY_HORF_TYPE)

---@param laser EntityLaser
---@param collider Entity
local function preLaserCollision(_, laser, collider)
    local data = laser:GetData()
    if data.Resouled_DamagePlayer and not collider:ToPlayer() then
        return true
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_LASER_COLLISION, preLaserCollision)