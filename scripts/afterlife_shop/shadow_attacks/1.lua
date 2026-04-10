Resouled:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
    if true then return end

    if Resouled.Game:GetFrameCount()%30 ~= 0 then return end
    local playerPos = Isaac.GetPlayer().Position
    local spawnPos =  Resouled.Game:GetRoom():GetCenterPos() + Vector(200, 0):Rotated(360 * math.random())

    Resouled:SpawnShadowProjectile(Resouled.ShadowProjectileTypes.Straight,
       spawnPos,
        (playerPos - spawnPos):Resized(0.05),
        25
    )
end)

---@param proj ResouledShadowProjectile
local function update(_, proj)
    if proj.Type ~= Resouled.ShadowProjectileTypes.Straight then return end

    if proj.FrameCount < 15 then
        
        proj.Velocity = proj.Velocity * 1.2 + proj.Velocity:Resized(1)
    end

    Resouled.Iterators:IterateOverPlayersInArea(proj.Position, proj.Size, function(player)
        
        player:TakeDamage(1, DamageFlag.DAMAGE_NOKILL, EntityRef(nil), 0)
    end)

    --proj.Position = proj.Position + proj.Velocity

    proj:CheckIfShouldRemoveProjectile()
end
Resouled:AddCallback(Resouled.Callbacks.ShadowProjectileUpdate, update)

---@param proj ResouledShadowProjectile
local function render(_, proj)
    if proj.Type ~= Resouled.ShadowProjectileTypes.Straight then return end

    proj:Move()
end
Resouled:AddCallback(Resouled.Callbacks.ShadowProjectileRender, render)