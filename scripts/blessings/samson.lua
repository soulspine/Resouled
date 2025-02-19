local GRANT_DAMAGE_THRESHOLD = 1

local DAMAGE_GAIN_CHANCE = 0.25
local DAMAGE_GAIN = 0.05

---@param player EntityPlayer
---@param cacheFlag CacheFlag
local function onCacheEval(_, player, cacheFlag)
    local playerRunSave = SAVE_MANAGER.GetRunSave(player)
    if not Resouled:HasBlessing(player, Resouled.Blessings.SAMSON) and player.Damage <= GRANT_DAMAGE_THRESHOLD then
        Resouled:GrantBlessing(player, Resouled.Blessings.SAMSON)
        playerRunSave.Blessings.Samson = 0
    end

    if Resouled:HasBlessing(player, Resouled.Blessings.SAMSON) and cacheFlag | CacheFlag.CACHE_DAMAGE == CacheFlag.CACHE_DAMAGE then
        player.Damage = player.Damage + playerRunSave.Blessings.Samson
    end
end
Resouled:AddPriorityCallback(ModCallbacks.MC_EVALUATE_CACHE, CallbackPriority.LATE, onCacheEval)



---@param npc EntityNPC
local function onNpcDeath(_, npc)
    local rng = npc:GetDropRNG()
    if rng:RandomFloat() < DAMAGE_GAIN_CHANCE then
        Resouled:IterateOverPlayers(function(player, playerId)
            if Resouled:HasBlessing(player, Resouled.Blessings.SAMSON) then
                local playerRunSave = SAVE_MANAGER.GetRunSave(player)
                playerRunSave.Blessings.Samson = playerRunSave.Blessings.Samson + DAMAGE_GAIN
                player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
                player:EvaluateItems()
            end
        end)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, onNpcDeath)