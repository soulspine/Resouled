local HANDICAPPED_PLACARD = Isaac.GetTrinketIdByName("Handicapped Placard")

local SLOW_DOWN_PER_SOUL = 0.0375

---@param npc EntityNPC
local function onNpcInit(_, npc)
    local handicappedPlacardPresent
    ---@param player EntityPlayer
    Resouled:IterateOverPlayers(function(player)
        if player:HasTrinket(HANDICAPPED_PLACARD) then
            handicappedPlacardPresent = true
        end
    end)
    if handicappedPlacardPresent and npc:IsEnemy() and npc:IsActiveEnemy(true) then
        local sprite = npc:GetSprite()
        local npcPlaybackSpeed = sprite.PlaybackSpeed
        local precentToSlowEnemyDown = SLOW_DOWN_PER_SOUL * Resouled:GetPossessedSoulsNum()
        local targetPlaybackSpeed = npcPlaybackSpeed - precentToSlowEnemyDown
        sprite.PlaybackSpeed = targetPlaybackSpeed
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_INIT, onNpcInit)

---@param npc EntityNPC
local function preNpcUpdate(_, npc)
    local handicappedPlacardPresent
    ---@param player EntityPlayer
    Resouled:IterateOverPlayers(function(player)
        if player:HasTrinket(HANDICAPPED_PLACARD) then
            handicappedPlacardPresent = true
        end
    end)
    if handicappedPlacardPresent and npc:IsEnemy() and npc:IsActiveEnemy(true) then
        local sprite = npc:GetSprite()
        local precentToSlowEnemyDown = SLOW_DOWN_PER_SOUL * Resouled:GetPossessedSoulsNum()
        local npcPlaybackSpeed = sprite.PlaybackSpeed + precentToSlowEnemyDown
        local targetPlaybackSpeed = npcPlaybackSpeed - precentToSlowEnemyDown
        sprite.PlaybackSpeed = targetPlaybackSpeed
        npc.Friction = npc.Friction - precentToSlowEnemyDown
    end
end
Resouled:AddPriorityCallback(ModCallbacks.MC_PRE_NPC_UPDATE, CallbackPriority.LATE, preNpcUpdate)

local function postProjectileInit(_, projectile)
    local handicappedPlacardPresent
    ---@param player EntityPlayer
    Resouled:IterateOverPlayers(function(player)
        if player:HasTrinket(HANDICAPPED_PLACARD) then
            handicappedPlacardPresent = true
        end
    end)
    if handicappedPlacardPresent and projectile.SpawnerEntity then
        if projectile.SpawnerEntity:IsEnemy() then
            local sprite = projectile:GetSprite()
            local precentToSlowProjectileDown = SLOW_DOWN_PER_SOUL * Resouled:GetPossessedSoulsNum()
            local projectilePlaybackSpeed = sprite.PlaybackSpeed + precentToSlowProjectileDown
            local targetPlaybackSpeed = projectilePlaybackSpeed - precentToSlowProjectileDown
            sprite.PlaybackSpeed = targetPlaybackSpeed
            projectile.Friction = projectile.Friction - precentToSlowProjectileDown
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PROJECTILE_INIT, postProjectileInit)

---@param projectile EntityProjectile
local function preProjectileUpdate(_, projectile)
    local handicappedPlacardPresent
    ---@param player EntityPlayer
    Resouled:IterateOverPlayers(function(player)
        if player:HasTrinket(HANDICAPPED_PLACARD) then
            handicappedPlacardPresent = true
        end
    end)
    if handicappedPlacardPresent and projectile.SpawnerEntity then
        if projectile.SpawnerEntity:IsEnemy() then
            local sprite = projectile:GetSprite()
            local precentToSlowProjectileDown = SLOW_DOWN_PER_SOUL * Resouled:GetPossessedSoulsNum()
            local projectilePlaybackSpeed = sprite.PlaybackSpeed + precentToSlowProjectileDown
            local targetPlaybackSpeed = projectilePlaybackSpeed - precentToSlowProjectileDown
            sprite.PlaybackSpeed = targetPlaybackSpeed
        end
    end
end
Resouled:AddPriorityCallback(ModCallbacks.MC_PRE_PROJECTILE_UPDATE, CallbackPriority.LATE, preProjectileUpdate)

---@param pickup EntityPickup
local function postPickupUpdate(_, pickup)
    if pickup.SubType == HANDICAPPED_PLACARD then
        if EID then
            local precent = tostring(SLOW_DOWN_PER_SOUL * 100)
            local currentPrecent = tostring(SLOW_DOWN_PER_SOUL * Resouled:GetPossessedSoulsNum() * 100)
            EID:addTrinket(HANDICAPPED_PLACARD, "Slows down enemies by "..precent.."% for every soul you posess,# Enemies will currently be slowed down by: {{ColorError}}"..currentPrecent.."%")
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, postPickupUpdate, PickupVariant.PICKUP_TRINKET)