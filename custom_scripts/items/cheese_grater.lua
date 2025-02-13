local CHEESE_GRATER = Isaac.GetItemIdByName("Cheese Grater")
local SPEED_CAP = 2.25
local SPEED_TO_ADD_PER_FRAME = 0.005
local SPEED_TO_REMOVE_PER_FRAME = 0.05
local BASE_SPEED_OVERWRITE = 1
local BOOST_EFFECT_SPEED_THRESHOLD = 2.20
local wallCheck = 0.99
local killCounter = 0
local combo = ""
local oldKillCounter = 0
local killCounterTimer = 300
local timer = 0
local printTimer = ""
local finalKillScore = 0
local stringFinalKillScore = ""
local scoreToLose = 0
local font = Font()
local counterDrawn = false
local sfx = SFXManager()
local playerDamageCalc = 5
local POSITION_OFFSET = Vector(0,-20)
local toppingCount = 0
local TOPPING_SUBTYPES = {
    MUSHROOM = 0,
    CHEESE = 1,
    TOMATO = 2,
    SAUSAGE = 3,
    PINEAPPLE = 4,
}
local TOPPING_VARIANT_TRANSLATION = {
    [0] = "Mushroom",
    [1] = "Cheese",
    [2] = "Tomato",
    [3] = "Sausage",
    [4] = "Pineapple",
}
local TOPPING_VARIANT = Isaac.GetEntityVariantByName(TOPPING_VARIANT_TRANSLATION[toppingCount].." Pickup")
local toppingRoomCount = 0
local roomsWithNoToppings = 1
local roomCount = 0
local topping = Isaac.GetEntityTypeByName("Topping Familiar")
local speedScreen = Sprite()
speedScreen:Load("gfx/effects/screen.anm2", true)

local function rollToppingRooms()
    local cheeseGraterPresent = false
    ---@param player EntityPlayer
    IterateOverPlayers(function(player, playerID)
        if player:HasCollectible(CHEESE_GRATER) then
            cheeseGraterPresent = true
        end
    end)

    if cheeseGraterPresent then
        local floorSave = SAVE_MANAGER.GetFloorSave()
        floorSave.CheeseGrater = {
            SpawnedCount  = 0,
            Rooms = {},
            SpawnedInRooms = {},
        }
        local maxRoomIndex = Game():GetLevel():GetRooms().Size + 1
        local rng = player:GetCollectibleRNG(CHEESE_GRATER)
        
        for _ = 1, 5 do
            ::reroll::
            local newRoomIndex = rng:RandomInt(maxRoomIndex)
            for _, roomIndex in ipairs(floorSave.CheeseGrater.Rooms) do
                if roomIndex == newRoomIndex then
                    goto reroll
                end
            end
            table.insert(floorSave.CheeseGrater.Rooms, newRoomIndex)
            table.insert(floorSave.CheeseGrater.SpawnedInRooms, false)
        end
    end
end
MOD:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, rollToppingRooms)

local function tryToSpawnToppingInRoom()
    local room = Game():GetRoom()

    local roomDescriptor = Game():GetLevel():GetCurrentRoomDesc()
    local floorSave = SAVE_MANAGER.GetFloorSave()

    if floorSave.CheeseGrater == nil then
        return
    end

    local validRoom = false
    for i, roomIndex in ipairs(floorSave.CheeseGrater.Rooms) do
        if roomIndex == roomDescriptor.ListIndex and not floorSave.CheeseGrater.SpawnedInRooms[i] then
            floorSave.CheeseGrater.SpawnedInRooms[i] = true
            validRoom = true
            break
        end
    end

    if validRoom then
        Game():Spawn(EntityType.ENTITY_PICKUP, TOPPING_VARIANT, Isaac.GetFreeNearPosition(Isaac.GetRandomPosition(), 500), Vector.Zero, nil, toppingCount, room:GetSpawnSeed())
        floorSave.CheeseGrater.SpawnedCount = floorSave.CheeseGrater.SpawnedCount + 1
    end
end
MOD:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, tryToSpawnToppingInRoom)

local function ensureFloorSave()
    local floorSave = SAVE_MANAGER.GetFloorSave()
    if floorSave.CheeseGrater == nil then
        rollToppingRooms()
    end
end
MOD:AddCallback(ModCallbacks.MC_POST_UPDATE, ensureFloorSave)

---@param pickup EntityPickup
function onToppingPickupInit(_, pickup)
    local sprite = pickup:GetSprite()
    local animationName  = ""

    if pickup.SubType == TOPPING_SUBTYPES.MUSHROOM then
        animationName = "Mushroom"
    elseif pickup.SubType == TOPPING_SUBTYPES.CHEESE then
        animationName = "Cheese"
    elseif pickup.SubType == TOPPING_SUBTYPES.TOMATO then
        animationName = "Tomato"
    elseif pickup.SubType == TOPPING_SUBTYPES.SAUSAGE then
        animationName = "Sausage"
    elseif pickup.SubType == TOPPING_SUBTYPES.PINEAPPLE then
        animationName = "Pineapple"
    end

    sprite:Play(animationName, true)
    pickup.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
end
MOD:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, onToppingPickupInit, TOPPING_VARIANT)

function onToppingPickupCollision(_, pickup, collider)
    if collider.Type == EntityType.ENTITY_PLAYER then
        local player = collider:ToPlayer()
        local room = Game():GetRoom()

        if player == nil then
            return
        end

        if player:HasCollectible(CHEESE_GRATER) then
            pickup:Remove()
            Game():Spawn(EntityType.ENTITY_FAMILIAR, TOPPING_VARIANT, pickup.Position, Vector.Zero, player, toppingCount, room:GetSpawnSeed())
            toppingCount = toppingCount + 1
        end
    end
end
MOD:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, onToppingPickupCollision, TOPPING_VARIANT, player)

---@param familiar EntityFamiliar
function onToppingFamiliarInit(_, familiar)
    familiar.PositionOffset = POSITION_OFFSET
    familiar:AddToFollowers()
    familiar:GetSprite():Play(TOPPING_VARIANT_TRANSLATION[toppingCount])
    local player = familiar.Player:ToPlayer()
    if player == nil then
        return
    end
end
MOD:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, onToppingFamiliarInit, TOPPING_VARIANT)

---@param familiar EntityFamiliar
local function onToppingFamiliarUpdate(_, familiar)
    familiar:FollowParent()
end
MOD:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, onToppingFamiliarUpdate, TOPPING_VARIANT)

HudHelper.RegisterHUDElement({
    Name = "HudHelperExample",
    Priority = HudHelper.Priority.NORMAL,
    XPadding = 0,
    YPadding = 100,
    Condition = function(player, playerHUDIndex, hudLayout)
        return player:HasCollectible(CHEESE_GRATER)
    end,
    OnRender = function(player, playerHUDIndex, hudLayout, position)
        speedScreen.Scale = Vector(0.35, 0.35)
        speedScreen:Update()
        speedScreen:Render(position + HudHelper.GetHealthHUDOffset(playerHUDIndex))
    end,
    BypassGhostBaby = true,
}, HudHelper.HUDType.EXTRA)

local SPRITE_SPEED_SCREEN_LEVEL_1_THRESHOLD = 1.25
local SPRITE_SPEED_SCREEN_LEVEL_2_THRESHOLD = 2.2

function CheeseGraterSpeedScreen()
    speedScreen:Update()
    if player.MoveSpeed < SPRITE_SPEED_SCREEN_LEVEL_1_THRESHOLD then
        speedScreen:Play("Idle",true)
    elseif player.MoveSpeed >= SPRITE_SPEED_SCREEN_LEVEL_1_THRESHOLD and player.MoveSpeed < SPRITE_SPEED_SCREEN_LEVEL_2_THRESHOLD then
        speedScreen:Play("Run 1", true)
        speedScreen:LoadGraphics()
    elseif player.MoveSpeed >= SPRITE_SPEED_SCREEN_LEVEL_2_THRESHOLD then
        speedScreen:Play("Run 2", true)
    end 
end
MOD:AddCallback(ModCallbacks.MC_POST_UPDATE, CheeseGraterSpeedScreen)

local function onUpdate()
    IterateOverPlayers(function (player, playerID)
        if player:HasCollectible(CHEESE_GRATER) then
            local playerRunSave = SAVE_MANAGER.GetRunSave(player)
            
            if playerRunSave == nil then
                playerRunSave = {
                    Combo = 0,
                    ComboTimer = 0,
                    TickTime = 0,
                    -- 100*Combo - TickTime//30 = Score
                }
            end

        end
    end)
end
MOD:AddCallback(ModCallbacks.MC_POST_UPDATE, onUpdate)


function KillCounter()
    player = Isaac.GetPlayer()
    if player:HasCollectible(CHEESE_GRATER) then
        oldKillCounter = killCounter
        killCounter = killCounter + 1
        combo = tostring(killCounter)
        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
        player.Damage = playerDamageCalc + (killCounter/5)
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
            if finalKillScore < 2000 then --under 2000 no reward
                zeros()
            end
            if finalKillScore >= 2000 and finalKillScore < 4000 then -- 2000 - 3999 one coin
                zeros()
                Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, Isaac.GetFreeNearPosition(player.Position, 40), Vector.Zero, nil)
            end
            if finalKillScore >= 4000 and finalKillScore < 6000 then -- 4000 - 5999 three sacks
                zeros()
                Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_GRAB_BAG, 0, Isaac.GetFreeNearPosition(player.Position, 40), Vector.Zero, nil)
                Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_GRAB_BAG, 0, Isaac.GetFreeNearPosition(player.Position, 40), Vector.Zero, nil)
                Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_GRAB_BAG, 0, Isaac.GetFreeNearPosition(player.Position, 40), Vector.Zero, nil)
            end
            if finalKillScore >= 6000 and finalKillScore < 8000 then -- 6000 - 7999 three chests
                zeros()
                Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_CHEST, 0, Isaac.GetFreeNearPosition(player.Position, 40), Vector.Zero, nil)
                Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_CHEST, 0, Isaac.GetFreeNearPosition(player.Position, 40), Vector.Zero, nil)
                Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_CHEST, 0, Isaac.GetFreeNearPosition(player.Position, 40), Vector.Zero, nil)
            end
            if finalKillScore >= 8000 and finalKillScore < 10000 then -- 8000 - 9999 one trinket
                zeros()
                Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, 0, Isaac.GetFreeNearPosition(player.Position, 40), Vector.Zero, nil)
            end
            if finalKillScore >= 10000 and finalKillScore < 12000 then -- 10000 - 11999 one quality 1
                zeros()
                MOD:SpawnItemOfQuality(1, player:GetCollectibleRNG(CHEESE_GRATER), player.Position)
            end
            if finalKillScore >= 12000 and finalKillScore < 14000 then -- 12000 - 13999 20 carot cards
                zeros()
                for _ = 1, 20 do
                Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, 0, Isaac.GetFreeNearPosition(player.Position, 40), Vector.Zero, nil)
                end
            end
            if finalKillScore >= 14000 and finalKillScore < 16000 then -- 14000 - 15999 20 sacks
                zeros()
                for _ = 1, 20 do
                Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_GRAB_BAG, 0, Isaac.GetFreeNearPosition(player.Position, 40), Vector.Zero, nil)
                end
            end
            if finalKillScore >= 16000 and finalKillScore < 18000 then -- 16000 - 17999 one quality 2
                zeros()
                MOD:SpawnItemOfQuality(2, player:GetCollectibleRNG(CHEESE_GRATER), player.Position)
            end
            if finalKillScore >= 18000 and finalKillScore < 20000 then -- 18000 - 19999 10 golden chests, 10 keys, 3 sacks
                zeros()
                for _ = 1, 10 do
                    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_LOCKEDCHEST, 0, Isaac.GetFreeNearPosition(player.Position, 40), Vector.Zero, nil)
                    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_KEY, 0, Isaac.GetFreeNearPosition(player.Position, 40), Vector.Zero, nil)
                end
                for _ = 1, 3 do
                    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_GRAB_BAG, 1, Isaac.GetFreeNearPosition(player.Position, 40), Vector.Zero, nil)
                end
            end
            if finalKillScore >= 20000 and finalKillScore < 22000 then -- 20000 - 21999 one quality 2, 10 trinkets
                zeros()
                MOD:SpawnItemOfQuality(2, player:GetCollectibleRNG(CHEESE_GRATER), player.Position)
                for _ = 1, 10 do
                    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, 0, Isaac.GetFreeNearPosition(player.Position, 40), Vector.Zero, nil)
                end
            end
            if finalKillScore >= 22000 and finalKillScore < 24000 then -- 22000 - 23999 five quality 1's
                zeros()
                for _ = 1, 5 do
                    MOD:SpawnItemOfQuality(1, player:GetCollectibleRNG(CHEESE_GRATER), player.Position)
                end
            end
            if finalKillScore >= 24000 and finalKillScore < 26000 then -- 24000 - 25999 10 trinkets, 3 gulp pills
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
            if finalKillScore >= 26000 and finalKillScore < 28000 then -- 26000 - 27999 one quality 3
                zeros()
                MOD:SpawnItemOfQuality(3, player:GetCollectibleRNG(CHEESE_GRATER), player.Position)
            end
            if finalKillScore >= 28000 and finalKillScore < 30000 then -- 28000 - 29999 two secret room items bellow quality 4
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
            if finalKillScore >= 30000 then -- 30000+ random effect from bellow
                zeros()
                local reward = math.random(1,16)
                if reward == 1 then -- three random secret room items
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
                if reward == 2 then -- 2 random quality 4's
                    MOD:SpawnItemOfQuality(4, player:GetCollectibleRNG(CHEESE_GRATER), player.Position)
                    MOD:SpawnItemOfQuality(4, player:GetCollectibleRNG(CHEESE_GRATER), player.Position)
                end
                if reward == 3 then -- 30 golden chests, paper clip
                    for _ = 1, 30 do
                        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_LOCKEDCHEST, 0, Isaac.GetFreeNearPosition(player.Position, 40), Vector.Zero, nil)
                    end
                    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, TrinketType.TRINKET_PAPER_CLIP, Isaac.GetFreeNearPosition(player.Position, 40), Vector.Zero, nil)
                end
                if reward == 4 then -- 30 trinkets, 15 gulp pills
                    for _ = 1, 30 do
                        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, 0, Isaac.GetFreeNearPosition(player.Position, 40), Vector.Zero, nil)
                    end
                    local pillEffect = PillEffect.PILLEFFECT_GULP
                    local pillEntity = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_PILL, 0, Isaac.GetFreeNearPosition(player.Position, 40), Vector.Zero, nil)
                    for _ = 1, 15 do
                    pillEntity:ToPickup().Variant = Game():GetItemPool():ForceAddPillEffect(pillEffect)
                    end
                end
                if reward == 5 then -- damage set to 13.5
                    player = Isaac.GetPlayer()
                    playerDamageCalc = 13.5
                end
                if reward == 6 then -- 7 random quality 3's
                    for _ = 1, 7 do
                        MOD:SpawnItemOfQuality(3, player:GetCollectibleRNG(CHEESE_GRATER), player.Position)
                    end
                end
                if reward == 7 then -- Pyro, Dollar, Skeleto Key, reverse fool
                    player:AddCollectible(CollectibleType.COLLECTIBLE_PYRO)
                    player:AddCollectible(CollectibleType.COLLECTIBLE_DOLLAR)
                    player:AddCollectible(CollectibleType.COLLECTIBLE_SKELETON_KEY)
                    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_REVERSE_FOOL, Isaac.GetFreeNearPosition(player.Position, 40), Vector.Zero, nil)
                end
                if reward == 8 then -- Full Heal
                    local player = Isaac.GetPlayer()
                    player:AddHealth(24)
                end
                if reward == 9 then -- 4 random planetarium items
                    for _ = 1, 4 do
                        local pool = ItemPoolType.POOL_PLANETARIUM
                        local seed = Game():GetSeeds():GetStartSeed()
                        local collectible = Game():GetItemPool():GetCollectible(pool, true, seed)
                        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, collectible, Isaac.GetFreeNearPosition(player.Position, 40), Vector.Zero, nil)
                    end
                end
                if reward == 10 then -- R key
                    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, CollectibleType.COLLECTIBLE_R_KEY, Isaac.GetFreeNearPosition(player.Position, 40), Vector.Zero, nil)
                end
                if reward == 11 then -- 2 diplopias
                    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, CollectibleType.COLLECTIBLE_DIPLOPIA, Isaac.GetFreeNearPosition(player.Position, 40), Vector.Zero, nil)
                    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, CollectibleType.COLLECTIBLE_DIPLOPIA, Isaac.GetFreeNearPosition(player.Position, 40), Vector.Zero, nil)
                end
                if reward == 12 then -- 6 angel items
                    for _ = 1, 6 do
                        local pool = ItemPoolType.POOL_ANGEL
                        local seed = Game():GetSeeds():GetStartSeed()
                        local collectible = Game():GetItemPool():GetCollectible(pool, true, seed)
                        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, collectible, Isaac.GetFreeNearPosition(player.Position, 40), Vector.Zero, nil)
                    end
                end
                if reward == 13 then -- 7 devil items
                    for _ = 1, 7 do
                        local pool = ItemPoolType.POOL_DEVIL
                        local seed = Game():GetSeeds():GetStartSeed()
                        local collectible = Game():GetItemPool():GetCollectible(pool, true, seed)
                        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, collectible, Isaac.GetFreeNearPosition(player.Position, 40), Vector.Zero, nil)
                    end
                end
                if reward == 14 then -- Infamy, Metal Plate, Host Hat, Jelly Belly
                    player:AddCollectible(CollectibleType.COLLECTIBLE_INFAMY)
                    player:AddCollectible(CollectibleType.COLLECTIBLE_METAL_PLATE)
                    player:AddCollectible(CollectibleType.COLLECTIBLE_HOST_HAT)
                    player:AddCollectible(CollectibleType.COLLECTIBLE_JELLY_BELLY)
                end
                if reward == 15 then -- Dr.Fetus, Pyromaniac
                    player:AddCollectible(CollectibleType.COLLECTIBLE_DR_FETUS)
                    player:AddCollectible(CollectibleType.COLLECTIBLE_PYROMANIAC)
                end
                if reward == 16 then -- Forget Me Now, 3 random quality 3's
                    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, CollectibleType.COLLECTIBLE_FORGET_ME_NOW, Isaac.GetFreeNearPosition(player.Position, 40), Vector.Zero, nil)
                    for _ = 1, 3 do
                        MOD:SpawnItemOfQuality(3, player:GetCollectibleRNG(CHEESE_GRATER), player.Position)
                    end
                end
            end
        end
    end
end
MOD:AddCallback(ModCallbacks.MC_POST_UPDATE, ComboRewards)

function PlayerSpeedUp(_, player, playerID)
    local player = Isaac.GetPlayer(playerID)
    if player:HasCollectible(CHEESE_GRATER) then
        player.Damage = playerDamageCalc + (killCounter/5)
     local move = Input.IsActionPressed(ButtonAction.ACTION_LEFT, 0) or
               Input.IsActionPressed(ButtonAction.ACTION_RIGHT, 0) or
               Input.IsActionPressed(ButtonAction.ACTION_UP, 0) or
                Input.IsActionPressed(ButtonAction.ACTION_DOWN, 0)
      if move and player:GetVelocityBeforeUpdate():Length() > wallCheck then
          player:AddCacheFlags(CacheFlag.CACHE_SPEED)
          player.MoveSpeed = player.MoveSpeed + SPEED_TO_ADD_PER_FRAME * player:GetCollectibleNum(CHEESE_GRATER)
          if player.MoveSpeed >= SPEED_CAP + 0.05 * (player:GetCollectibleNum(CHEESE_GRATER)-1) then
              player.MoveSpeed = SPEED_CAP + 0.05 * (player:GetCollectibleNum(CHEESE_GRATER)-1)
          end
      else
        player.MoveSpeed = player.MoveSpeed - SPEED_TO_REMOVE_PER_FRAME
        if player.MoveSpeed <= BASE_SPEED_OVERWRITE + 0.05 * (player:GetCollectibleNum(CHEESE_GRATER)-1) then
            player.MoveSpeed = BASE_SPEED_OVERWRITE + 0.05 * (player:GetCollectibleNum(CHEESE_GRATER)-1)
        end
      end
      if player.MoveSpeed >= BOOST_EFFECT_SPEED_THRESHOLD then
        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_DROP, 1, player.Position, Vector.Zero, player)
      end
    else
        return
    end
end
MOD:AddCallback(ModCallbacks.MC_POST_UPDATE, PlayerSpeedUp)

function timerResetOnRunStart()
        playerDamageCalc = 5
        timer = 0
        killCounter = 0
        combo = "0"
        stringFinalKillScore = "0"
        printTimer = "0"
        toppingCount = 0
        counterDrawn = false
        
end
MOD:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, timerResetOnRunStart)

function DrawCombo()
    player = Isaac.GetPlayer()
    if player:HasCollectible(CHEESE_GRATER) and counterDrawn == false then
        font:Load("font/terminus.fnt")
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
    elseif not player:HasCollectible(CHEESE_GRATER) and counterDrawn == false then
        font:Unload()
    end
end
MOD:AddCallback(ModCallbacks.MC_POST_RENDER, DrawCombo)