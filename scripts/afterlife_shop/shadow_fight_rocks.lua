---@class ResouledShadowFightRocks
---@field Position Vector
---@field Size number
---@field Weight number
---@field Sprite Sprite
---@field Data table
---@field Index string
local RockClass = {}
RockClass.__index = RockClass
local rocks = {}

---@return string
local function newIdx()
    local idx = ""
    ::Start::
    for _ = 1, 8 do
        idx = idx .. string.char(math.random(Keyboard.KEY_A, Keyboard.KEY_Z))
    end
    if rocks[idx] then goto Start end
    return idx
end

---@param rock ResouledShadowFightRocks
function RockClass.Render(rock)
    rock.Sprite:Render(Isaac.WorldToScreen(rock.Position))
end

local HITBOX_COLOR = KColor(1, 0, 0, 1)
local STEP = 360/16
---@param rock ResouledShadowFightRocks
function RockClass.RenderHitbox(rock)
    local pos = Isaac.WorldToScreen(rock.Position)
    local offset = Vector(rock.Size, 0)

    for _ = 1, 16 do
        local newOffset = offset:Rotated(STEP)
        Isaac.DrawLine(pos + offset, pos + newOffset, HITBOX_COLOR, HITBOX_COLOR, 1)
        offset = newOffset
    end
end

---@param rock ResouledShadowFightRocks
function RockClass.CheckPlayerCollision(rock)
    ---@param player EntityPlayer
    Resouled.Iterators:IterateOverPlayersInArea(rock.Position, rock.Size + Isaac.GetPlayer().Size, function(player)
        
        rock.Position = rock.Position + (player.Position - rock.Position):Normalized()/rock.Weight
        player.Velocity = Vector.Zero
    end)
end

---@param rock ResouledShadowFightRocks
function RockClass.Remove(rock)
    rocks[rock.Index] = nil
end

---@param pos Vector
---@param size number
---@param weight number
---@param gfxPath string
---@return ResouledShadowFightRocks
function Resouled:CreateShadowFightRock(pos, size, weight, gfxPath)
    local newRock = setmetatable({}, RockClass)
    local idx = newIdx()

    newRock.Position = pos
    newRock.Size = size
    newRock.Weight = weight
    newRock.Sprite = Sprite()
    newRock.Sprite:Load(gfxPath, true)
    newRock.Data = {}
    newRock.Index = idx

    rocks[idx] = newRock

    Isaac.RunCallback(Resouled.Callbacks.ShadowFightRockInit, newRock)

    return newRock
end

Resouled:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
    if not Resouled.AfterlifeShop.ShadowFight.Active then return end
    for _, rock in pairs(rocks) do
        Isaac.RunCallback(Resouled.Callbacks.ShadowFightRockUpdate, rock)
    end
end)

Resouled:AddCallback(ModCallbacks.MC_POST_RENDER, function()
    if not Resouled.AfterlifeShop.ShadowFight.Active then return end
    for _, rock in pairs(rocks) do
        Isaac.RunCallback(Resouled.Callbacks.ShadowFightRockRender, rock)
    end
end)