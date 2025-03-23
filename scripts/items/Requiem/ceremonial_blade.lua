local CEREMONIAL_BLADE = Isaac.GetItemIdByName("Ceremonial Blade")

local ROOM_CLEAR_FADING_PICKUP_VELOCITY = 2
local ROOM_CLEAR_FADING_PICKUP_TIMEOUT = 60
local ROOM_CLEAR_WHITELISTED_PICKUPS = {
    PickupVariant.PICKUP_HEART,
    PickupVariant.PICKUP_COIN,
    PickupVariant.PICKUP_KEY,
    PickupVariant.PICKUP_BOMB,
    PickupVariant.PICKUP_POOP,
    PickupVariant.PICKUP_CHEST,
    PickupVariant.PICKUP_BOMBCHEST,
    PickupVariant.PICKUP_SPIKEDCHEST,
    PickupVariant.PICKUP_ETERNALCHEST,
    PickupVariant.PICKUP_MIMICCHEST,
    PickupVariant.PICKUP_OLDCHEST,
    PickupVariant.PICKUP_WOODENCHEST,
    PickupVariant.PICKUP_MEGACHEST,
    PickupVariant.PICKUP_LOCKEDCHEST,
    PickupVariant.PICKUP_GRAB_BAG,
    PickupVariant.PICKUP_LIL_BATTERY,
    PickupVariant.PICKUP_TAROTCARD,
    PickupVariant.PICKUP_REDCHEST,
}

local PICKUP_EFFECT_VARIANT = EffectVariant.HERETIC_PENTAGRAM
local PICKUP_EFFECT_TIMEOUT = 1
local PICKUP_EFFECT_SCALE = Vector(0.2, 0.2)
local PICKUP_EFFECT_COLOR = Color(1.5,0.1,0.1,1)

local ENEMY_KILL_BASE_PICKUP_DROP_CHANCE = 0.05
local ENEMY_KILL_PICKUP_DROP_CHANCE_PER_1_LUCK = 0.01
local ENEMY_KILL_PICKUP_VELOCITY = 2
local ENEMY_KILL_WHITELISTED_PICKUPS = {
    PickupVariant.PICKUP_COIN,
    PickupVariant.PICKUP_BOMB,
    PickupVariant.PICKUP_KEY,
}

if EID then
    EID:addCollectible(CEREMONIAL_BLADE, "5% chance to drop a {{Coin}} coin / {{Bomb}} bomb / {{Key}} key when killing an enemy.#On room clear makes Isaac drop 1 pickup with no way to pick it up and spawns a new random pickup.#{{Luck}} 15% chance at 10 luck", "Ceremonial Blade")
end

---@param spawner Entity
local function spawnEffect(spawner)
    local effect = Game():Spawn(EntityType.ENTITY_EFFECT, PICKUP_EFFECT_VARIANT, spawner.Position, Vector.Zero, spawner, 0, 0):ToEffect()
    if effect then
        effect:SetTimeout(PICKUP_EFFECT_TIMEOUT)
        effect:GetSprite().Scale = PICKUP_EFFECT_SCALE
        effect:GetSprite().Color = PICKUP_EFFECT_COLOR
        effect:GetData().ResouledCeremonialBladeEffect = true
    end
end
---@param npc EntityNPC
local function onNpcDeath(_, npc)
    local playerLuck = 0
    local ceremonialBladeAmount = 0
    ---@param player EntityPlayer
    Resouled:IterateOverPlayers(function(player)
        if player:HasCollectible(CEREMONIAL_BLADE) then
            ceremonialBladeAmount = ceremonialBladeAmount + player:GetCollectibleNum(CEREMONIAL_BLADE)
            playerLuck = playerLuck + player.Luck
        end
    end)
    
    if ceremonialBladeAmount > 0 then
        if npc:IsEnemy() then
            local rng = RNG()
            rng:SetSeed(npc.DropSeed, 0)
            for _ = 1, ceremonialBladeAmount do
                if rng:RandomFloat() <= ENEMY_KILL_BASE_PICKUP_DROP_CHANCE + (ENEMY_KILL_PICKUP_DROP_CHANCE_PER_1_LUCK * playerLuck) then

                    local newPickupSeed = 0
                    while newPickupSeed == 0 do
                        newPickupSeed = Random()
                    end

                    local pickup = Game():Spawn(EntityType.ENTITY_PICKUP, ENEMY_KILL_WHITELISTED_PICKUPS[rng:RandomInt(#ENEMY_KILL_WHITELISTED_PICKUPS) + 1], npc.Position, Vector(math.random(-ENEMY_KILL_PICKUP_VELOCITY, ENEMY_KILL_PICKUP_VELOCITY), math.random(-ENEMY_KILL_PICKUP_VELOCITY, ENEMY_KILL_PICKUP_VELOCITY)), nil, 1, newPickupSeed):ToPickup()
                    if pickup then
                        spawnEffect(pickup)
                    end
                end
            end
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, onNpcDeath)

local function onRoomClear()
    if Resouled:CollectiblePresent(CEREMONIAL_BLADE) then
        local room = Game():GetRoom()
        local roomRng = RNG()
        roomRng:SetSeed(room:GetAwardSeed(), 4) -- random 4 shift because why not
    
        local player0 = Isaac.GetPlayer(0)
        local allowedPickupsToRemove = {}
    
        if player0:GetNumCoins() > 0 then
            table.insert(allowedPickupsToRemove, PickupVariant.PICKUP_COIN)
        end
    
        if player0:GetNumBombs() > 0 then
            table.insert(allowedPickupsToRemove, PickupVariant.PICKUP_BOMB)
        end
    
        if player0:GetNumKeys() > 0 then
            table.insert(allowedPickupsToRemove, PickupVariant.PICKUP_KEY)
        end
    
        if #allowedPickupsToRemove > 0 then
            local pickupToRemove = allowedPickupsToRemove[roomRng:RandomInt(#allowedPickupsToRemove) + 1]
    
            if pickupToRemove == PickupVariant.PICKUP_COIN then
                player0:AddCoins(-1)
            elseif pickupToRemove == PickupVariant.PICKUP_BOMB then
                player0:AddBombs(-1)
            elseif pickupToRemove == PickupVariant.PICKUP_KEY then
                player0:AddKeys(-1)
            end
    
            local newPickupSeed = 0
    
            while newPickupSeed == 0 do
                newPickupSeed = Random()
            end
    
            local spawnPos = room:GetCenterPos()
    
            local fadingPickup = Game():Spawn(EntityType.ENTITY_PICKUP, pickupToRemove, player0.Position, Vector(math.random(-ROOM_CLEAR_FADING_PICKUP_VELOCITY, ROOM_CLEAR_FADING_PICKUP_VELOCITY), math.random(-ROOM_CLEAR_FADING_PICKUP_VELOCITY,ROOM_CLEAR_FADING_PICKUP_VELOCITY)), nil, 1, newPickupSeed):ToPickup()

            if fadingPickup then
                fadingPickup.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
                fadingPickup.Timeout = ROOM_CLEAR_FADING_PICKUP_TIMEOUT
                fadingPickup:GetData().ResouledCeremonialBladeCancelCollision = true
            end

            local pickup = Game():Spawn(EntityType.ENTITY_PICKUP, ROOM_CLEAR_WHITELISTED_PICKUPS[roomRng:RandomInt(#ROOM_CLEAR_WHITELISTED_PICKUPS) + 1], room:FindFreePickupSpawnPosition(spawnPos), Vector.Zero, nil, 0, newPickupSeed):ToPickup()
            if pickup then
                spawnEffect(pickup)
            end        
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, onRoomClear)

---@param pickup EntityPickup
---@param collider Entity
---@param low boolean
local function onPickupCollision(_, pickup, collider, low)
    if pickup:GetData().ResouledCeremonialBladeCancelCollision then
        return false
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, onPickupCollision)

---@param effect EntityEffect
local function onEffectUpdate(_, effect)
    if effect:GetData().ResouledCeremonialBladeEffect and effect.SpawnerEntity then
        effect.Position = effect.SpawnerEntity.Position
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, onEffectUpdate)