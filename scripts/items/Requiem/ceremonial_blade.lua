local CEREMONIAL_BLADE = Isaac.GetItemIdByName("Ceremonial Blade")

local ROOM_CLEAR_EFFECT_VARIANT = EffectVariant.HERETIC_PENTAGRAM
local ROOM_CLEAR_EFFECT_TIMEOUT = 1
local ROOM_CLEAR_EFFECT_SCALE = Vector(0.15, 0.15)

local ENEMY_KILL_BASE_PICKUP_DROP_CHANCE = 0.05
local ENEMY_KILL_PICKUP_DROP_CHANCE_PER_1_LUCK = 0.0025
local ENEMY_KILL_PICKUP_VELOCITY = 2
local ENEMY_KILL_WHITELISTED_PICKUPS = {
    PickupVariant.PICKUP_COIN,
    PickupVariant.PICKUP_BOMB,
    PickupVariant.PICKUP_KEY,
}


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

                    Game():Spawn(EntityType.ENTITY_PICKUP, ENEMY_KILL_WHITELISTED_PICKUPS[rng:RandomInt(#ENEMY_KILL_WHITELISTED_PICKUPS) + 1], npc.Position, Vector(math.random(-ENEMY_KILL_PICKUP_VELOCITY, ENEMY_KILL_PICKUP_VELOCITY), math.random(-ENEMY_KILL_PICKUP_VELOCITY, ENEMY_KILL_PICKUP_VELOCITY)), nil, 1, newPickupSeed)
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
    
            local pickup = Game():Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_NULL, spawnPos, Vector.Zero, nil, 0, newPickupSeed):ToPickup()
            if pickup then
                local effect = Game():Spawn(EntityType.ENTITY_EFFECT, ROOM_CLEAR_EFFECT_VARIANT, pickup.Position, Vector.Zero, nil, 0, 0):ToEffect()
                if effect then
                    effect:SetTimeout(ROOM_CLEAR_EFFECT_TIMEOUT)
                    effect:GetSprite().Scale = ROOM_CLEAR_EFFECT_SCALE
                end
            end        
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, onRoomClear)