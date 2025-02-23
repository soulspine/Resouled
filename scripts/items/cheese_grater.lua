local CHEESE_GRATER = Isaac.GetItemIdByName("Cheese Grater")
local SPEED_CAP = 2.25
local SPEED_TO_ADD_PER_FRAME = 0.005
local SPEED_TO_REMOVE_PER_FRAME = 0.05
local BASE_SPEED_OVERWRITE = 1
local BOOST_EFFECT_SPEED_THRESHOLD = 2.20
local wallCheck = 0.99
local timer = 0
local score = 0
local ranOutOfTime = false
local bossKilled = false
local stringScore = ""
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

local function resetScoreOnNewFloor()
    local floor = Game():GetLevel():GetStage()
    score = 200 + 10*(floor-1)
    timer = 0
    ranOutOfTime = false
    bossKilled = false
    stringScore = tostring(score)
end
Resouled:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, resetScoreOnNewFloor)

local function scoreCount()
    local player = Isaac.GetPlayer()
    if player:HasCollectible(CHEESE_GRATER) then
        if ranOutOfTime == false and bossKilled == false then            
            timer = timer + 1
        else
        end
        if timer % 30 == 0 and ranOutOfTime == false and bossKilled == false then
            score = score - 1
            stringScore = tostring(score)
        end
        if score <= 0 then
            ranOutOfTime = true
        end
        print(score)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_UPDATE, scoreCount)

local function toppingSpawning()
    local player = Isaac.GetPlayer()
    if player:HasCollectible(CHEESE_GRATER) then
        if ranOutOfTime == false then
            local room = Game():GetRoom()
            if room:GetType() == RoomType.ROOM_BOSS then
                Game():Spawn(EntityType.ENTITY_PICKUP, TOPPING_VARIANT, Isaac.GetFreeNearPosition(Isaac.GetRandomPosition(), 5), Vector.Zero, nil, toppingCount, Game():GetRoom():GetSpawnSeed())
                bossKilled = true
            end
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, toppingSpawning)

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
                Timer = 0,
                TickTime = 0,
                -- 100*Combo - TickTime//30 = Score
            }
        end
        player.MoveSpeed = MOVESPEEDFIX
    end
end
Resouled:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, onCacheEval)

---@param pickup EntityPickup
local function onPickupInit(_, pickup)
    local player = Isaac.GetPlayer()
    if player:HasCollectible(CHEESE_GRATER) then
        player.MoveSpeed = MOVESPEEDFIX
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, onPickupInit, EntityPickup.PICKUP_COLLECTIBLE)

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
    local player = Isaac.GetPlayer()
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
        toppingCount = 0
        counterDrawn = false
end
Resouled:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, timerResetOnRunStart)

function DrawCombo()
    local player = Isaac.GetPlayer()
    if player:HasCollectible(CHEESE_GRATER) and counterDrawn == false then
        font:Load("font/terminus.fnt")
        Resouled:AddCallback(ModCallbacks.MC_POST_RENDER, function()
        font:DrawString("Score:"..stringScore, 320, 40, KColor(1,1,1,1), 0, false)
        end)
        counterDrawn = true
    elseif not player:HasCollectible(CHEESE_GRATER) and counterDrawn == false then
        font:Unload()
    end
end

Resouled:AddCallback(ModCallbacks.MC_POST_RENDER, DrawCombo)