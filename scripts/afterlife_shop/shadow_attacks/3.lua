Resouled:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
    if true then return end
    if Resouled.Game:GetFrameCount()%60 ~= 0 then return end
    local step = 360/10
    local offset = Vector(1, 0):Rotated(step)
    for _ = 1, 3 do
        
        Resouled:SpawnShadowProjectile(Resouled.ShadowProjectileTypes.Homing,
            Resouled.Game:GetRoom():GetCenterPos() + offset,
            offset:Resized(10),
            nil
        )

        offset = offset:Rotated(-step)
    end

    offset = Vector(-1, 0):Rotated(step)
    for _ = 1, 3 do
        
        Resouled:SpawnShadowProjectile(Resouled.ShadowProjectileTypes.Homing,
            Resouled.Game:GetRoom():GetCenterPos() + offset,
            offset:Resized(10),
            10
        )

        offset = offset:Rotated(-step)
    end
end)

---@param proj ResouledShadowProjectile
local function update(_, proj)
    if proj.Type ~= Resouled.ShadowProjectileTypes.Homing then return end
    
    if proj.FrameCount < 100 then
        local player = Isaac.GetPlayer()
        local toPlayer = player.Position - proj.Position

        proj.Velocity = (proj.Velocity + toPlayer/50):Resized(10)
    end

    Resouled.Iterators:IterateOverPlayersInArea(proj.Position, proj.Size, function(player)
        
        player:TakeDamage(1, DamageFlag.DAMAGE_NOKILL, EntityRef(nil), 0)
    end)

    proj:CheckIfShouldRemoveProjectile()
end
Resouled:AddCallback(Resouled.Callbacks.ShadowProjectileUpdate, update)

---@param proj ResouledShadowProjectile
local function render(_, proj)
    if proj.Type ~= Resouled.ShadowProjectileTypes.Homing then return end

    proj:Move()
end
Resouled:AddCallback(Resouled.Callbacks.ShadowProjectileRender, render)