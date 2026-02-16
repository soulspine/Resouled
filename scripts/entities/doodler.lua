local game = Game()

local CONST = {
    Ent = Resouled:GetEntityByName("Resouled Doodler"),
    Anim = {
        Base = {
            Idle = {
                Name = "Idle",
                Len = 1,
            },
            WalkForward = {
                Name = "WalkForward",
                Len = 26,
            },
            WalkRight = {
                Name = "WalkRight",
                Len = 26,
            },
            WalkLeft = {
                Name = "WalkLeft",
                Len = 26,
            },
            RunForward = {
                Name = "RunForward",
                Len = 20,
            },
            RunRight = {
                Name = "RunRight",
                Len = 20,
            },
            RunLeft = {
                Name = "RunLeft",
                Len = 20,
            },
        },
        Overlay = {
            HeadDownOpen = {
                Name = "HeadDownOpen",
                Len = 1,
            },
            HeadDown = {
                Name = "HeadDown",
                Len = 1,
            },
            HeadDownLifted = {
                Name = "HeadDownLifted",
                Len = 1,
            },
        }
    }
}

---@param vel Vector
---@return string
local function getBodyAnimationFromVelocity(vel)
   
    if vel:Length() < 0.1 then
        return CONST.Anim.Base.Idle.Name
    end

    local angle = vel:GetAngleDegrees()%360
    
    if angle < 45 or angle >= 315 then
        return CONST.Anim.Base.WalkRight.Name
    elseif (angle >= 45 and angle < 135) or (angle >= 225 and angle < 315) then
        return CONST.Anim.Base.WalkForward.Name
    elseif angle >= 135 and angle < 225 then
        return CONST.Anim.Base.WalkLeft.Name
    end

    return CONST.Anim.Base.Idle.Name
end

---@param doodler EntityNPC
local function onDooderInit(_, doodler)
    if not Resouled:MatchesEntityDesc(doodler, CONST.Ent) then return end

    local sprite = doodler:GetSprite()
    sprite:Play(CONST.Anim.Base.WalkForward.Name, true)
    sprite:PlayOverlay(CONST.Anim.Overlay.HeadDown.Name, true)
    doodler:GetData().Resouled_Doodler = {}

    doodler.State = NpcState.STATE_MOVE
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_INIT, onDooderInit, CONST.Ent.Type)

---@param doodler EntityNPC
local function onDoodlerUpdate(_, doodler)
    if not Resouled:MatchesEntityDesc(doodler, CONST.Ent) then return end
    
    local playerTarget = doodler:GetPlayerTarget()
    local sprite = doodler:GetSprite()
    local room = game:GetRoom()
    local data = doodler:GetData().Resouled_Doodler
    
    doodler.Velocity = doodler.Velocity * 0.9

    local bodyAnim = getBodyAnimationFromVelocity(doodler.Velocity)
    if sprite:GetAnimation() ~= bodyAnim then
        sprite:Play(bodyAnim, true)
    end

    if doodler.State == NpcState.STATE_MOVE then
        if not data.TargetPos then data.TargetPos = Isaac.GetFreeNearPosition(room:GetRandomPosition(24), 24) end

        doodler.Pathfinder:FindGridPath(data.TargetPos, 0.75, 0, false)

        if doodler.Position:Distance(data.TargetPos) < doodler.Size + 40 then
            data.TargetPos = nil

            doodler.State = NpcState.STATE_IDLE
            data.WalkCooldown = 30
        end
    elseif doodler.State == NpcState.STATE_IDLE then
        
        if data.WalkCooldown then
            data.WalkCooldown = data.WalkCooldown - 1

            if data.WalkCooldown <= 0 then
                data.WalkCooldown = nil
                doodler.State = NpcState.STATE_MOVE
            end
        end

        doodler.Velocity = doodler.Velocity * 0.75

    end

end
Resouled:AddCallback(ModCallbacks.MC_NPC_UPDATE, onDoodlerUpdate, CONST.Ent.Type)
