Resouled:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
    if true then return end
    if Resouled.Game:GetFrameCount()%90 ~= 0 then return end
    local step = 360/10
    local offset = Vector(1, 0):Rotated(step)
    for _ = 1, 3 do
        
        Resouled:SpawnShadowProjectile(Resouled.ShadowProjectileTypes.Homing,
            Resouled.Game:GetRoom():GetCenterPos() + offset,
            offset:Resized(10),
            20
        )

        offset = offset:Rotated(-step)
    end

    offset = Vector(-1, 0):Rotated(step)
    for _ = 1, 3 do
        
        Resouled:SpawnShadowProjectile(Resouled.ShadowProjectileTypes.Homing,
            Resouled.Game:GetRoom():GetCenterPos() + offset,
            offset:Resized(10),
            20
        )

        offset = offset:Rotated(-step)
    end
end)

---@param proj ResouledShadowProjectile
local function init(_, proj)
    if proj.Type ~= Resouled.ShadowProjectileTypes.Homing then return end
    local sprite = proj.Sprite
    sprite:Load("gfx_resouled/misc/shadow_projectile.anm2", true)
    sprite:Play("Idle", true)
    local scale = proj.Size/32
    sprite.Scale.X = scale
    sprite.Scale.Y = scale
end
Resouled:AddCallback(Resouled.Callbacks.ShadowProjectileInit, init)

---@param proj ResouledShadowProjectile
local function update(_, proj)
    if proj.Type ~= Resouled.ShadowProjectileTypes.Homing then return end
    
    if proj.FrameCount < 100 then
        local player = Isaac.GetPlayer()
        local toPlayer = player.Position - proj.Position

        proj.Velocity = (proj.Velocity + toPlayer/50):Resized(10)
    end

    Resouled.Iterators:IterateOverPlayers(function(player)
        
        if proj:IsTouchingPlayer(player) then
            player:TakeDamage(1, DamageFlag.DAMAGE_NOKILL, EntityRef(nil), 0)
        end
    end)
end
Resouled:AddCallback(Resouled.Callbacks.ShadowProjectileUpdate, update)

---@param proj ResouledShadowProjectile
local function render(_, proj)
    if proj.Type ~= Resouled.ShadowProjectileTypes.Homing then return end

    proj.Sprite:Render(Isaac.WorldToScreen(proj.Position))

    proj:Move()
end
Resouled:AddCallback(Resouled.Callbacks.ShadowProjectileRender, render)