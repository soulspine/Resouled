local DAMAGE_GAIN_CHANCE = 0.10
local DAMAGE_GAIN = 0.02

---@param player EntityPlayer
local function onPlayerUpdate(_, player)
    local playerRunSave = SAVE_MANAGER.GetRunSave(player)
    if not playerRunSave.Blessings.Samson then
        playerRunSave.Blessings.Samson = {
            BaseDamage = player.Damage,
            BaseFireRate = Resouled:GetFireRate(player),
            Damage = 0
        }
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, onPlayerUpdate)

---@param player EntityPlayer
---@param cacheFlag CacheFlag
local function onCacheEval(_, player, cacheFlag)
    local playerRunSave = SAVE_MANAGER.GetRunSave(player)

    if not playerRunSave.Blessings then
        return
    end

    if not Resouled:HasBlessing(player, Resouled.Blessings.Samson) and player.Damage < playerRunSave.Blessings.Samson.BaseDamage and Resouled:GetFireRate(player) < playerRunSave.Blessings.Samson.BaseFireRate then
        Resouled:GrantBlessing(player, Resouled.Blessings.Samson)
    end

    if Resouled:HasBlessing(player, Resouled.Blessings.Samson) and cacheFlag | CacheFlag.CACHE_DAMAGE == CacheFlag.CACHE_DAMAGE then
        player.Damage = player.Damage + playerRunSave.Blessings.Samson.Damage
    end
end
Resouled:AddPriorityCallback(ModCallbacks.MC_EVALUATE_CACHE, CallbackPriority.LATE, onCacheEval)



---@param npc EntityNPC
local function onNpcDeath(_, npc)
    local rng = npc:GetDropRNG()
    if rng:RandomFloat() < DAMAGE_GAIN_CHANCE then
        Resouled:IterateOverPlayers(function(player)
            if Resouled:HasBlessing(player, Resouled.Blessings.Samson) then
                local playerRunSave = SAVE_MANAGER.GetRunSave(player)
                playerRunSave.Blessings.Samson.Damage = playerRunSave.Blessings.Samson.Damage + DAMAGE_GAIN
                player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
                player:EvaluateItems()
            end
        end)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, onNpcDeath)