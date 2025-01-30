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
font:Load("font/terminus.fnt")

function KillCounter()
    oldKillCounter = killCounter
    killCounter = killCounter + 1
    combo = tostring(killCounter)
    if player:HasCollectible(CHEESE_GRATER) then
    player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
    player.Damage = playerBaseDamage + (killCounter/5)
    end
end

function KillCounterTimerCountdown()
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
            print("timer reset")
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

function ComboRewards()
    player = Isaac.GetPlayer()
    local function zeros()
        timer = 0
        killCounter = 0
        combo = "0"
        stringFinalKillScore = "0"
        printTimer = "0"
        scoreToLose = 0
    end
    if timer >= killCounterTimer then
        if finalKillScore < 2000 then
            zeros()
        end
        if finalKillScore >= 2000 and finalKillScore < 4000 then
            zeros()
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, player.Position, Vector.Zero, player)
        end
        if finalKillScore >= 4000 and finalKillScore < 6000 then
            zeros()
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, CollectibleType.COLLECTIBLE_DOLLAR, player.Position, Vector.Zero, player)
        end
    end
end

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

function timerResetOnRunEnd()
        timer = 0
        killCounter = 0
        combo = "0"
        stringFinalKillScore = "0"
        printTimer = "0"
end

function setBaseDamage(_, player, playerID)
    player = Isaac.GetPlayer()
    if player:HasCollectible(CHEESE_GRATER) then
        player.Damage = playerBaseDamage + (killCounter/5)
    end
end

MOD:AddCallback(ModCallbacks.MC_POST_UPDATE, PlayerSpeedUp)
MOD:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, KillCounter)
MOD:AddCallback(ModCallbacks.MC_POST_UPDATE, KillCounterTimerCountdown)
MOD:AddCallback(ModCallbacks.MC_POST_RENDER, function()
font:DrawString(combo, 140, 15, KColor(1,1,1,1), 0, true)
end)
MOD:AddCallback(ModCallbacks.MC_POST_RENDER, function()
font:DrawString(printTimer, 180, 15, KColor(1,1,1,1), 0, true)
end)
MOD:AddCallback(ModCallbacks.MC_POST_RENDER, function()
font:DrawString(stringFinalKillScore, 220, 15, KColor(1,1,1,1), 0, true)
end)
MOD:AddCallback(ModCallbacks.MC_POST_UPDATE, ComboRewards)
MOD:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, timerResetOnRunEnd)
MOD:AddCallback(ModCallbacks.MC_POST_UPDATE, setBaseDamage)