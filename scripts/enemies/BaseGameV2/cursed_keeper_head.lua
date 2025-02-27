local CURSED_KEEPER_HEAD_VARIANT = Isaac.GetEntityVariantByName("Cursed Keeper Head")
local CURSED_KEEPER_HEAD_TYPE = Isaac.GetEntityTypeByName("Cursed Keeper Head")

local HALO_SUBTYPE = 3
local HALO_OFFSET = Vector(0, -15)
local HALO_SCALE = Vector(1.5, 1.5)
local COOLDOWN = 10

local DICE_ROLL_TARGET = 2
local ACTIVATION_DISTANCE = 110

local GREED_COIN_TIMEOUT = 60 -- frames
local GREED_POSITION_STEP = 10
local GREED_COIN_VECTOR_SIZE = 2

local DEATH_TEARS_SPAWN_COUNT = 7
local DEATH_TEAR_BULLET_FLAGS = (ProjectileFlags.SMART | ProjectileFlags.ACCELERATE | ProjectileFlags.GREED | ProjectileFlags.TRIANGLE)
local DEATH_TEAR_HOMING_STRENGTH = 0.05
local DEATH_TEAR_ACCELERATION = 1.105

local CURSED_ENEMY_MORPH_CHANCE = 0.05

local function onRoomEnter()
    local rng = RNG()
    if Game():GetLevel():GetCurses() < 0 then
        return
    end
    for _ = 1, #Isaac.GetRoomEntities() do
        local npc = Isaac.GetRoomEntities()[_]
        rng:SetSeed(npc:GetDropRNG():GetSeed(), 0)
        if npc == EntityType.ENTITY_PLAYER or not npc:IsEnemy() then
        elseif npc.Type == CURSED_KEEPER_HEAD_TYPE and rng:RandomFloat() < CURSED_ENEMY_MORPH_CHANCE then
            Game():Spawn(CURSED_KEEPER_HEAD_TYPE, CURSED_KEEPER_HEAD_VARIANT, npc.Position, Vector(0, 0), nil, 0, npc:GetDropRNG():GetSeed())
            npc:Die()
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, onRoomEnter)

---@param npc EntityNPC
local function onNpcInit(_, npc)
    if npc.Variant == CURSED_KEEPER_HEAD_VARIANT then
        Resouled:AddHaloToNpc(npc, HALO_SUBTYPE, HALO_SCALE, HALO_OFFSET)
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

        print(data.Cooldown)

        if data.Cooldown > 0 then
            data.Cooldown = data.Cooldown - 1
        end

        ---@param player EntityPlayer
        Resouled:IterateOverPlayers(function(player)
            print(player.Position:Distance(npc.Position))
            if data.Cooldown == 0 and player.Position:Distance(npc.Position) < ACTIVATION_DISTANCE then
                print("Player is close enough to drop item")
                if Resouled:RollD6(npc:GetDropRNG()) == DICE_ROLL_TARGET and player:GetNumCoins() > 0 then
                    player:AddCoins(-2)
                    local spawnPos = Isaac.GetFreeNearPosition(player.Position, GREED_POSITION_STEP)
                    local spawnVel = Vector(player.Position.X - spawnPos.X, player.Position.Y - spawnPos.Y):Resized(GREED_COIN_VECTOR_SIZE)
                    local coin = Game():Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, spawnPos, spawnVel, nil, CoinSubType.COIN_PENNY, Game():GetSeeds():GetStageSeed(Game():GetLevel():GetStage()))
                    coin:ToPickup().Timeout = GREED_COIN_TIMEOUT
                end
                data.Cooldown = COOLDOWN
            end
        end)
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, preNpcUpdate, CURSED_KEEPER_HEAD_TYPE)