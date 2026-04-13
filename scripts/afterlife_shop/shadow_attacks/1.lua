Resouled:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
    if true then return end

    if Resouled.Game:GetFrameCount()%12 ~= 0 then return end
    local playerPos = Isaac.GetPlayer().Position
    local spawnPos =  Resouled.Game:GetRoom():GetCenterPos() + Vector(200, 0):Rotated(360 * math.random())

    Resouled:SpawnShadowProjectile(Resouled.ShadowProjectileTypes.Straight,
       spawnPos,
        (playerPos - spawnPos):Resized(0.05),
        50
    )
end)

---@param proj ResouledShadowProjectile
local function init(_, proj)
    if proj.Type ~= Resouled.ShadowProjectileTypes.Straight then return end
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
    if proj.Type ~= Resouled.ShadowProjectileTypes.Straight then return end

    if proj.FrameCount < 15 then
        
        proj.Velocity = proj.Velocity * 1.2 + proj.Velocity:Resized(1)
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
    if proj.Type ~= Resouled.ShadowProjectileTypes.Straight then return end

    proj.Sprite:Render(Isaac.WorldToScreen(proj.Position))

    proj:Move()
end
Resouled:AddCallback(Resouled.Callbacks.ShadowProjectileRender, render)