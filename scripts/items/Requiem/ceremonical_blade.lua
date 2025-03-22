local CEREMONIAL_BLADE = Isaac.GetItemIdByName("Ceremonial Blade")
local BASE_PICKUP_DROP_CHANCE = 0.05
local PICKUP_DROP_CHANCE_PER_1_LUCK = 0.0025
local PICKUP_VELOCITY = 2

---@param npc EntityNPC
local function onNpcDeath(_, npc)
    local playerLuck = 0
    local ceremonicalBladeAmmount = 0
    ---@param player EntityPlayer
    Resouled:IterateOverPlayers(function(player)
        if player:HasCollectible(CEREMONIAL_BLADE) then
            ceremonicalBladeAmmount = ceremonicalBladeAmmount + player:GetCollectibleNum(CEREMONIAL_BLADE)
        end

        if player:GetPlayerType() == PlayerType.PLAYER_JUDAS_B then
            ceremonicalBladeAmmount = ceremonicalBladeAmmount + 1
        end

        if player:HasCollectible(CEREMONIAL_BLADE) or player:GetPlayerType() == PlayerType.PLAYER_JUDAS_B then
            playerLuck = playerLuck + player.Luck
        end
    end)
    
    if ceremonicalBladeAmmount > 0 then
        if npc:IsEnemy() then
            local rng = RNG()
            rng:SetSeed(npc.InitSeed, 0)
            for _ = 1, ceremonicalBladeAmmount do
                local chance = rng:RandomFloat()
                if chance <= BASE_PICKUP_DROP_CHANCE + (PICKUP_DROP_CHANCE_PER_1_LUCK * playerLuck) then
                    local pickup = rng:RandomInt(3)
                    local pickupTranslation = {
                        [0] = PickupVariant.PICKUP_COIN,
                        [1] = PickupVariant.PICKUP_BOMB,
                        [2] = PickupVariant.PICKUP_KEY,
                    }
                    Game():Spawn(EntityType.ENTITY_PICKUP, pickupTranslation[pickup], npc.Position, Vector(math.random(-PICKUP_VELOCITY, PICKUP_VELOCITY) + math.random(-1, 1), math.random(-PICKUP_VELOCITY, PICKUP_VELOCITY) + math.random(-1, 1)), nil, 1, rng:GetSeed())
                end
                rng:Next()
            end
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, onNpcDeath)

local function onRoomClear()
    local ceremonicalBladeAmmount = 0
    ---@param player EntityPlayer
    Resouled:IterateOverPlayers(function(player)
        if player:HasCollectible(CEREMONIAL_BLADE) then
            ceremonicalBladeAmmount = ceremonicalBladeAmmount + player:GetCollectibleNum(CEREMONIAL_BLADE)
        end

        if player:GetPlayerType() == PlayerType.PLAYER_JUDAS_B then
            ceremonicalBladeAmmount = ceremonicalBladeAmmount + 1
        end
    end)
    if ceremonicalBladeAmmount > 0 then
        local player = Isaac.GetPlayer()
        if player:GetNumCoins() > 0 and player:GetNumBombs() > 0 and player:GetNumKeys() > 0 then
            for _ = 1, ceremonicalBladeAmmount do
                local rng = RNG()
                rng:SetSeed(Game():GetRoom():GetSeededCollectible(Game():GetRoom():GetAwardSeed(), false), 0)
                local pickupToAdd = rng:RandomInt(3)
                rng:Next()
                local coin = 0
                local bomb = 1
                local key = 2
                local pickupToRemove = rng:RandomInt(3)
                if pickupToAdd == coin then
                    player:AddCoins(1)
                elseif pickupToAdd == bomb then
                    player:AddBombs(1)
                elseif pickupToAdd == key then
                    player:AddKeys(1)
                end
                if pickupToRemove == coin then
                    player:AddCoins(-1)
                elseif pickupToRemove == bomb then
                    player:AddBombs(-1)
                elseif pickupToRemove == key then
                    player:AddKeys(-1)
                end
            end
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, onRoomClear)