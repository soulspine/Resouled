local CURSED_KEEPER_HEAD_VARIANT = Isaac.GetEntityVariantByName("Cursed Keeper Head")
local CURSED_KEEPER_HEAD_TYPE = Isaac.GetEntityTypeByName("Cursed Keeper Head")

local HALO_SUBTYPE = 3
local HALO_OFFSET = Vector(0, -15)
local HALO_SCALE = Vector(1.5, 1.5)

local COIN_DROP_CHANCE = 0.3
local ACTIVATION_DISTANCE = 110
local COOLDOWN = 40

local COIN_POSITION_STEP = 10
local COIN_VECTOR_SIZE = 2

local DEATH_TEARS_SPAWN_COUNT = 7
local DEATH_TEAR_BULLET_FLAGS = (ProjectileFlags.SMART | ProjectileFlags.ACCELERATE | ProjectileFlags.GREED | ProjectileFlags.TRIANGLE)
local DEATH_TEAR_HOMING_STRENGTH = 0.05
local DEATH_TEAR_ACCELERATION = 1.085

local CURSED_ENEMY_MORPH_CHANCE = 0.1

local COINS_TO_LOSE = 2

---@param npc EntityNPC
local function onNpcInit(_, npc)
    --Try to turn enemy into a cursed enemy
    if Game():GetLevel():GetCurses() > 0 then
        Resouled:TryEnemyMorph(npc, CURSED_ENEMY_MORPH_CHANCE, CURSED_KEEPER_HEAD_TYPE, CURSED_KEEPER_HEAD_VARIANT, 0)
    end

    if npc.Variant == CURSED_KEEPER_HEAD_VARIANT then
        Resouled.NpcHalo:AddHaloToNpc(npc, HALO_SUBTYPE, HALO_SCALE, HALO_OFFSET)
        npc:GetData().Cooldown = COOLDOWN
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_INIT, onNpcInit, CURSED_KEEPER_HEAD_TYPE)

---@param npc EntityNPC
local function onNPCDeath(_, npc)
    if npc.Variant == CURSED_KEEPER_HEAD_VARIANT then
        local DEATH_PROJECTILE_PARAMS = ProjectileParams()
        DEATH_PROJECTILE_PARAMS.BulletFlags = DEATH_TEAR_BULLET_FLAGS
        DEATH_PROJECTILE_PARAMS.Acceleration = DEATH_TEAR_ACCELERATION
        DEATH_PROJECTILE_PARAMS.HomingStrength = DEATH_TEAR_HOMING_STRENGTH

        for i = 1, DEATH_TEARS_SPAWN_COUNT do
            npc:FireProjectiles(npc.Position, Vector.FromAngle(i * 360 / DEATH_TEARS_SPAWN_COUNT):Resized(1), 0, DEATH_PROJECTILE_PARAMS)
        end

        --npc:FireProjectiles(npc.Position, Vector(1, 0), 1, DEATH_PROJECTILE_PARAMS)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, onNPCDeath, CURSED_KEEPER_HEAD_TYPE)

---@param npc EntityNPC
local function preNpcUpdate(_, npc)
    if npc.Variant == CURSED_KEEPER_HEAD_VARIANT then
        local data = npc:GetData()
        if data.Cooldown > 0 then
            data.Cooldown = data.Cooldown - 1
        end

        ---@param player EntityPlayer
        Resouled.Iterators:IterateOverPlayers(function(player)
            if data.Cooldown == 0 and player.Position:Distance(npc.Position) < ACTIVATION_DISTANCE then
                local playerCoins = player:GetNumCoins()
                if npc:GetDropRNG():RandomFloat() < COIN_DROP_CHANCE and playerCoins > 0 then
                    local coinsToDrop = math.min(playerCoins, COINS_TO_LOSE)
                    player:AddCoins(-coinsToDrop)
                    for i = 1, coinsToDrop do
                        local spawnPos = Isaac.GetFreeNearPosition(player.Position, COIN_POSITION_STEP)
                        local spawnVel = Vector(player.Position.X - spawnPos.X, player.Position.Y - spawnPos.Y):Resized(COIN_VECTOR_SIZE)
                        Game():Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, spawnPos, spawnVel, nil, CoinSubType.COIN_PENNY, Game():GetSeeds():GetStageSeed(Game():GetLevel():GetStage()))
                    end
                end
                data.Cooldown = COOLDOWN
            end
        end)
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, preNpcUpdate, CURSED_KEEPER_HEAD_TYPE)