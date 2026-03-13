local g = Resouled.Game

Resouled.AfterlifeShop.ShadowFight = {

    Active = false,

    MaxOverlayEndTimout = 200,
    OverlayEndOffset = 550,
    MaxOverlayStartTimeout = 30
}
local config = Resouled.AfterlifeShop.ShadowFight

config.RoomTransitionFunctions = {}
config.RoomTransitionFunctions.Start = {} --Animation before entering the room
config.RoomTransitionFunctions.Middle = {} --Entering the room
config.RoomTransitionFunctions.End = {} --Entered the room

function config.RoomTransitionFunctions.Start.Begin()
    Resouled.Iterators:IterateOverPlayers(function(player)
        player:AnimateSad()
    end)

    config.CurrentOverlayTimout = config.MaxOverlayStartTimeout

    Resouled:AddCallback(ModCallbacks.MC_POST_UPDATE, config.RoomTransitionFunctions.Start.OverlayScreenUpdate)
    Resouled:AddCallback(ModCallbacks.MC_POST_RENDER, config.RoomTransitionFunctions.Start.OverlayScreenRender)
end

function config.RoomTransitionFunctions.Start.OverlayScreenUpdate()
    config.CurrentOverlayTimout = math.max(config.CurrentOverlayTimout - 1, 0)
    if config.CurrentOverlayTimout == 0 then

        config.RoomTransitionFunctions.Middle.Enter()

        Resouled:RemoveCallback(ModCallbacks.MC_POST_UPDATE, config.RoomTransitionFunctions.Start.OverlayScreenUpdate)
    end
end

function config.RoomTransitionFunctions.Start.OverlayScreenRender()
    local x = config.MaxOverlayStartTimeout ^ 2
    Resouled:OverlayScreen(KColor(0, 0, 0, (x - config.CurrentOverlayTimout ^ 2)/x))
end

function config.RoomTransitionFunctions.Middle.Enter()
    config.CurrentOverlayTimout = config.MaxOverlayEndTimout

    Resouled:RemoveCallback(ModCallbacks.MC_POST_UPDATE, config.RoomTransitionFunctions.Start.OverlayScreenUpdate)
    Resouled:RemoveCallback(ModCallbacks.MC_POST_RENDER, config.RoomTransitionFunctions.Start.OverlayScreenRender)

    Resouled:AddCallback(ModCallbacks.MC_POST_RENDER, config.RoomTransitionFunctions.Middle.OverlayScreen)
    Resouled:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, config.RoomTransitionFunctions.End.Start)

    config.Active = true

    Isaac.ExecuteCommand("goto d.124")
end

local blackColor = KColor(0, 0, 0, 1)
function config.RoomTransitionFunctions.Middle.OverlayScreen()
    Resouled:OverlayScreen(blackColor)
end

function config.RoomTransitionFunctions.End.Start()
    local room = g:GetRoom()
    local center = room:GetCenterPos()

    Resouled.Iterators:IterateOverPlayers(function(player)
        player.Position = center
        player:AnimateAppear()
    end)

    ---@param pickup EntityPickup
    Resouled.Iterators:IterateOverRoomPickups(function(pickup)
        pickup:Remove()
    end)

    config.CurrentOverlayTimout = config.MaxOverlayEndTimout

    Resouled:AddCallback(ModCallbacks.MC_POST_UPDATE, config.RoomTransitionFunctions.End.OverlayScreenUpdate)
    Resouled:AddCallback(ModCallbacks.MC_POST_RENDER, config.RoomTransitionFunctions.End.OverlayScreenRender)
    Resouled:RemoveCallback(ModCallbacks.MC_POST_RENDER, config.RoomTransitionFunctions.Middle.OverlayScreen)
    Resouled:RemoveCallback(ModCallbacks.MC_POST_NEW_ROOM, config.RoomTransitionFunctions.End.Start)
end

function config.RoomTransitionFunctions.End.OverlayScreenUpdate()
    config.CurrentOverlayTimout = math.max(config.CurrentOverlayTimout - 1, 0)
    if config.CurrentOverlayTimout == 0 then
        Resouled:RemoveCallback(ModCallbacks.MC_POST_UPDATE, config.RoomTransitionFunctions.End.OverlayScreenUpdate)
    end
end

function config.RoomTransitionFunctions.End.OverlayScreenRender()
    if not g:IsPaused() then
    local room = g:GetRoom()
    local camera = room:GetCamera()
    camera:SetFocusPosition(Isaac.GetPlayer().Position)
        camera:Update()
    end
    Resouled:OverlayScreen(KColor(0, 0, 0, ((config.CurrentOverlayTimout ^ 2) + config.OverlayEndOffset)/(config.MaxOverlayEndTimout ^ 2)))
    if config.CurrentOverlayTimout == 0 then
        Resouled:RemoveCallback(ModCallbacks.MC_POST_RENDER, config.RoomTransitionFunctions.End.OverlayScreenRender)
    end
end

function Resouled.AfterlifeShop:TeleportToShadowBossfight()
    config.RoomTransitionFunctions.Start.Begin()
end

Resouled:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function()
    config.CurrentOverlayTimout = 0
    config.Active = false
end)



local shadowProjectileConfig = {
    Scale = 0,
    Color = Color(0.2, 0.2, 0.2, 0.1, 0.5, 0.5, 0.5),
    FallingAccel = -0.1,
    FallingSpeed = 0,
    
    Animation = "RegularTear5"
}
---@return EntityProjectile | nil
local function spawnShadowProjectile(pos, vel)
    local p = g:Spawn(EntityType.ENTITY_PROJECTILE, ProjectileVariant.PROJECTILE_TEAR, pos, Vector.Zero, nil, 0, Resouled:NewSeed()):ToProjectile()
    if not p then return nil end
    p.Velocity = vel
    p.Scale = shadowProjectileConfig.Scale
    p.Color = shadowProjectileConfig.Color
    p.FallingAccel = shadowProjectileConfig.FallingAccel
    p.FallingSpeed = shadowProjectileConfig.FallingSpeed
    p:AddProjectileFlags(ProjectileFlags.NO_WALL_COLLIDE)

    p:GetData().Resouled_AfterlifeShadowProjectile = true

    return p
end

---@param p EntityProjectile
Resouled:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, function(_, p)
    if not p:GetData().Resouled_AfterlifeShadowProjectile then return end

    if p.FrameCount > 500 then p:Remove() end

    local sprite = p:GetSprite()
    if not sprite:IsPlaying(shadowProjectileConfig.Animation) then
        sprite:Play(shadowProjectileConfig.Animation, true)
    end
end)

--[[
Resouled:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
    local frameCount = g:GetFrameCount()
    local room = g:GetRoom()
    local center = room:GetCenterPos()
    local vel = Vector(0, 4)
    local step = 360/16
    if frameCount % 15 == 0 then
        for _ = 1, 16 do
            
            local p = spawnShadowProjectile(center, vel)
            if p then
                p:AddProjectileFlags(
                    ((frameCount % 30)//15 == 0 and ProjectileFlags.CURVE_LEFT or ProjectileFlags.CURVE_RIGHT)
                    | ProjectileFlags.ACCELERATE
                    | ProjectileFlags.CHANGE_FLAGS_AFTER_TIMEOUT
                )
                p.ChangeTimeout = 75
                p:AddChangeFlags(ProjectileFlags.FADEOUT)
                p.CurvingStrength = 0.0035
                p.Acceleration = 1.02
            end

            vel = vel:Rotated(step)
        end

    end

    if frameCount % 5 == 0 then
        
        vel = Vector(0, 10):Rotated(frameCount / 3)
        step = 360/6
        for _ = 1, 6 do
            
            local p = spawnShadowProjectile(center, vel)
            if p then
                p:AddProjectileFlags(ProjectileFlags.ACCELERATE | ProjectileFlags.CHANGE_FLAGS_AFTER_TIMEOUT)
                p.ChangeTimeout = 30
                p:AddChangeFlags(ProjectileFlags.FADEOUT)
                p.Acceleration = 1.05
            end
            
            vel = vel:Rotated(step)
        end
    end
end)
]]--

--[[
Resouled:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
    local frameCount = g:GetFrameCount()
    local room = g:GetRoom()
    local center = room:GetCenterPos()

    local player = Isaac.GetPlayer()
    player.MoveSpeed = 1.4

    local vel = Vector(0, 10):Rotated(frameCount * 3)
    local step = 360/8
    if frameCount % 3 == 0 then
        
        for _ = 1, 8 do
            local p = spawnShadowProjectile(center, vel)
            if p then
                p:AddChangeFlags(ProjectileFlags.FADEOUT)
                p:AddProjectileFlags(ProjectileFlags.CHANGE_FLAGS_AFTER_TIMEOUT)
                p.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
                p.ChangeTimeout = 120
                p.CurvingStrength = 0.005
                p:AddProjectileFlags(ProjectileFlags.CURVE_RIGHT)
            end

            vel = vel:Rotated(step)
        end

    end
end)
]]--