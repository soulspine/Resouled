local CHEESE_GRATER = Isaac.GetItemIdByName("Cheese Grater")
local COMBO_DAMAGE_DIVIDER = 10
local SPEED_CAP = 2.25
local SPEED_TO_ADD_PER_FRAME = 0.005
local SPEED_TO_REMOVE_PER_FRAME = 0.05
local BASE_SPEED_OVERWRITE = 1
local BOOST_EFFECT_SPEED_THRESHOLD = 2.20
local wallCheck = 0.99
local killCounter = 0
local combo = ""
local oldKillCounter = 0
local killCounterTimer = 600
local timer = 0
local printTimer = ""
local finalKillScore = 0
local stringFinalKillScore = ""
local scoreToLose = 0
local font = Font()
local counterDrawn = false
local sfx = SFXManager()
local POSITION_OFFSET = Vector(0,-20)
local toppingCount = 0
local TOPPING_SUBTYPES = {
    MUSHROOM = 0,
    CHEESE = 1,
    TOMATO = 2,
    SAUSAGE = 3,
    PINEAPPLE = 4,
    PIZZA = 5,
}
local TOPPING_VARIANT_TRANSLATION = {
    [0] = "Mushroom",
    [1] = "Cheese",
    [2] = "Tomato",
    [3] = "Sausage",
    [4] = "Pineapple",
    [5] = "Pizza",
}
local MOVESPEEDFIX = 1
local TOPPING_VARIANT = Isaac.GetEntityVariantByName(TOPPING_VARIANT_TRANSLATION[toppingCount].." Pickup")
local speedScreen = Sprite()
local pizzaShootTimer = 0
local pizzaShootTreshold = 180
speedScreen:Load("gfx/effects/screen.anm2", true)
-- r = 1
-- R = 0.5
-- o = (4.5 ,6)
-- O = (-3 ,-2)
-- x=(rsin(ot)+Rsin(Ot),rcos(ot)+Rcos(Ot))

local function onUpdate()
    Resouled:IterateOverPlayers(function (player, playerID)
        if player:HasCollectible(CHEESE_GRATER) then
            MOVESPEEDFIX = player.MoveSpeed
            local playerRunSave = SAVE_MANAGER.GetRunSave(player)
            if playerRunSave.CheeseGrater == nil then
                playerRunSave.CheeseGrater = {
                    Combo = 0,
                    ComboTimer = 0,
                    TickTime = 0,
                    -- 100*Combo - TickTime//30 = Score
                    Dmg = player.Damage,
                }
            end
        end
    end)
end
Resouled:AddCallback(ModCallbacks.MC_POST_UPDATE, onUpdate)

local function onCacheEval()
    local player = Isaac.GetPlayer()
    if player:HasCollectible(CHEESE_GRATER) then
        local playerRunSave = SAVE_MANAGER.GetRunSave(player)
        if playerRunSave.CheeseGrater == nil then
            playerRunSave.CheeseGrater = {
                Combo = 0,
                ComboTimer = 0,
                TickTime = 0,
                -- 100*Combo - TickTime//30 = Score
                Dmg = player.Damage,
            }
        end
        playerRunSave.CheeseGrater.Dmg = player.Damage - (killCounter/COMBO_DAMAGE_DIVIDER)
        player.Damage = playerRunSave.CheeseGrater.Dmg + (killCounter/COMBO_DAMAGE_DIVIDER)
        player.MoveSpeed = MOVESPEEDFIX
    end
end
Resouled:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, onCacheEval)

local function cheeseGraterDamageFix()
    local player = Isaac.GetPlayer()
    local playerRunSave = SAVE_MANAGER.GetRunSave(player)
    if player:HasCollectible(CHEESE_GRATER) then
        playerRunSave.CheeseGrater.Dmg = player.Damage - (killCounter/COMBO_DAMAGE_DIVIDER)
        if playerRunSave.CheeseGrater.Dmg < 0.5 then
            playerRunSave.CheeseGrater.Dmg = 0.5
        end
        player.Damage = playerRunSave.CheeseGrater.Dmg + (killCounter/COMBO_DAMAGE_DIVIDER)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_UPDATE, cheeseGraterDamageFix)

---@param pickup EntityPickup
local function onPickupInit(_, pickup)
    player = Isaac.GetPlayer()
    if player:HasCollectible(CHEESE_GRATER) then
        local playerRunSave = SAVE_MANAGER.GetRunSave(player)
        playerRunSave.CheeseGrater.Dmg = player.Damage - (killCounter/COMBO_DAMAGE_DIVIDER)
        player.Damage = playerRunSave.CheeseGrater.Dmg + (killCounter/COMBO_DAMAGE_DIVIDER)
        player.MoveSpeed = MOVESPEEDFIX
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, onPickupInit, EntityPickup.PICKUP_COLLECTIBLE)

local function OnNewFloorRemoveToppings()
    local player = Isaac.GetPlayer()
    if player:HasCollectible(CHEESE_GRATER) then
        
        local playerRunSave = SAVE_MANAGER.GetRunSave(player)
        if toppingCount >= 5 then
            Game():Spawn(EntityType.ENTITY_FAMILIAR, Isaac.GetEntityVariantByName("Pizza Orbital"), player.Position, Vector.Zero, player, 0, 0)
        end
        for i=0, toppingCount-1 do
            for _, entity in ipairs(Isaac.GetRoomEntities()) do
                if entity.Variant == Isaac.GetEntityVariantByName(TOPPING_VARIANT_TRANSLATION[i].." Familiar") then
                    entity:Remove()
                end
            end
        end
        toppingCount = 0
        if timer > 0 then
            timer = timer - 60
        end
        player.Damage = playerRunSave.CheeseGrater.Dmg + (killCounter/COMBO_DAMAGE_DIVIDER)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, OnNewFloorRemoveToppings)

---@param familiar EntityFamiliar
function onPizzaFamiliarInit(_, familiar)
    familiar.PositionOffset = POSITION_OFFSET
    familiar:GetSprite():Play("Idle")
    local player = familiar.Player:ToPlayer()
    if player == nil then
        return
    end
end
Resouled:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, onPizzaFamiliarInit, Isaac.GetEntityVariantByName("Pizza Orbital"))

---@param familiar EntityFamiliar
local function onPizzaFamiliarUpdate(_, familiar)
    local randomEnemy
    local enemies = Isaac.GetRoomEntities()
    for _, entity in ipairs(enemies) do
        if entity:IsVulnerableEnemy() then
            randomEnemy = entity
            break
        end
    end
    local pos = Vector(0,0)
    if randomEnemy then
        pizzaShootTimer = pizzaShootTimer + 1
        pos = randomEnemy.Position
        familiar:FollowPosition(pos)
        if pizzaShootTimer == pizzaShootTreshold/4 then
            Game():Spawn(EntityType.ENTITY_TEAR, TearVariant.LOST_CONTACT, familiar.Position, Vector(0,0), player, 0, Game():GetRoom():GetSpawnSeed())
        end
        if pizzaShootTimer == 2*(pizzaShootTreshold/4) then
            Game():Spawn(EntityType.ENTITY_TEAR, TearVariant.LOST_CONTACT, familiar.Position, Vector(0,0), player, 0, Game():GetRoom():GetSpawnSeed())
        end
        if pizzaShootTimer == 3*(pizzaShootTreshold/4) then
            Game():Spawn(EntityType.ENTITY_TEAR, TearVariant.LOST_CONTACT, familiar.Position, Vector(0,0), player, 0, Game():GetRoom():GetSpawnSeed())
        end
        if pizzaShootTimer >= pizzaShootTreshold then
            Game():Spawn(EntityType.ENTITY_TEAR, TearVariant.LOST_CONTACT, familiar.Position, Vector(0,0), player, 0, Game():GetRoom():GetSpawnSeed())
            pizzaShootTimer = 0
        end
    else
        familiar:FollowParent()
    end
end
Resouled:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, onPizzaFamiliarUpdate, Isaac.GetEntityVariantByName("Pizza Orbital"))

local function rollToppingRooms()
    local cheeseGraterPresent = false
    ---@param player EntityPlayer
    Resouled:IterateOverPlayers(function(player, playerID)
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
        local maxRoomIndex = Game():GetLevel():GetRooms().Size - 1
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
Resouled:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, rollToppingRooms)

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
Resouled:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, tryToSpawnToppingInRoom)

local function ensureFloorSave()
    local floorSave = SAVE_MANAGER.GetFloorSave()
    if floorSave.CheeseGrater == nil then
        rollToppingRooms()
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_UPDATE, ensureFloorSave)

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
Resouled:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, onToppingPickupInit, TOPPING_VARIANT)

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
            timer = 0
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, onToppingPickupCollision, TOPPING_VARIANT)

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
Resouled:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, onToppingFamiliarInit, TOPPING_VARIANT)

---@param familiar EntityFamiliar
local function onToppingFamiliarUpdate(_, familiar)
    familiar:FollowParent()
end
Resouled:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, onToppingFamiliarUpdate, TOPPING_VARIANT)

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
    local player = Isaac.GetPlayer()
    if player:HasCollectible(CHEESE_GRATER) then
        
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
end
Resouled:AddCallback(ModCallbacks.MC_POST_UPDATE, CheeseGraterSpeedScreen)

function KillCounter()
    player = Isaac.GetPlayer()
    local playerRunSave = SAVE_MANAGER.GetRunSave(player)
    if player:HasCollectible(CHEESE_GRATER) then
        oldKillCounter = killCounter
        killCounter = killCounter + 1
        combo = tostring(killCounter)
        player.Damage = playerRunSave.CheeseGrater.Dmg + (killCounter/COMBO_DAMAGE_DIVIDER)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, KillCounter)

function KillCounterTimerCountdown()
    player = Isaac.GetPlayer()
    if player:HasCollectible(CHEESE_GRATER) then
        if killCounter > 0 then
            player:GetEffects()
            if player.MoveSpeed < BOOST_EFFECT_SPEED_THRESHOLD then
                timer = timer + 2
            else
                timer = timer + 1.5
            end
            printTimer = tostring(math.floor(((killCounterTimer/60)+1)-(timer/60)))
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
Resouled:AddCallback(ModCallbacks.MC_POST_UPDATE, KillCounterTimerCountdown)

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
            local playerRunSave = SAVE_MANAGER.GetRunSave(player)
            player.Damage = playerRunSave.CheeseGrater.Dmg
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
                Resouled:SpawnChaosItemOfQuality(1, player:GetCollectibleRNG(CHEESE_GRATER), player.Position)
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
                Resouled:SpawnChaosItemOfQuality(2, player:GetCollectibleRNG(CHEESE_GRATER), player.Position)
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
                Resouled:SpawnChaosItemOfQuality(2, player:GetCollectibleRNG(CHEESE_GRATER), player.Position)
                for _ = 1, 10 do
                    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, 0, Isaac.GetFreeNearPosition(player.Position, 40), Vector.Zero, nil)
                end
            end
            if finalKillScore >= 22000 and finalKillScore < 24000 then -- 22000 - 23999 five quality 1's
                zeros()
                for _ = 1, 5 do
                    Resouled:SpawnChaosItemOfQuality(1, player:GetCollectibleRNG(CHEESE_GRATER), player.Position)
                end
            end
            if finalKillScore >= 24000 and finalKillScore < 26000 then -- 24000 - 25999 10 trinkets, one time use pocket smelter
                zeros()
                for _ = 1, 10 do
                    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, 0, Isaac.GetFreeNearPosition(player.Position, 40), Vector.Zero, nil)
                end
                if player:GetActiveItem(ActiveSlot.SLOT_POCKET2) == CollectibleType.COLLECTIBLE_NULL then
                    player:SetPocketActiveItem(CollectibleType.COLLECTIBLE_SMELTER, ActiveSlot.SLOT_POCKET2, true)
                end
            end
            if finalKillScore >= 26000 and finalKillScore < 28000 then -- 26000 - 27999 one quality 3
                zeros()
                Resouled:SpawnChaosItemOfQuality(3, player:GetCollectibleRNG(CHEESE_GRATER), player.Position)
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
                    Resouled:SpawnChaosItemOfQuality(4, player:GetCollectibleRNG(CHEESE_GRATER), player.Position)
                    Resouled:SpawnChaosItemOfQuality(4, player:GetCollectibleRNG(CHEESE_GRATER), player.Position)
                end
                if reward == 3 then -- 30 golden chests, paper clip
                    for _ = 1, 30 do
                        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_LOCKEDCHEST, 0, Isaac.GetFreeNearPosition(player.Position, 40), Vector.Zero, nil)
                    end
                    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, TrinketType.TRINKET_PAPER_CLIP, Isaac.GetFreeNearPosition(player.Position, 40), Vector.Zero, nil)
                end
                if reward == 4 then -- 30 trinkets, one time use pocket smelter
                    for _ = 1, 30 do
                        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, 0, Isaac.GetFreeNearPosition(player.Position, 40), Vector.Zero, nil)
                    end
                    if player:GetActiveItem(ActiveSlot.SLOT_POCKET2) == CollectibleType.COLLECTIBLE_NULL then
                        player:SetPocketActiveItem(CollectibleType.COLLECTIBLE_SMELTER, ActiveSlot.SLOT_POCKET2, true)
                    end
                end
                if reward == 5 then -- damage set to 13.5
                    player = Isaac.GetPlayer()
                end
                if reward == 6 then -- 7 random quality 3's
                    for _ = 1, 7 do
                        Resouled:SpawnChaosItemOfQuality(3, player:GetCollectibleRNG(CHEESE_GRATER), player.Position)
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
                        Resouled:SpawnChaosItemOfQuality(3, player:GetCollectibleRNG(CHEESE_GRATER), player.Position)
                    end
                end
            end
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_UPDATE, ComboRewards)

function PlayerSpeedUp(_, player, playerID)
    local player = Isaac.GetPlayer(playerID)
    if player:HasCollectible(CHEESE_GRATER) then
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
Resouled:AddCallback(ModCallbacks.MC_POST_UPDATE, PlayerSpeedUp)

function timerResetOnRunStart()
        timer = 0
        killCounter = 0
        combo = "0"
        stringFinalKillScore = "0"
        printTimer = "0"
        toppingCount = 0
        counterDrawn = false
end
Resouled:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, timerResetOnRunStart)

function DrawCombo()
    player = Isaac.GetPlayer()
    if player:HasCollectible(CHEESE_GRATER) and counterDrawn == false then
        font:Load("font/terminus.fnt")
        Resouled:AddCallback(ModCallbacks.MC_POST_RENDER, function()
        font:DrawString("Combo:".. combo, 320, 10, KColor(1,1,1,1), 0, false)
        end)
        Resouled:AddCallback(ModCallbacks.MC_POST_RENDER, function()
        font:DrawString("Time:"..printTimer, 320, 25, KColor(1,1,1,1), 0, false)
        end)
        Resouled:AddCallback(ModCallbacks.MC_POST_RENDER, function()
        font:DrawString("Score:"..stringFinalKillScore, 320, 40, KColor(1,1,1,1), 0, false)
        end)
        counterDrawn = true
    elseif not player:HasCollectible(CHEESE_GRATER) and counterDrawn == false then
        font:Unload()
    end
end

Resouled:AddCallback(ModCallbacks.MC_POST_RENDER, DrawCombo)