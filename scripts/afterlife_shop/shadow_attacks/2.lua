Resouled:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
    if true then return end
    local player = Isaac.GetPlayer()
    local spawnPos = Resouled.Game:GetRoom():GetCenterPos()
    for _ = 1, 3 do
        local playerPos = player.Position + player.Velocity * player.Position:Distance(spawnPos)/10
        local rotation = (math.random() - 0.5) * 270
        
        local proj = Resouled:SpawnShadowProjectile(Resouled.ShadowProjectileTypes.Beam,
            spawnPos,
            (playerPos - spawnPos):Resized(5):Rotated(rotation),
            10 + (270/2 - math.abs(rotation))/4
        )
        proj.Data = {
            OriginalRotation = math.abs(rotation),
            RotationLeft = math.abs(rotation),
            Mult = rotation > 0 and -1 or 1,
            Active = true
        }
    end
end)

---@param proj ResouledShadowProjectile
local function init(_, proj)
    if proj.Type ~= Resouled.ShadowProjectileTypes.Beam then return end
    local sprite = proj.Sprite
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

    local scale = math.min(proj.FrameCount, 15)/15
    sprite.Scale.X = scale
    sprite.Scale.Y = scale
    sprite.Color.A = scale

    if data.Active then
        local rotation = math.min(data.OriginalRotation/10, data.RotationLeft)
        proj.Velocity = proj.Velocity:Rotated(rotation * data.Mult)
        data.RotationLeft = data.RotationLeft - rotation

        if data.RotationLeft == 0 then data.Active = nil end
    end

    Resouled.Iterators:IterateOverPlayersInArea(proj.Position, proj.Size, function(player)
        
        player:TakeDamage(1, DamageFlag.DAMAGE_NOKILL, EntityRef(nil), 0)
    end)

    proj:CheckIfShouldRemoveProjectile()
end
Resouled:AddCallback(Resouled.Callbacks.ShadowProjectileUpdate, update)

---@param proj ResouledShadowProjectile
local function render(_, proj)
    if proj.Type ~= Resouled.ShadowProjectileTypes.Beam then return end

    local pos = Isaac.WorldToScreen(proj.Position)
    local mult = math.min(proj.FrameCount/15, 1)
    Isaac.DrawLine(pos, pos - proj.Velocity * (mult * mult) * 2.5, KColor(0, 0, 0, mult/2), KColor(0, 0, 0, 0), proj.Size * mult / 3)

    proj:Move()
end
Resouled:AddCallback(Resouled.Callbacks.ShadowProjectileRender, render)
