local CHEESE_GRATER = Isaac.GetItemIdByName("Cheese Grater")

local sfx = SFXManager()
local PIZZA_CUT_SFX = Isaac.GetSoundIdByName("Pizza cut")

local BASE_SCORE = 60
local SCORE_PER_FLOOR = 25
local SCORE_LOSS_PER_UPDATE_PRE_BOSS_CLEAR = 1
local SCORE_LOSS_PER_UPDATE_POST_BOSS_CLEAR = 2
local POSITION_OFFSET = Vector(0,-100)

local PIZZA_COLLISION_DAMAGE_DPS = 30
local PIZZA_COLLISION_DAMAGE_COUNTDOWN = 30 -- no idea what this does
local PIZZA_COLLISION_DISTANCE_MARGIN = 25
local PIZZA_VELOCITY_MULTIPLIER = 15
local PIZZA_SIZE_MULTIPLIER = Vector(1, 1)
local PIZZA_ROTATION_GAIN = 66

-- score displays
local SCORE_TEXT_POSITION = Vector(Isaac.GetScreenWidth()/2, 10)
local SCORE_TEXT_COLOR = KColor(1, 0, 0, 1)
local SCORE_TEXT_BOX_WIDTH = 5
local SCORE_TEXT_CENTER = true
local FONT = Font()
FONT:Load("font/teammeatfont16.fnt")
local globalScore = 0

-- speed screen display
local SPEED_SCREEN_SPRITE = Sprite()
SPEED_SCREEN_SPRITE:Load("gfx/effects/screen.anm2", true)
local ANIMATION_SPEED_SCREEN_IDLE = "Idle"
local ANIMATION_SPEED_SCREEN_RUN1 = "Run1"
local ANIMATION_SPEED_SCREEN_RUN2 = "Run2"
local ANIMATION_SPEED_SCREEN_SWITCH = "Screen Switch"
local screenTargetAnimation

local TOPPING_VARIANT = Isaac.GetEntityVariantByName("Pizza Familiar")

local TOPPING_SUBTYPES = {
    MUSHROOM = 0,
    CHEESE = 1,
    TOMATO = 2,
    SAUSAGE = 3,
    PINEAPPLE = 4,
    PIZZA = 5,
}
local TOPPING_SUBTYPE_ANIMATION_TRANSLATION = {
    [0] = "Mushroom",
    [1] = "Cheese",
    [2] = "Tomato",
    [3] = "Sausage",
    [4] = "Pineapple",
    [5] = "Pizza",
}

local MAX_SPEED = 2.25
local SPEED_TO_ADD_PER_FRAME = 0.005
local SPEED_TO_REMOVE_PER_FRAME = 0.05
local MIN_SPEED = 1
local BOOST_EFFECT_SPEED_THRESHOLD = 2.20

local function resetScoreOnNewFloor()
    local runSave = SAVE_MANAGER.GetRunSave()

    if not runSave.CheeseGrater then
        runSave.CheeseGrater = {
            Floor = 0,
        }
    else
        runSave.CheeseGrater.Floor = runSave.CheeseGrater.Floor + 1
    end

    runSave.CheeseGrater.SpawnedRewards = false
    runSave.CheeseGrater.BossKilled = false
    runSave.CheeseGrater.Duration = 0
    runSave.CheeseGrater.Score = BASE_SCORE + SCORE_PER_FLOOR * runSave.CheeseGrater.Floor
    
end
Resouled:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, resetScoreOnNewFloor)

local function tryGrantPizzaFamiliar()
    ---@param player EntityPlayer
    Resouled:IterateOverPlayers(function(player)
        if player:HasCollectible(CHEESE_GRATER) then
            local playerRunSave = SAVE_MANAGER.GetRunSave(player)
            local toppingCount = 0
            if playerRunSave.CheeseGrater and playerRunSave.CheeseGrater.ObtainedFamiliars then
                for _, obtained in pairs(playerRunSave.CheeseGrater.ObtainedFamiliars) do
                    if obtained then
                        toppingCount = toppingCount + 1
                    end
                end
            end

            if toppingCount == 3 then
                for i = 1, #TOPPING_SUBTYPES do
                    player:CheckFamiliar(TOPPING_VARIANT, 0, RNG(), nil, TOPPING_SUBTYPES[i])
                end

                playerRunSave.CheeseGrater.ObtainedFamiliars[TOPPING_SUBTYPES.PIZZA] = true

                Game():Spawn(EntityType.ENTITY_FAMILIAR, TOPPING_VARIANT, Isaac.GetRandomPosition(), Vector.Zero, player, TOPPING_SUBTYPES.PIZZA, player.InitSeed)
            end
        end

    end)
end
Resouled:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, tryGrantPizzaFamiliar)

local function updateScoreOnGameUpdate()
    if Resouled:CollectiblePresent(CHEESE_GRATER) then
        local runSave = SAVE_MANAGER.GetRunSave()

        if runSave.CheeseGrater then
            if runSave.CheeseGrater.Score > 0 then
                runSave.CheeseGrater.Duration = runSave.CheeseGrater.Duration + 1

                if not runSave.CheeseGrater.BossKilled then
                    if runSave.CheeseGrater.Duration % 30 == 0 then -- 30 because there are 30 updates / s
                        runSave.CheeseGrater.Score = math.max(runSave.CheeseGrater.Score - SCORE_LOSS_PER_UPDATE_PRE_BOSS_CLEAR, 0)
                    end
                else
                    runSave.CheeseGrater.Score = math.max(runSave.CheeseGrater.Score - SCORE_LOSS_PER_UPDATE_POST_BOSS_CLEAR, 0)
                end
                globalScore = runSave.CheeseGrater.Score
            elseif not runSave.CheeseGrater.SpawnedRewards and runSave.CheeseGrater.BossKilled and runSave.CheeseGrater.FinalScore > 0 then -- and finalscore == 0
                ---@param player EntityPlayer
                Resouled:IterateOverPlayers(function(player)
                    if player:HasCollectible(CHEESE_GRATER) then
                        local playerRunSave = SAVE_MANAGER.GetRunSave(player)
                        if not playerRunSave.CheeseGrater then
                            playerRunSave.CheeseGrater = {}
                            playerRunSave.CheeseGrater.ObtainedFamiliars = {}
                            for _, familiarSubtype in pairs(TOPPING_SUBTYPES) do
                                playerRunSave.CheeseGrater.ObtainedFamiliars[familiarSubtype] = false
                            end
                        end

                        if playerRunSave.CheeseGrater.ObtainedFamiliars[TOPPING_SUBTYPES.PIZZA] then
                            return
                        end

                        local validFamiliars = {}

                        for familiarSubtype, obtained in pairs(playerRunSave.CheeseGrater.ObtainedFamiliars) do
                            if not obtained and familiarSubtype ~= TOPPING_SUBTYPES.PIZZA then
                                table.insert(validFamiliars, familiarSubtype)
                            end
                        end

                        local rng = RNG()
                        local spawnSeed = Game():GetRoom():GetSpawnSeed()
                        rng:SetSeed(spawnSeed, 0)

                        local selectedFamiliar = validFamiliars[rng:RandomInt(#validFamiliars) + 1]

                        playerRunSave.CheeseGrater.ObtainedFamiliars[selectedFamiliar] = true

                        Game():Spawn(EntityType.ENTITY_FAMILIAR, TOPPING_VARIANT, Isaac.GetRandomPosition(), Vector.Zero, player, selectedFamiliar, spawnSeed)
                        
                    end
                end)
                runSave.CheeseGrater.SpawnedRewards = true
            end
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_UPDATE, updateScoreOnGameUpdate)

local function postBossClear()
    local room = Game():GetRoom()
    if room:IsCurrentRoomLastBoss() then
        local runSave = SAVE_MANAGER.GetRunSave()
        runSave.CheeseGrater.BossKilled = true
        runSave.CheeseGrater.FinalScore = runSave.CheeseGrater.Score
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, postBossClear)

---@param familiar EntityFamiliar
local function onToppingFamiliarInit(_, familiar)
    if familiar.SubType ~= TOPPING_SUBTYPES.PIZZA then    
        familiar.PositionOffset = POSITION_OFFSET
    end
    familiar:GetSprite():Play(TOPPING_SUBTYPE_ANIMATION_TRANSLATION[familiar.SubType])
    familiar.GridCollisionClass = GridCollisionClass.COLLISION_WALL
    familiar.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ENEMIES
    if familiar.SubType == TOPPING_SUBTYPES.PIZZA then
        familiar.SizeMulti = PIZZA_SIZE_MULTIPLIER
        familiar.SpriteRotation = math.random(0, 360)
    end
end
Resouled:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, onToppingFamiliarInit, TOPPING_VARIANT)

---@param familiar EntityFamiliar
local function onToppingFamiliarUpdate(_, familiar)
    if familiar.SubType == TOPPING_SUBTYPES.PIZZA then
        local room = Game():GetRoom()
        local sprite = familiar:GetSprite()
        if room:GetAliveEnemiesCount() > 0 then

            if not sprite:IsPlaying("PizzaAttack") then
                sprite:Play("PizzaAttack", true)
            end

            familiar.SpriteRotation = (familiar.SpriteRotation + PIZZA_ROTATION_GAIN + math.random(-10, 10))%360
            local target = Resouled:GetEnemyTarget(familiar)
            if target then
                familiar:RemoveFromFollowers()
                if familiar.Position:Distance(target.Position) < PIZZA_COLLISION_DISTANCE_MARGIN or target:IsDead() then
                    Resouled:ClearEnemyTarget(familiar)
                else
                    familiar.Velocity = (target.Position - familiar.Position):Normalized() * PIZZA_VELOCITY_MULTIPLIER
                end
            else
                Resouled:SelectRandomEnemyTarget(familiar)
            end
        else

            if not sprite:IsPlaying("PizzaIdle") then
                sprite:Play("PizzaIdle", true)
                familiar.SpriteRotation = 0
            end

            familiar:AddToFollowers()
            familiar:FollowParent()
        end
    else
        familiar:FollowParent()
    end
end
Resouled:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, onToppingFamiliarUpdate, TOPPING_VARIANT)

---@param familiar EntityFamiliar
---@param collider Entity
local function onToppingFamiliarCollision(_, familiar, collider)
    local enemy = collider:ToNPC()
    if familiar.SubType == TOPPING_SUBTYPES.PIZZA and enemy then
        enemy:TakeDamage(PIZZA_COLLISION_DAMAGE_DPS / 30, 0, EntityRef(familiar), PIZZA_COLLISION_DAMAGE_COUNTDOWN)
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, onToppingFamiliarCollision, TOPPING_VARIANT)

HudHelper.RegisterHUDElement({
    Name = "Speed Screen",
    Priority = HudHelper.Priority.NORMAL,
    XPadding = 0,
    YPadding = 100,
    Condition = function(player, playerHUDIndex, hudLayout)
        return player:HasCollectible(CHEESE_GRATER)
    end,
    OnRender = function(player, playerHUDIndex, hudLayout, position)
        SPEED_SCREEN_SPRITE.Scale = Vector(0.35, 0.35)
        SPEED_SCREEN_SPRITE:Update()
        SPEED_SCREEN_SPRITE:Render(position + HudHelper.GetHealthHUDOffset(playerHUDIndex))
    end,
    BypassGhostBaby = true,
}, HudHelper.HUDType.EXTRA)

local SPRITE_SPEED_SCREEN_LEVEL_1_THRESHOLD = 1.25
local SPRITE_SPEED_SCREEN_LEVEL_2_THRESHOLD = 2.2

local function speedScreenUpdate()
    local player = Isaac.GetPlayer()
    if player:HasCollectible(CHEESE_GRATER) then
        SPEED_SCREEN_SPRITE:Update()

        if SPEED_SCREEN_SPRITE:IsPlaying(ANIMATION_SPEED_SCREEN_SWITCH) then
            return
        elseif SPEED_SCREEN_SPRITE:IsFinished(ANIMATION_SPEED_SCREEN_SWITCH) then
            if screenTargetAnimation then
                SPEED_SCREEN_SPRITE:Play(screenTargetAnimation, true)
                screenTargetAnimation = nil
            end
        end

        if player.MoveSpeed < SPRITE_SPEED_SCREEN_LEVEL_1_THRESHOLD then
            if not SPEED_SCREEN_SPRITE:IsPlaying(ANIMATION_SPEED_SCREEN_IDLE) then
                screenTargetAnimation = ANIMATION_SPEED_SCREEN_IDLE
            end 
        elseif player.MoveSpeed >= SPRITE_SPEED_SCREEN_LEVEL_1_THRESHOLD and player.MoveSpeed < SPRITE_SPEED_SCREEN_LEVEL_2_THRESHOLD then
            if not SPEED_SCREEN_SPRITE:IsPlaying(ANIMATION_SPEED_SCREEN_RUN1) then
                screenTargetAnimation = ANIMATION_SPEED_SCREEN_RUN1
            end
        elseif player.MoveSpeed >= SPRITE_SPEED_SCREEN_LEVEL_2_THRESHOLD then
            if not SPEED_SCREEN_SPRITE:IsPlaying(ANIMATION_SPEED_SCREEN_RUN2) then
                screenTargetAnimation = ANIMATION_SPEED_SCREEN_RUN2
            end
        end

        if screenTargetAnimation then
            SPEED_SCREEN_SPRITE:Play(ANIMATION_SPEED_SCREEN_SWITCH, true)
        end

    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_UPDATE, speedScreenUpdate)

---@param player EntityPlayer
local function playerSpeedUp(_, player)
    if player:HasCollectible(CHEESE_GRATER) then
        local itemConfig = Isaac.GetItemConfig()
        local playerItems = Resouled:GetPlayerItems(player)
        for _ = 1, #itemConfig:GetCollectibles() do
            if playerItems[_] ~= nil and _ ~= CHEESE_GRATER then
                player:RemoveCostume(itemConfig:GetCollectible(_))
                print(itemConfig:GetCollectible(_))
            end
        end
        local move = Input.IsActionPressed(ButtonAction.ACTION_LEFT, 0) or
            Input.IsActionPressed(ButtonAction.ACTION_RIGHT, 0) or
            Input.IsActionPressed(ButtonAction.ACTION_UP, 0) or
            Input.IsActionPressed(ButtonAction.ACTION_DOWN, 0)
         if move and player:GetVelocityBeforeUpdate():Length() > 0.99 then
            player:AddCacheFlags(CacheFlag.CACHE_SPEED)
            player.MoveSpeed = player.MoveSpeed + SPEED_TO_ADD_PER_FRAME * player:GetCollectibleNum(CHEESE_GRATER)
            if player.MoveSpeed >= MAX_SPEED then
                player.MoveSpeed = MAX_SPEED
            end
        else
            player.MoveSpeed = player.MoveSpeed - SPEED_TO_REMOVE_PER_FRAME
            if player.MoveSpeed <= MIN_SPEED then
                player.MoveSpeed = MIN_SPEED
            end
        end
        if player.MoveSpeed >= BOOST_EFFECT_SPEED_THRESHOLD then
           Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_DROP, 1, player.Position, Vector.Zero, player)
        end
        else
           return
    end
end

Resouled:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, playerSpeedUp)

local function drawScore()
    if Resouled:CollectiblePresent(CHEESE_GRATER) and globalScore > 0 then
        SCORE_TEXT_POSITION = Vector(Isaac.GetScreenWidth()/2, 10)
        FONT:DrawString(tostring(globalScore), SCORE_TEXT_POSITION.X, SCORE_TEXT_POSITION.Y, SCORE_TEXT_COLOR, SCORE_TEXT_BOX_WIDTH, SCORE_TEXT_CENTER)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_RENDER, drawScore)