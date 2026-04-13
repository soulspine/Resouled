local projectileConf = {
    Type = Isaac.GetEntityTypeByName("ResouledShadowFightProjectile"),
    Variant = Isaac.GetEntityVariantByName("ResouledShadowFightProjectile"),
    SubType = Isaac.GetEntitySubTypeByName("ResouledShadowFightProjectile"),

    RemoveCheckFrequency = 10
}

local projectiles = {}

---@return string
local function findFreeIdx()
    ::GenerateAgain::
    local idx = ""
    for _ = 1, 16 do
        idx = idx .. string.char(math.random(Keyboard.KEY_A, Keyboard.KEY_Z)) --A - Z
    end

    if projectiles[idx] then goto GenerateAgain end
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
---@field AutoRemove boolean
local ShadowProjectileClass = {}
ShadowProjectileClass.__index = ShadowProjectileClass

---@param proj ResouledShadowProjectile
function ShadowProjectileClass.Remove(proj) projectiles[proj.Index] = nil end

---@param proj ResouledShadowProjectile
---@return boolean
function ShadowProjectileClass.IsOnScreen(proj)
    local screen = Resouled.Screen()
    local screenCenter = screen/2
    local pos = (Isaac.WorldToScreen(proj.Position) - screenCenter) * 0.9 + screenCenter
    return pos.X > 0 and pos.X < screen.X and pos.Y > 0 and pos.Y < screen.Y
end

---@param proj ResouledShadowProjectile
function ShadowProjectileClass.CheckIfShouldRemoveProjectile(proj)
    if proj.FrameCount % projectileConf.RemoveCheckFrequency ~= 0 then return end
    if not proj:IsOnScreen() then proj:Remove() end
end

---@param proj ResouledShadowProjectile
function ShadowProjectileClass.Move(proj)
    if not Resouled.Game:IsPaused() then proj.Position = proj.Position + proj.Velocity/2 end
end

---@param proj ResouledShadowProjectile
---@param player EntityPlayer
function ShadowProjectileClass.IsTouchingPlayer(proj, player)
    return player.Position:Distance(proj.Position) < (proj.Size + player.Size)/2
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
---@param autoRemove? boolean
---@return ResouledShadowProjectile
function Resouled:SpawnShadowProjectile(type, pos, vel, size, autoRemove)
    local idx = findFreeIdx()

    local newProjectile = setmetatable({}, ShadowProjectileClass)
    newProjectile.FrameCount = 0
    newProjectile.Index = idx
    newProjectile.Position = pos
    newProjectile.Size = size or 0
    newProjectile.Sprite = Sprite()
    newProjectile.Type = type
    newProjectile.Velocity = vel or Vector.Zero
    newProjectile.AutoRemove = autoRemove or true
    newProjectile.Data = {WasOnScreen = newProjectile:IsOnScreen()}

    Isaac.RunCallback(Resouled.Callbacks.ShadowProjectileInit, newProjectile)

    projectiles[idx] = newProjectile

    return newProjectile
end

local function onUpdate()
    ---@param proj ResouledShadowProjectile
    for _, proj in pairs(projectiles) do
        Isaac.RunCallback(Resouled.Callbacks.ShadowProjectileUpdate, proj)

        local data = proj.Data

        proj.FrameCount = proj.FrameCount + 1

        if data.WasOnScreen == false then
            if proj.FrameCount%2 == 0 then data.WasOnScreen = (data.WasOnScreen == false) and proj:IsOnScreen() end
        end

        if proj.AutoRemove then

            if data.WasOnScreen == true then
                proj:CheckIfShouldRemoveProjectile()
            else
                if proj.FrameCount > 45 then
                    proj:Remove()
                end
            end
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_UPDATE, onUpdate)

local function postRender()
    ---@param proj ResouledShadowProjectile
    for _, proj in pairs(projectiles) do
        Isaac.RunCallback(Resouled.Callbacks.ShadowProjectileRender, proj)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_RENDER, postRender)

include("scripts.afterlife_shop.shadow_attacks.1")
include("scripts.afterlife_shop.shadow_attacks.2")
include("scripts.afterlife_shop.shadow_attacks.3")
include("scripts.afterlife_shop.shadow_attacks.4")