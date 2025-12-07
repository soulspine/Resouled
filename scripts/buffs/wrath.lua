local CHANCE = 1/3

local BASE_BOMB_RADIUS = 87
local BASE_BOMB_DAMAGE = 100

local function placeBomb(_, player)
    if not Resouled:ActiveBuffPresent(Resouled.Buffs.WRATH) then return end

    if math.random() < CHANCE then
        ---@param npc EntityNPC
        for _, npc in pairs(Isaac.FindInRadius(player.Position, BASE_BOMB_RADIUS, EntityPartition.ENEMY)) do
            if npc:IsVulnerableEnemy() and npc:IsEnemy() then
                npc:TakeDamage(BASE_BOMB_DAMAGE, DamageFlag.DAMAGE_EXPLOSION, EntityRef(player), 0)
            end
        end
        Game():BombExplosionEffects(player.Position, 0, TearFlags.TEAR_NORMAL)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PLAYER_USE_BOMB, placeBomb)

Resouled:AddBuffToRemoveOnRunEnd(Resouled.Buffs.WRATH, true)