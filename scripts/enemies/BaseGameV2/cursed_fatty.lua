local CURSED_FATTY_VARIANT = Isaac.GetEntityVariantByName("Cursed Fatty")
local CURSED_FATTY_TYPE = Isaac.GetEntityTypeByName("Cursed Fatty")

local ITEM_DROP_CHANCE = 0.3
local ACTIVATION_DISTANCE = 110
local ITEM_DROP_STEP = 10
local COOLDOWN = 10


local DEATH_TEARS_SPAWN_COUNT = 10
local DEATH_TEAR_BULLET_FLAGS = (ProjectileFlags.SMART | ProjectileFlags.ACCELERATE | ProjectileFlags.SINE_VELOCITY)
local DEATH_TEAR_HOMING_STRENGTH = 0.05
local DEATH_TEAR_ACCELERATION = 1.08

-- local DEATH_TEAR_BULLET_FLAGS = (ProjectileFlags.SMART | ProjectileFlags.ACCELERATE | ProjectileFlags.SINE_VELOCITY | ProjectileFlags.SIDEWAVE | ProjectileFlags.LASER_SHOT | ProjectileFlags.BURST8) TODO ADD THIS TO EACH ENEMY DATH IN ULTRAHARD

local HALO_SUBTYPE = 3
local HALO_OFFSET = Vector(0, -15)
local HALO_SCALE = Vector(1.5, 1.5)

local CURSED_ENEMY_MORPH_CHANCE = 0.1

---@param npc EntityNPC
local function onNPCDeath(_, npc)
    if npc.Variant == CURSED_FATTY_VARIANT then
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
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, onNPCDeath, CURSED_FATTY_TYPE)
    
---@param npc EntityNPC
local function onNpcInit(_, npc)
    --Try to turn enemy into a cursed enemy
    if Game():GetLevel():GetCurses() > 0 then
        Resouled:TryEnemyMorph(npc, CURSED_ENEMY_MORPH_CHANCE, CURSED_FATTY_TYPE, CURSED_FATTY_VARIANT, 0)
    end

    if npc.Variant == CURSED_FATTY_VARIANT then
        npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
        Resouled.NpcHalo:AddHaloToNpc(npc, HALO_SUBTYPE, HALO_SCALE, HALO_OFFSET)
        npc:GetData().Cooldown = COOLDOWN
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_INIT, onNpcInit, CURSED_FATTY_TYPE)

---@param npc EntityNPC
local function preNpcUpdate(_, npc)
    if npc.Variant == CURSED_FATTY_VARIANT then
        local data = npc:GetData()
        if data.Cooldown > 0 then
            data.Cooldown = data.Cooldown - 1
        end

        ---@param player EntityPlayer
        Resouled.Iterators:IterateOverPlayers(function(player)
            if data.Cooldown == 0 and player.Position:Distance(npc.Position) < ACTIVATION_DISTANCE then
                local itemToDrop = Resouled.Collectiblextension:ChooseRandomPlayerItemID(player, npc:GetDropRNG())
                if itemToDrop and npc:GetDropRNG():RandomFloat() <= ITEM_DROP_CHANCE then
                    local itemCharge = 0
                    if player:GetActiveItem(ActiveSlot.SLOT_PRIMARY) == itemToDrop then
                        itemCharge = player:GetActiveCharge(ActiveSlot.SLOT_PRIMARY) + player:GetBatteryCharge(ActiveSlot.SLOT_PRIMARY)
                    elseif player:GetActiveItem(ActiveSlot.SLOT_SECONDARY) == itemToDrop then
                        itemCharge = player:GetActiveCharge(ActiveSlot.SLOT_SECONDARY) + player:GetBatteryCharge(ActiveSlot.SLOT_SECONDARY)
                    end

                    player:RemoveCollectible(itemToDrop)
                    local rng = player:GetCollectibleRNG(itemToDrop)
                    local entity = Game():Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, Isaac.GetFreeNearPosition(Isaac.GetRandomPosition(), ITEM_DROP_STEP), Vector.Zero, player, itemToDrop, rng:GetSeed())

                    local pickup = entity:ToPickup()

                    if pickup then
                        pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, itemToDrop, false, true, true)
                        pickup.Touched = true
                        pickup.Charge = itemCharge
                    end
                end
                data.Cooldown = COOLDOWN
            end
        end)
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, preNpcUpdate, CURSED_FATTY_TYPE)