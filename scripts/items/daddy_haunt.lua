local DADDY_HAUNT = Isaac.GetItemIdByName("Daddy Haunt")
local DADDY_HAUNT_VARIANT = Isaac.GetEntityVariantByName("Daddy Haunt")

local VELOCITY_MULTIPLIER = 4

local POSITION_OFFSET_FOLLOW_PARENT = Vector(0, -30)
local POSITION_OFFSET_ENEMY_HOVER = Vector(0, -90)

if EID then
    EID:addCollectible(DADDY_HAUNT, "Not implemented yet", "Daddy Haunt")
end



---@param player EntityPlayer
---@param cacheFlag CacheFlag
local function onCacheEval(_, player, cacheFlag)
    if cacheFlag & CacheFlag.CACHE_FAMILIARS then
        player:CheckFamiliar(DADDY_HAUNT_VARIANT, player:GetCollectibleNum(DADDY_HAUNT), player:GetCollectibleRNG(DADDY_HAUNT))
    end
end
Resouled:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, onCacheEval)

---@param familiar EntityFamiliar
local function onFamiliarInit(_, familiar)
end
Resouled:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, onFamiliarInit, DADDY_HAUNT_VARIANT)

---@param familiar EntityFamiliar
local function onFamiliarUpdate(_, familiar)
    local room = Game():GetRoom()
    if room:GetAliveEnemiesCount() > 0 then
        local room = Game():GetRoom()
        if room:GetAliveEnemiesCount() > 0 then
            local target = Resouled:GetEnemyTarget(familiar)
            if target then
                familiar:RemoveFromFollowers()
                familiar:FollowPosition(target.Position)
                familiar.Velocity = familiar.Velocity * VELOCITY_MULTIPLIER
                familiar.PositionOffset = POSITION_OFFSET_ENEMY_HOVER
            else
                Resouled:SelectRandomEnemyTarget(familiar)
            end
            
        end
    else
        familiar:AddToFollowers()
        familiar:FollowParent()
        familiar.PositionOffset = POSITION_OFFSET_FOLLOW_PARENT
    end
end
Resouled:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, onFamiliarUpdate, DADDY_HAUNT_VARIANT)