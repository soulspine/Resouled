Resouled:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
    if true then return end
    if Resouled.Game:GetFrameCount() % 60 ~= 0 then return end

    Resouled:SpawnShadowProjectile(Resouled.ShadowProjectileTypes.BigHomingBurst,
        Resouled.Game:GetRoom():GetCenterPos(),
        Vector.Zero,
        60
    )
end)

---@param proj ResouledShadowProjectile
local function init(_, proj)
    if proj.Type ~= Resouled.ShadowProjectileTypes.BigHomingBurst then return end
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
    if proj.Type ~= Resouled.ShadowProjectileTypes.BigHomingBurst then return end
    local speed = 1 - math.log(proj.FrameCount/2 + 1, 3)/math.log(60, 3)
    proj.Velocity = (Isaac.GetPlayer().Position - proj.Position):Resized(20 * speed)

    if proj.FrameCount == 120 then

        local velocity = Vector(0.1, 0)
        for _ = 1, 8 do
            
            Resouled:SpawnShadowProjectile(Resouled.ShadowProjectileTypes.Straight,
                proj.Position,
                velocity,
                20
            )

            velocity = velocity:Rotated(360/8)
        end

        proj:Remove()
    end
end
Resouled:AddCallback(Resouled.Callbacks.ShadowProjectileUpdate, update)

---@param proj ResouledShadowProjectile
local function render(_, proj)
    if proj.Type ~= Resouled.ShadowProjectileTypes.BigHomingBurst then return end

    proj.Sprite:Render(Isaac.WorldToScreen(proj.Position))

    proj:Move()
end
Resouled:AddCallback(Resouled.Callbacks.ShadowProjectileRender, render)
