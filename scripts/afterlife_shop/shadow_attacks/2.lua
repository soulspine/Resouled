local MAX_SPREAD = 180
local SMALLEST_PROJECTILE_SIZE = 10
local PROJECTILE_COUNT = 8
local BEAM_SIZE = 1.5

Resouled:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
    if true then return end
    local player = Isaac.GetPlayer()
    local spawnPos = Resouled.Game:GetRoom():GetCenterPos()
    for _ = 1, PROJECTILE_COUNT do
        local playerPos = player.Position + player.Velocity * player.Position:Distance(spawnPos)/20
        local rotation = (math.random() - 0.5) * MAX_SPREAD
        
        local proj = Resouled:SpawnShadowProjectile(Resouled.ShadowProjectileTypes.Beam,
            spawnPos,
            (playerPos - spawnPos):Resized(5):Rotated(rotation),
            SMALLEST_PROJECTILE_SIZE + ((MAX_SPREAD/2 - math.abs(rotation))/4) ^ 1.5
        )

        local data = proj.Data
        data.OriginalRotation = math.abs(rotation)/BEAM_SIZE
        data.RotationLeft = math.abs(rotation)
        data.Mult = rotation > 0 and -1 or 1
        data.Active = true
        data.ExtraSpeed = 1 + math.random()/2
    end
end)

---@param proj ResouledShadowProjectile
local function init(_, proj)
    if proj.Type ~= Resouled.ShadowProjectileTypes.Beam then return end
    local sprite = proj.Sprite
    sprite:Load("gfx_resouled/misc/shadow_projectile.anm2", true)
    sprite:Play("Idle", true)
    sprite.Scale.X = 0
    sprite.Scale.Y = 0
    sprite.Color.A = 0
end
Resouled:AddCallback(Resouled.Callbacks.ShadowProjectileInit, init)

---@param proj ResouledShadowProjectile
local function update(_, proj)
    if proj.Type ~= Resouled.ShadowProjectileTypes.Beam then return end
    local data = proj.Data
    local sprite = proj.Sprite

    if proj.FrameCount < 10 then
        proj.Velocity = proj.Velocity * 1.2
    end

    local mult = math.min(proj.FrameCount, 15)/15
    local sizeMult = mult/2 * proj.Size/SMALLEST_PROJECTILE_SIZE
    sprite.Scale.X = sizeMult
    sprite.Scale.Y = sizeMult
    sprite.Color.A = mult

    if data.Active then
        local rotation = math.min(data.OriginalRotation/10, data.RotationLeft)
        proj.Velocity = proj.Velocity:Rotated(rotation * data.Mult)
        data.RotationLeft = data.RotationLeft - rotation

        if data.RotationLeft == 0 then data.Active = nil end
    else
        if proj.FrameCount < 17 then
            proj.Velocity = proj.Velocity * data.ExtraSpeed
        end
    end

    Resouled.Iterators:IterateOverPlayers(function(player)

        if proj.Position:Distance(player.Position) < math.max(25 + proj.Size * 1.5, 75) then
            --proj:Remove()
            return
        end

        if proj:IsTouchingPlayer(player) then
            player:TakeDamage(1, DamageFlag.DAMAGE_NOKILL, EntityRef(nil), 0)
        end
    end)
end
Resouled:AddCallback(Resouled.Callbacks.ShadowProjectileUpdate, update)

---@param proj ResouledShadowProjectile
local function render(_, proj)
    if proj.Type ~= Resouled.ShadowProjectileTypes.Beam then return end

    local pos = Isaac.WorldToScreen(proj.Position)
    local mult = math.min(proj.FrameCount/15, 1)
    Isaac.DrawLine(pos, pos - proj.Velocity:Resized(math.min(proj.Velocity:Length()/1.5, 40)) * (mult * mult) * 2.5, KColor(0, 0, 0, mult), KColor(0, 0, 0, 0), SMALLEST_PROJECTILE_SIZE * proj.Size/SMALLEST_PROJECTILE_SIZE/2 * math.min(proj.FrameCount, 15)/15)

    proj.Sprite:Render(pos)

    proj:Move()
end
Resouled:AddCallback(Resouled.Callbacks.ShadowProjectileRender, render)
