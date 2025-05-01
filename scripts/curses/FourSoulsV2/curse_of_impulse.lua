local curse = Resouled.Curses.CURSE_OF_IMPULSE
local mapId = Resouled.CursesMapId[curse]

--[[
MinimapAPI:AddMapFlag(
    mapId,
    function()
        return Resouled:CustomCursePresent(curse)
    end,
    Resouled.CursesSprite,
    mapId,
    1
)
]]

local PUSH_DURATION = 10
local PUSH_VELOCITY_MULT = 1.2

---@param player EntityPlayer
---@param gridIndex integer
---@param gridEntity GridEntity | nil
local function onPlayerCollision(_, player, gridIndex, gridEntity)
    local data = player:GetData()
    if Resouled:CustomCursePresent(curse) and gridEntity and not data.ResouledCurseOfImpulsePushCooldown and gridEntity:GetType() ~= GridEntityType.GRID_PIT and not data.ResouledSRVelocity then --data.ResouledSRVelocity is from sibling rivalry
        player:AddKnockback(EntityRef(player), Resouled:GetBounceOffGridElementVector(player.Velocity, player.Position, gridEntity.Position) * PUSH_VELOCITY_MULT, PUSH_DURATION, false)
        data.ResouledCurseOfImpulsePushCooldown = PUSH_DURATION
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_PLAYER_GRID_COLLISION, onPlayerCollision)

---@param player EntityPlayer
local function onPlayerUpdate(_, player)
    local data = player:GetData()
    if data.ResouledCurseOfImpulsePushCooldown then
        data.ResouledCurseOfImpulsePushCooldown = data.ResouledCurseOfImpulsePushCooldown - 1

        if data.ResouledCurseOfImpulsePushCooldown == 0 then
            data.ResouledCurseOfImpulsePushCooldown = nil
        end

    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, onPlayerUpdate)