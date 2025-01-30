local CHEESE_GRATER = Isaac.GetItemIdByName("Cheese Grater")
local speedCap = 2.25
local speedToAdd = 0.005
local speedToRemove = 0.05
local baseSpeed = 1
local boostLine = 2.20
local wallCheck = 0.99
local killCounter = 0
local oldKillCounter = 0
local killCounterTimer = 300
local timer = 0
local finalKillScore = 0
local stringFinalKillScore = ""
local scoreToLose = 0
local combo = ""
local font = Font()
local printTimer = ""
local playerBaseDamage = 5
local counterDrawn = false
local sfx = SFXManager()
font:Load("font/terminus.fnt")

function KillCounter()
    player = Isaac.GetPlayer()
    if player:HasCollectible(CHEESE_GRATER) then
        oldKillCounter = killCounter
        killCounter = killCounter + 1
        combo = tostring(killCounter)
        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
        player.Damage = playerBaseDamage + (killCounter/5)
    end
end
MOD:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, KillCounter)

function KillCounterTimerCountdown()
    player = Isaac.GetPlayer()
    if player:HasCollectible(CHEESE_GRATER) then
        if killCounter > 0 then
            timer = timer + 1
            printTimer = tostring(math.floor(((killCounterTimer/30)+1)-(timer/30)))
            if printTimer == "0" then
                combo = "0"
            end
            scoreToLose = scoreToLose + 1
            finalKillScore = math.floor((killCounter * 100) - (scoreToLose/30))
            stringFinalKillScore = tostring(finalKillScore)
            if killCounter ~= oldKillCounter and killCounter > oldKillCounter then
                timer = 0
                oldKillCounter = killCounter
            end
            if timer > killCounterTimer then
                finalKillScore = math.floor((killCounter * 100) - (scoreToLose/30))
                killCounter = 0
                stringFinalKillScore = "0"
                scoreToLose = 0
                print(finalKillScore)
            end
        end
    end
end
MOD:AddCallback(ModCallbacks.MC_POST_UPDATE, KillCounterTimerCountdown)

function ComboRewards()
    player = Isaac.GetPlayer()
    if player:HasCollectible(CHEESE_GRATER) then
        local function zeros()
            timer = 0
            killCounter = 0
            combo = "0"
            stringFinalKillScore = "0"
            printTimer = "0"
            scoreToLose = 0
        end
        if timer >= killCounterTimer then
            sfx:Play(SoundEffect.SOUND_CHOIR_UNLOCK, 0.7, 10)
            if finalKillScore < 2000 then
                zeros()
            end
            if finalKillScore >= 2000 and finalKillScore < 4000 then
                zeros()
                Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Isaac.GetFreeNearPosition(player.Position, 40), Vector.Zero, nil)
            end
            if finalKillScore >= 4000 and finalKillScore < 6000 then
                zeros()
                Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_GRAB_BAG, 0, Isaac.GetFreeNearPosition(player.Position, 40), Vector.Zero, nil)
                Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_GRAB_BAG, 0, Isaac.GetFreeNearPosition(player.Position, 40), Vector.Zero, nil)
                Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_GRAB_BAG, 0, Isaac.GetFreeNearPosition(player.Position, 40), Vector.Zero, nil)
            end
            if finalKillScore >= 6000 and finalKillScore < 8000 then
                zeros()
                Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_CHEST, 0, Isaac.GetFreeNearPosition(player.Position, 40), Vector.Zero, nil)
                Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_CHEST, 0, Isaac.GetFreeNearPosition(player.Position, 40), Vector.Zero, nil)
                Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_CHEST, 0, Isaac.GetFreeNearPosition(player.Position, 40), Vector.Zero, nil)
            end
            if finalKillScore >= 8000 and finalKillScore < 10000 then
                zeros()
                Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, 0, Isaac.GetFreeNearPosition(player.Position, 40), Vector.Zero, nil)
            end
            if finalKillScore >= 10000 and finalKillScore < 12000 then
                zeros()
                MOD:SpawnItemOfQuality(1, player:GetCollectibleRNG(CHEESE_GRATER), player.Position)
            end
            if finalKillScore >= 12000 and finalKillScore < 14000 then
                zeros()
                for _ = 1, 20 do
                Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, 0, Isaac.GetFreeNearPosition(player.Position, 40), Vector.Zero, nil)
                end
            end
            if finalKillScore >- 14000 and finalKillScore < 16000 then
                zeros()
                for _ = 1, 20 do
                Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_GRAB_BAG, 0, Isaac.GetFreeNearPosition(player.Position, 40), Vector.Zero, nil)
                end
            end
            if finalKillScore >= 16000 and finalKillScore < 18000 then
                zeros()
                MOD:SpawnItemOfQuality(2, player:GetCollectibleRNG(CHEESE_GRATER), player.Position)
            end
            if finalKillScore >= 18000 and finalKillScore < 20000 then
                zeros()
                for _ = 1, 10 do
                    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_LOCKEDCHEST, 0, Isaac.GetFreeNearPosition(player.Position, 40), Vector.Zero, nil)
                    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_KEY, 0, Isaac.GetFreeNearPosition(player.Position, 40), Vector.Zero, nil)
                end
                for _ = 1, 3 do
                    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_GRAB_BAG, 1, Isaac.GetFreeNearPosition(player.Position, 40), Vector.Zero, nil)
                end
            end
            if finalKillScore >= 20000 and finalKillScore < 22000 then
                zeros()
                MOD:SpawnItemOfQuality(2, player:GetCollectibleRNG(CHEESE_GRATER), player.Position)
                for _ = 1, 10 do
                    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, 0, Isaac.GetFreeNearPosition(player.Position, 40), Vector.Zero, nil)
                end
            end
            if finalKillScore >= 22000 and finalKillScore < 24000 then
                zeros()
                for _ = 1, 5 do
                    MOD:SpawnItemOfQuality(1, player:GetCollectibleRNG(CHEESE_GRATER), player.Position)
                end
            end
            if finalKillScore >= 24000 and finalKillScore < 26000 then
                zeros()
                for _ = 1, 10 do
                    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, 0, Isaac.GetFreeNearPosition(player.Position, 40), Vector.Zero, nil)
                end
                local pillEffect = PillEffect.PILLEFFECT_GULP
                local pillEntity = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_PILL, 0, Isaac.GetFreeNearPosition(player.Position, 40), Vector.Zero, nil)
                for _ = 1, 3 do
                pillEntity:ToPickup().Variant = Game():GetItemPool():ForceAddPillEffect(pillEffect)
                end
            end
            if finalKillScore >= 26000 and finalKillScore < 28000 then
                zeros()
                MOD:SpawnItemOfQuality(3, player:GetCollectibleRNG(CHEESE_GRATER), player.Position)
            end
            if finalKillScore >= 28000 and finalKillScore < 30000 then
                zeros()
                for _ = 1, 2 do
                    local pool = ItemPoolType.POOL_SECRET
                    local seed = Game():GetSeeds():GetStartSeed()
                    local collectible = Game():GetItemPool():GetCollectible(pool, true, seed)
                    while Isaac.GetItemConfig():GetCollectible(collectible).Quality ~= 3 do
                    collectible = Game():GetItemPool():GetCollectible(pool, true, seed)
                    end
                    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, collectible, Isaac.GetFreeNearPosition(player.Position, 40), Vector.Zero, nil)
                end
            end
            if finalKillScore >= 30000 then
                zeros()
                local reward = math.random(1,16)
                if reward == 1 then
                    for _ = 1, 3 do
                        local pool = ItemPoolType.POOL_SECRET
                        local seed = Game():GetSeeds():GetStartSeed()
                        local collectible = Game():GetItemPool():GetCollectible(pool, true, seed)
                        while Isaac.GetItemConfig():GetCollectible(collectible).Quality ~= 3 do
                        collectible = Game():GetItemPool():GetCollectible(pool, true, seed)
                        end
                        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, collectible, Isaac.GetFreeNearPosition(player.Position, 40), Vector.Zero, nil)
                    end
                end
                if reward == 2 then
                    MOD:SpawnItemOfQuality(4, player:GetCollectibleRNG(CHEESE_GRATER), player.Position)
                end
                if reward == 3 then
                    for _ = 1, 30 do
                        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_LOCKEDCHEST, 0, Isaac.GetFreeNearPosition(player.Position, 40), Vector.Zero, nil)
                    end
                    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, TrinketType.TRINKET_PAPER_CLIP, Isaac.GetFreeNearPosition(player.Position, 40), Vector.Zero, nil)
                end
                if reward == 4 then
                    for _ = 1, 30 do
                        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, 0, Isaac.GetFreeNearPosition(player.Position, 40), Vector.Zero, nil)
                    end
                    local pillEffect = PillEffect.PILLEFFECT_GULP
                    local pillEntity = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_PILL, 0, Isaac.GetFreeNearPosition(player.Position, 40), Vector.Zero, nil)
                    for _ = 1, 15 do
                    pillEntity:ToPickup().Variant = Game():GetItemPool():ForceAddPillEffect(pillEffect)
                    end
                end
                if reward == 5 then
                    playerBaseDamage = 13.5
                end
                if reward == 6 then
                    for _ = 1, 7 do
                        MOD:SpawnItemOfQuality(3, player:GetCollectibleRNG(CHEESE_GRATER), player.Position)
                    end
                end
                if reward == 7 then
                    player:AddCollectible(CollectibleType.COLLECTIBLE_PYRO)
                    player:AddCollectible(CollectibleType.COLLECTIBLE_DOLLAR)
                    player:AddCollectible(CollectibleType.COLLECTIBLE_SKELETON_KEY)
                    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_REVERSE_FOOL, Isaac.GetFreeNearPosition(player.Position, 40), Vector.Zero, nil)
                end
                if reward == 8 then
                    local player = Isaac.GetPlayer()
                    player:AddHealth(24)
                end
                if reward == 9 then
                    local pool = ItemPoolType.POOL_PLANETARIUM
                    local seed = Game():GetSeeds():GetStartSeed()
                    local collectible = Game():GetItemPool():GetCollectible(pool, true, seed)
                    for _ = 1, 4 do
                        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, collectible, Isaac.GetFreeNearPosition(player.Position, 40), Vector.Zero, nil)
                    end
                end
                if reward == 10 then
                    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, CollectibleType.COLLECTIBLE_R_KEY, Isaac.GetFreeNearPosition(player.Position, 40), Vector.Zero, nil)
                end
                if reward == 11 then
                    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, CollectibleType.COLLECTIBLE_DIPLOPIA, Isaac.GetFreeNearPosition(player.Position, 40), Vector.Zero, nil)
                    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, CollectibleType.COLLECTIBLE_DIPLOPIA, Isaac.GetFreeNearPosition(player.Position, 40), Vector.Zero, nil)
                end
                if reward == 12 then
                    for _ = 1, 6 do
                        local pool = ItemPoolType.POOL_ANGEL
                        local seed = Game():GetSeeds():GetStartSeed()
                        local collectible = Game():GetItemPool():GetCollectible(pool, true, seed)
                        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, collectible, Isaac.GetFreeNearPosition(player.Position, 40), Vector.Zero, nil)
                    end
                end
                if reward == 13 then
                    for _ = 1, 7 do
                        local pool = ItemPoolType.POOL_DEVIL
                        local seed = Game():GetSeeds():GetStartSeed()
                        local collectible = Game():GetItemPool():GetCollectible(pool, true, seed)
                        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, collectible, Isaac.GetFreeNearPosition(player.Position, 40), Vector.Zero, nil)
                    end
                end
                if reward == 14 then
                    player:AddCollectible(CollectibleType.COLLECTIBLE_INFAMY)
                    player:AddCollectible(CollectibleType.COLLECTIBLE_METAL_PLATE)
                    player:AddCollectible(CollectibleType.COLLECTIBLE_HOST_HAT)
                    player:AddCollectible(CollectibleType.COLLECTIBLE_JELLY_BELLY)
                end
                if reward == 15 then
                    player:AddCollectible(CollectibleType.COLLECTIBLE_DR_FETUS)
                    player:AddCollectible(CollectibleType.COLLECTIBLE_PYROMANIAC)
                end
                if reward == 16 then
                    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, CollectibleType.COLLECTIBLE_FORGET_ME_NOW, Isaac.GetFreeNearPosition(player.Position, 40), Vector.Zero, nil)
                    for _ = 1, 3 do
                        MOD:SpawnItemOfQuality(3, player:GetCollectibleRNG(CHEESE_GRATER), player.Position)
                    end
                end
                print(reward)
            end
        end
    end
end
MOD:AddCallback(ModCallbacks.MC_POST_UPDATE, ComboRewards)

function PlayerSpeedUp(_, player, playerID)
    local player = Isaac.GetPlayer(playerID)
    if player:HasCollectible(CHEESE_GRATER) then
     local move = Input.IsActionPressed(ButtonAction.ACTION_LEFT, 0) or
               Input.IsActionPressed(ButtonAction.ACTION_RIGHT, 0) or
               Input.IsActionPressed(ButtonAction.ACTION_UP, 0) or
                Input.IsActionPressed(ButtonAction.ACTION_DOWN, 0)
      if move and player:GetVelocityBeforeUpdate():Length() > wallCheck then
          player:AddCacheFlags(CacheFlag.CACHE_SPEED)
          player.MoveSpeed = player.MoveSpeed + speedToAdd * player:GetCollectibleNum(CHEESE_GRATER)
          if player.MoveSpeed >= speedCap + 0.05 * (player:GetCollectibleNum(CHEESE_GRATER)-1) then
              player.MoveSpeed = speedCap + 0.05 * (player:GetCollectibleNum(CHEESE_GRATER)-1)
          end
      else
        player.MoveSpeed = player.MoveSpeed - speedToRemove
        if player.MoveSpeed <= baseSpeed + 0.05 * (player:GetCollectibleNum(CHEESE_GRATER)-1) then
            player.MoveSpeed = baseSpeed + 0.05 * (player:GetCollectibleNum(CHEESE_GRATER)-1)
        end
      end
      if player.MoveSpeed >= boostLine then
        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_DROP, 1, player.Position, Vector.Zero, player)
      end
    else
        return
    end
end
MOD:AddCallback(ModCallbacks.MC_POST_UPDATE, PlayerSpeedUp)

function timerResetOnRunStart()
        timer = 0
        killCounter = 0
        combo = "0"
        stringFinalKillScore = "0"
        printTimer = "0"
        font:Unload()
end
MOD:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, timerResetOnRunStart)

function setBaseDamage(_, player, playerID)
    player = Isaac.GetPlayer()
    if player:HasCollectible(CHEESE_GRATER) then
        player.Damage = playerBaseDamage + (killCounter/5)
    end
end
MOD:AddCallback(ModCallbacks.MC_POST_UPDATE, setBaseDamage)

function DrawCombo()
    player = Isaac.GetPlayer()
    if player:HasCollectible(CHEESE_GRATER) and counterDrawn == false then
        MOD:AddCallback(ModCallbacks.MC_POST_RENDER, function()
            font:DrawString("Combo:".. combo, 320, 10, KColor(1,1,1,1), 0, false)
            end)
            MOD:AddCallback(ModCallbacks.MC_POST_RENDER, function()
            font:DrawString("Time:"..printTimer, 320, 25, KColor(1,1,1,1), 0, false)
            end)
            MOD:AddCallback(ModCallbacks.MC_POST_RENDER, function()
            font:DrawString("Score:"..stringFinalKillScore, 320, 40, KColor(1,1,1,1), 0, false)
            end)
            counterDrawn = true
    end
end
MOD:AddCallback(ModCallbacks.MC_POST_RENDER, DrawCombo)