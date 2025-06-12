local HUNTER_TYPE = Isaac.GetEntityTypeByName("Hunter")
local HUNTER_VARIANT = Isaac.GetEntityVariantByName("Hunter")
local HUNTER_SUBTYPE = Isaac.GetEntityTypeByName("Hunter")

local ATTACK_TYPE = Isaac.GetEntityTypeByName("COTH attack claws")
local CLAW_ATTACK_VARIANT = Isaac.GetEntityVariantByName("COTH attack claws")
local THROW_ATTACK_VARIANT = Isaac.GetEntityVariantByName("COTH attack spear")

local APPEAR = "Appear"
local IDLE = "OpenIdle"
local TELEPORT = "Teleport"
local DISAPPEAR = "Disappear"

local OPEN_TRIGGER = "ResouledOpen"
local TELEPORT_TRIGGER = "ResouledTeleport"

local TIME_BEFORE_ATTACKING = 90
local POST_TELEPORT_COOLDOWN = 15
local POST_ATTACK_DISAPPEAR_COOLDOWN = 20

---@param npc EntityNPC
local function postNpcInit(_, npc)
    if npc.Variant == HUNTER_VARIANT then
        local sprite = npc:GetSprite()
        local data = npc:GetData()

        sprite:Play("Appear", true)

        npc.DepthOffset = 1000

        npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
        npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY

        data.ResouledHunterAttack = math.random(1, 2)
        if data.ResouledHunterAttack == 1 then
            data.ResouledRandomPlayer = math.random(0, Game():GetNumPlayers()-1)
            data.ResouledRandomPlayerColor = 0
        end

        if data.ResouledHunterAttack == 2 then
            data.ResouledIndicatorBeamAlpha = 0
        end

        sprite:GetLayer(8):SetColor(Color(1, 1, 1, 0))
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_INIT, postNpcInit, HUNTER_TYPE)

---@param npc EntityNPC
local function npcUpdate(_, npc)
    if npc.Variant == HUNTER_VARIANT then
        local sprite = npc:GetSprite()
        local data = npc:GetData()

        if sprite:IsEventTriggered(OPEN_TRIGGER) then
            sprite:Play(IDLE, true)
            data.ResouledHunterWaiting = TIME_BEFORE_ATTACKING
        end

        if not sprite:IsPlaying(APPEAR) then
            Game():Darken(1, 1)
        end

        if sprite:IsPlaying(IDLE) then

            if data.ResouledHunterWaiting then
                if data.ResouledHunterWaiting > 0 then 
                    data.ResouledHunterWaiting = data.ResouledHunterWaiting - 1
                end
            end
        end

        sprite:GetLayer(4):SetPos((Game():GetNearestPlayer(npc.Position).Position - npc.Position):Normalized() * 4)

        if data.ResouledHunterWaiting then
            if data.ResouledHunterWaiting <= 0 then
                data.ResouledHunterAttacking = true
                data.ResouledHunterWaiting = nil
            end
        end

        if sprite:IsPlaying(TELEPORT) then
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        else
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
        end

        if sprite:IsEventTriggered(TELEPORT_TRIGGER) then
            local randomPlayerID
            if data.ResouledRandomPlayer then
                randomPlayerID = data.ResouledRandomPlayer
            else
                randomPlayerID = math.random(0, Game():GetNumPlayers()-1)
            end
            local player = Isaac.GetPlayer(randomPlayerID)
            local playerPos = player.Position
            local randomAngle = math.random(0, 360)
            local distanceFromPlayer = 75
                
            npc.Position = playerPos + Vector(1, 0):Normalized():Rotated(randomAngle) * distanceFromPlayer

            data.ResouledPostTeleportCooldown = POST_TELEPORT_COOLDOWN
        end

        if data.ResouledHunterAttack == 2 then
            if not data.ResouledHunterAttacking then
                
                if data.ResouledIndicatorBeamAlpha < 120 then
                    data.ResouledIndicatorBeamAlpha = data.ResouledIndicatorBeamAlpha + 1
                end
                
                sprite:GetLayer(8):SetRotation((Game():GetNearestPlayer(npc.Position).Position - npc.Position):Normalized():GetAngleDegrees() + (math.random() * math.random(-1, 1)))
                sprite:GetLayer(8):SetColor(Color(1, 1, 1, data.ResouledIndicatorBeamAlpha/120))
            else
                if data.ResouledIndicatorBeamAlpha then
                    if data.ResouledIndicatorBeamAlpha > 0 then
                        data.ResouledIndicatorBeamAlpha = data.ResouledIndicatorBeamAlpha - 6
                        sprite:GetLayer(8):SetColor(Color(1, 1, 1, data.ResouledIndicatorBeamAlpha/120))
                    end
                end
            end
        end

        if data.ResouledRandomPlayer then
            data.ResouledRandomPlayerColor = data.ResouledRandomPlayerColor - 0.005
            local player = Isaac.GetPlayer(data.ResouledRandomPlayer)
            player.Color = Color(player.Color.R, player.Color.G, player.Color.B, player.Color.A, data.ResouledRandomPlayerColor, data.ResouledRandomPlayerColor, data.ResouledRandomPlayerColor)
        end

        if data.ResouledPostTeleportCooldown then
            if data.ResouledPostTeleportCooldown > 0 then
                data.ResouledPostTeleportCooldown = data.ResouledPostTeleportCooldown - 1
            end
        end

        if sprite:IsFinished(TELEPORT) then
            sprite:Play(IDLE, true)
        end

        if data.ResouledHunterAttacking then
            if data.ResouledHunterAttack == 1 then
                if data.ResouledPostTeleportCooldown == nil and not sprite:IsPlaying(TELEPORT) then
                    sprite:Play(TELEPORT, true)
                    local player = Isaac.GetPlayer(data.ResouledRandomPlayer)
                    player.Color = Color(player.Color.R, player.Color.G, player.Color.B, player.Color.A, 0, 0, 0)
                    data.ResouledRandomPlayer = nil
                end
  
                if data.ResouledPostTeleportCooldown then
                    if data.ResouledPostTeleportCooldown <= 0 then
                        Game():Spawn(ATTACK_TYPE, CLAW_ATTACK_VARIANT, npc.Position, Vector.Zero, npc, 0, npc.InitSeed)
                        data.ResouledHunterAttacking = nil
                        data.ResouledHunterAttack = nil
                        data.ResouledPostAttackCooldown = POST_ATTACK_DISAPPEAR_COOLDOWN
                    end
                end
            end

            if data.ResouledHunterAttack == 2 then
                Game():Spawn(ATTACK_TYPE, THROW_ATTACK_VARIANT, npc.Position, Vector.Zero, npc, 0, npc.InitSeed)
                data.ResouledHunterAttacking = nil
                data.ResouledHunterAttack = nil
                data.ResouledPostAttackCooldown = POST_ATTACK_DISAPPEAR_COOLDOWN
            end
        end

        if data.ResouledPostAttackCooldown then
            if data.ResouledPostAttackCooldown > 0 then
                data.ResouledPostAttackCooldown = data.ResouledPostAttackCooldown - 1
            end

            if data.ResouledPostAttackCooldown <= 0 then
                sprite:Play(DISAPPEAR, true)
                data.ResouledPostAttackCooldown = nil
            end
        end

        if sprite:IsFinished(DISAPPEAR) then
            npc:Remove()
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_NPC_UPDATE, npcUpdate, HUNTER_TYPE)