Resouled:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
    if true then return end
    if Resouled.Game:GetFrameCount() % 10 ~= 0 then return end

    Resouled:SpawnShadowProjectile(Resouled.ShadowProjectileTypes.BigHomingBurst,
        Resouled.Game:GetRoom():GetCenterPos(),
        Vector.Zero,
        30
    )
end)

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
                10
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

    proj:Move()
end
Resouled:AddCallback(Resouled.Callbacks.ShadowProjectileRender, render)
