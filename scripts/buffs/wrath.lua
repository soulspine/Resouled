local CHANCE = 1/3

local BASE_BOMB_RADIUS = 87
local BASE_BOMB_DAMAGE = 100

local function placeBomb(_, player)
    if math.random() < CHANCE then
        ---@param npc EntityNPC
        for _, npc in pairs(Isaac.FindInRadius(player.Position, BASE_BOMB_RADIUS, EntityPartition.ENEMY)) do
            if npc:IsVulnerableEnemy() and npc:IsEnemy() then
                npc:TakeDamage(BASE_BOMB_DAMAGE, DamageFlag.DAMAGE_EXPLOSION, EntityRef(player), 0)
            end
        end
        Resouled.Game:BombExplosionEffects(player.Position, 0, TearFlags.TEAR_NORMAL)
    end
end

Resouled:AddBuffToRemoveOnRunEnd(Resouled.Buffs.WRATH, true)

Resouled:AddBuffCallbackConfig(Resouled.Buffs.WRATH, {
    {
        CallbackID = ModCallbacks.MC_POST_PLAYER_USE_BOMB,
        Function = placeBomb
    }
})