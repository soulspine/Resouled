local projectileConf = {
    Type = Isaac.GetEntityTypeByName("ResouledShadowFightProjectile"),
    Variant = Isaac.GetEntityVariantByName("ResouledShadowFightProjectile"),
    SubType = Isaac.GetEntitySubTypeByName("ResouledShadowFightProjectile"),

    RemoveCheckFrequency = 15
}

local projectiles = {}

---@return string
local function findFreeIdx()
    local idx = ""
    for _ = 1, 16 do
        idx = idx .. string.char(math.random(65, 132)) --A - Z
    end
    return idx
end

---@class ResouledShadowProjectile
---@field Index string
---@field Type ResouledShadowProjectileType
---@field Position Vector
---@field Velocity Vector
---@field Size number
---@field FrameCount number
---@field Sprite Sprite
---@field Data table
local ShadowProjectileClass = {}
ShadowProjectileClass.__index = ShadowProjectileClass

---@param projectile ResouledShadowProjectile
function ShadowProjectileClass.Remove(projectile) projectiles[projectile.Index] = nil end

---@param proj ResouledShadowProjectile
function ShadowProjectileClass.CheckIfShouldRemoveProjectile(proj)
    if proj.FrameCount % projectileConf.RemoveCheckFrequency ~= 0 then return end
    local screen = Resouled.Screen()
    local screenCenter = screen/2
    local pos = (Isaac.WorldToScreen(proj.Position) - screenCenter) * 0.9 + screenCenter
    if pos.X < 0 or pos.X > screen.X or pos.Y < 0 or pos.Y > screen.Y then proj:Remove() end
end

---@param proj ResouledShadowProjectile
function ShadowProjectileClass.Move(proj)
    if not Resouled.Game:IsPaused() then proj.Position = proj.Position + proj.Velocity/2 end
end

---@enum ResouledShadowProjectileType
Resouled.ShadowProjectileTypes = {
    Straight = 1,
    Beam = 2,
    Homing = 3,
    BigHomingBurst = 4
}

---@param type ResouledShadowProjectileType
---@param pos Vector
---@param vel? Vector
---@param size? number
---@return ResouledShadowProjectile
function Resouled:SpawnShadowProjectile(type, pos, vel, size)
    local idx = findFreeIdx()

    local newProjectile = setmetatable({}, ShadowProjectileClass)
    newProjectile.Data = {}
    newProjectile.FrameCount = 0
    newProjectile.Index = idx
    newProjectile.Position = pos
    newProjectile.Size = size or 0
    newProjectile.Sprite = Sprite()
    newProjectile.Type = type
    newProjectile.Velocity = vel or Vector.Zero

    Isaac.RunCallback(Resouled.Callbacks.ShadowProjectileInit, newProjectile)

    projectiles[idx] = newProjectile

    return newProjectile
end

local function onUpdate()
    ---@param proj ResouledShadowProjectile
    for _, proj in pairs(projectiles) do
        Isaac.RunCallback(Resouled.Callbacks.ShadowProjectileUpdate, proj)

        proj.FrameCount = proj.FrameCount + 1
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_UPDATE, onUpdate)

local function postRender()
    ---@param proj ResouledShadowProjectile
    for _, proj in pairs(projectiles) do
        
        local sprite = proj.Sprite
        
        local scale = (sprite.Scale.X + sprite.Scale.Y)/2
        local pos = Isaac.WorldToScreen(proj.Position)
        
        local color = KColor(0, 0, 0, 0.5 * sprite.Color.A)
        local vec = Vector(proj.Size/2, 0) * scale
        Isaac.DrawLine(pos - vec, pos + vec, color, color, proj.Size * scale)
        
        Isaac.RunCallback(Resouled.Callbacks.ShadowProjectileRender, proj)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_RENDER, postRender)

include("scripts.afterlife_shop.shadow_attacks.1")
include("scripts.afterlife_shop.shadow_attacks.2")
include("scripts.afterlife_shop.shadow_attacks.3")
include("scripts.afterlife_shop.shadow_attacks.4")