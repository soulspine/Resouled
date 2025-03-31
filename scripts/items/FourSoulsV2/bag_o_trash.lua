local BAG_O_TRASH = Isaac.GetItemIdByName("Bag-O-Trash")

local USE_CHARGE = 3

local ACTIVATE_HOLD_DURATION = 90

local KNIFE_VARIANT =  KnifeVariant.BAG_OF_CRAFTING

local BAG_ENTITY_SPRITESHEET = "gfx/effects/bag_o_trash_knife.png"
local BAG_ENTITY_SPRITE_PLAYBACK_SPEED = 0.5

local BAG_ITEM_SPRITE = Sprite()
BAG_ITEM_SPRITE:Load("gfx/items/bag_o_trash.anm2", true)
local BAG_ITEM_SPRITE_DEFAULT_ANIMATION = "Idle"
local BAG_ITEM_SPRITE_EMPTY_FRAME = 1
local BAG_ITEM_SPRITE_FULL_FRAME = 0
local BAG_ITEM_SPRITE_WIDTH_HEIGHT = 32

local VFX_PICKUP_VARIANT = EffectVariant.POOF01
local VFX_PICKUP_SCALE = Vector(0.5, 0.5)

local SFX_SWING = SoundEffect.SOUND_BIRD_FLAP

local HITBOX_OFFSET = 36
local HITBOX_SCALE = Vector(1.9, 1.9)
local SPRITE_OFFSET = Vector(0, -10)

local ANIMATION_PLAYER_LIFT_ITEM = "LiftItem"
local ANIMATION_PLAYER_HIDE_ITEM = "HideItem"

local ANIMATION_PICKUP_PLAYER_PICKUP = "PlayerPickup"

local CHARGEBAR_SPRITE_HEIGHT = 16
local ANIMATION_CHARGEBAR_EMPTY = "BarEmpty"
local ANIMATION_CHARGEBAR_FULL = "BarFull"
local INPUT_IGNORE_DURATION = 4

local ANIMATIONS_BAG_SWING = {
    "Swing",
    "Swing2",
    "SwingDown",
    "SwingDown2"
}

local UNSPECIFIED_WEIGHT = 1

local SPAWN_PICKUPS = {
    {PickupVariant.PICKUP_COIN, CoinSubType.COIN_LUCKYPENNY},
    {PickupVariant.PICKUP_COIN, CoinSubType.COIN_STICKYNICKEL},
    {PickupVariant.PICKUP_COIN, CoinSubType.COIN_DOUBLEPACK},
    {PickupVariant.PICKUP_KEY, KeySubType.KEY_CHARGED},
    {PickupVariant.PICKUP_KEY, KeySubType.KEY_DOUBLEPACK},
    {PickupVariant.PICKUP_BOMB, BombSubType.BOMB_DOUBLEPACK},
    {PickupVariant.PICKUP_BOMB, BombSubType.BOMB_GOLDENTROLL},
    {PickupVariant.PICKUP_LIL_BATTERY, BatterySubType.BATTERY_NORMAL},
    {PickupVariant.PICKUP_LIL_BATTERY, BatterySubType.BATTERY_GOLDEN},
    {PickupVariant.PICKUP_HEART, HeartSubType.HEART_DOUBLEPACK},
    {PickupVariant.PICKUP_HEART, HeartSubType.HEART_ROTTEN},
    {PickupVariant.PICKUP_HEART, HeartSubType.HEART_BONE},
    {PickupVariant.PICKUP_HEART, HeartSubType.HEART_ETERNAL},
}

local COLLECT_PICKUP_WHITELSIT = {
    [PickupVariant.PICKUP_BOMB] = true,
    [PickupVariant.PICKUP_COIN] = true,
    [PickupVariant.PICKUP_TAROTCARD] = true,
    [PickupVariant.PICKUP_KEY] = true,
    [PickupVariant.PICKUP_PILL] = true,
    [PickupVariant.PICKUP_HEART] = true,
    [PickupVariant.PICKUP_LIL_BATTERY] = true,
    [PickupVariant.PICKUP_POOP] = true,
}

local COIN_WEIGHT = {
    [CoinSubType.COIN_STICKYNICKEL] = 0,
    [CoinSubType.COIN_DOUBLEPACK] = 2,
    [Isaac.GetEntitySubTypeByName("Triple Coin")] = 3,
    [Isaac.GetEntitySubTypeByName("Quad Coin")] = 4,
}

local BOMB_WEIGHT = {
    [BombSubType.BOMB_DOUBLEPACK] = 2,
    [BombSubType.BOMB_GIGA] = 0,
}

local KEY_WEIGHT = {
    [KeySubType.KEY_DOUBLEPACK] = 2,
}

local HEART_WEIGHT = {
    [HeartSubType.HEART_DOUBLEPACK] = 2,
}

---@param itemId CollectibleType
---@param rng RNG
---@param player EntityPlayer
---@param useFlags UseFlag
---@param activeSlot ActiveSlot
---@param customVarData integer
local function onActiveUse(_, itemId, rng, player, useFlags, activeSlot, customVarData)
    if useFlags & UseFlag.USE_CUSTOMVARDATA == 0 then
        player:UseActiveItem(itemId, useFlags | UseFlag.USE_CUSTOMVARDATA, activeSlot)
        return
    end

    local sprite = player:GetSprite()
    local data = player:GetData()
    if sprite:GetOverlayAnimation() == "" then
        data.ResouledBagOfTrash = nil
        player:AnimateCollectible(BAG_O_TRASH, ANIMATION_PLAYER_HIDE_ITEM, ANIMATION_PICKUP_PLAYER_PICKUP)
    else
        data.ResouledBagOfTrash = {
            ActiveSlot = activeSlot,
            Swung = false,
            SpacebarHoldDuration = 0,
            InputIgnore = 0,
        }
        player:AnimateCollectible(BAG_O_TRASH, ANIMATION_PLAYER_LIFT_ITEM, ANIMATION_PICKUP_PLAYER_PICKUP)
    end 
end
Resouled:AddCallback(ModCallbacks.MC_USE_ITEM, onActiveUse, BAG_O_TRASH)

---@param player EntityPlayer
local function onPlayerUpdate(_, player)
    local data = player:GetData()
    
    if data.ResouledBagOfTrash then
        local aimDirection = player:GetAimDirection()
        local activeSlot = data.ResouledBagOfTrash.ActiveSlot
        local itemDesc = player:GetActiveItemDesc(activeSlot)
        local game = Game()
        local room = game:GetRoom()
    
        if itemDesc.Item ~= BAG_O_TRASH then
            data.ResouledBagOfTrash = nil
            player:AnimateCollectible(BAG_O_TRASH, ANIMATION_PLAYER_HIDE_ITEM, ANIMATION_PICKUP_PLAYER_PICKUP)
            return
        end

        if not data.ResouledBagOfTrash.Swung and aimDirection:Length() > 0 then -- handling swings
            data.ResouledBagOfTrash.Swung = true
            player:AnimateCollectible(BAG_O_TRASH, ANIMATION_PLAYER_HIDE_ITEM, ANIMATION_PICKUP_PLAYER_PICKUP)
            SFXManager():Play(SFX_SWING)
            local hitboxOffset = HITBOX_OFFSET*aimDirection
            local knife = Game():Spawn(EntityType.ENTITY_KNIFE, KNIFE_VARIANT, player.Position + hitboxOffset, Vector.Zero, player, 0, Resouled:NewSeed()):ToKnife()
            if knife then
                knife.SizeMulti = HITBOX_SCALE
                knife.DepthOffset = player.DepthOffset - 1
                knife.Parent = player
                knife.SpriteOffset = SPRITE_OFFSET - hitboxOffset/2
                knife.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
                local swingAnimation = ANIMATIONS_BAG_SWING[math.random(#ANIMATIONS_BAG_SWING)]
                local sprite = knife:GetSprite()
                sprite:ReplaceSpritesheet(0, BAG_ENTITY_SPRITESHEET, true)
                sprite:Play(swingAnimation, true)
                sprite:GetLayer(1):SetVisible(true)
                sprite.PlaybackSpeed = BAG_ENTITY_SPRITE_PLAYBACK_SPEED
                knife.SpriteRotation = Vector(aimDirection.Y, -aimDirection.X):GetAngleDegrees() -- no idea what logic was behind that, this variation just worked
                knife:GetData().ResouledBagOfTrash = {
                    HitboxOffset = hitboxOffset,
                    ActiveSlot = data.ResouledBagOfTrash.ActiveSlot,
                }
            end
        end



        if data.ResouledBagOfTrash.SpacebarHoldDuration == ACTIVATE_HOLD_DURATION and itemDesc.VarData >= USE_CHARGE then -- handling spawning
            player:AnimateCollectible(BAG_O_TRASH, ANIMATION_PLAYER_HIDE_ITEM, ANIMATION_PICKUP_PLAYER_PICKUP)
            itemDesc.VarData = itemDesc.VarData - USE_CHARGE
            local rng = player:GetCollectibleRNG(BAG_O_TRASH)
            local effectNum = rng:RandomInt(3)

            print("EffectNum: " .. effectNum)

            if effectNum == 0 then -- spawn 6 flies
                player:AddBlueFlies(6, player.Position, nil)
            elseif effectNum == 1 then -- spawn a trinket
                game:Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, room:FindFreePickupSpawnPosition(player.Position), Vector.Zero, player, 0, Resouled:NewSeed())
            elseif effectNum == 2 then
                local targetPickup = SPAWN_PICKUPS[rng:RandomInt(#SPAWN_PICKUPS) + 1]
                game:Spawn(EntityType.ENTITY_PICKUP, targetPickup[1], room:FindFreePickupSpawnPosition(player.Position), Vector.Zero, player, targetPickup[2], Resouled:NewSeed())
            end

            data.ResouledBagOfTrash = nil
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, onPlayerUpdate)

---@param knife EntityKnife
local function onKnifeUpdate(_, knife)
    local knifeData = knife:GetData()
    if knifeData.ResouledBagOfTrash then
        local player = knife.Parent:ToPlayer()

        if not player then
            knife:Remove()
            return
        end

        knife.Position = knife.Parent.Position + knifeData.ResouledBagOfTrash.HitboxOffset

        local capsule = knife:GetCollisionCapsule()
        for _, entity in ipairs(Isaac.FindInCapsule(capsule, EntityPartition.PICKUP)) do
            local pickup = entity:ToPickup()
            if pickup and not entity:IsDead() and COLLECT_PICKUP_WHITELSIT[entity.Variant] then

                local price = pickup.Price

                local weight = UNSPECIFIED_WEIGHT
                if entity.Variant == PickupVariant.PICKUP_COIN then
                    weight = (COIN_WEIGHT[entity.SubType] == nil and 1 or COIN_WEIGHT[entity.SubType])
                end

                if entity.Variant == PickupVariant.PICKUP_BOMB then
                    weight = (BOMB_WEIGHT[entity.SubType] == nil and 1 or BOMB_WEIGHT[entity.SubType])
                end

                if entity.Variant == PickupVariant.PICKUP_KEY then
                    weight = (KEY_WEIGHT[entity.SubType] == nil and 1 or KEY_WEIGHT[entity.SubType])
                end

                if entity.Variant == PickupVariant.PICKUP_HEART then
                    weight = (HEART_WEIGHT[entity.SubType] == nil and 1 or HEART_WEIGHT[entity.SubType])
                end

                if weight ~= 0 and player:GetNumCoins() >= price and price >= 0 then
                    local effect = Game():Spawn(EntityType.ENTITY_EFFECT, VFX_PICKUP_VARIANT, entity.Position, Vector.Zero, nil, 0, Resouled:NewSeed())
                    effect:GetSprite().Scale = VFX_PICKUP_SCALE
                    entity:Remove()
                    local activeSlot = knifeData.ResouledBagOfTrash.ActiveSlot 
                    player:SetActiveVarData(player:GetActiveItemDesc(activeSlot).VarData + weight, activeSlot)
                    player:AddCoins(-price)
                end
            end
        end

        if knife:GetSprite():IsFinished() then
            local playerData = player:GetData()
            if playerData.ResouledBagOfTrash and playerData.ResouledBagOfTrash.Swung then
                playerData.ResouledBagOfTrash = nil
            end
            knife:Remove()
        end
        return true
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_KNIFE_UPDATE, onKnifeUpdate)

---@param entity Entity
---@param inputHook InputHook
---@param action ButtonAction
local function onActionTriggered(_, entity, inputHook, action)

    if not entity then return end   

    local data = entity:GetData()
    if entity.Type == EntityType.ENTITY_PLAYER and data.ResouledBagOfTrash and inputHook == InputHook.IS_ACTION_TRIGGERED then
        local actionPressed = Input.IsActionPressed(action, entity:ToPlayer().ControllerIndex)

        if data.ResouledBagOfTrash.InputIgnore > 0 and not actionPressed then
            data.ResouledBagOfTrash.InputIgnore = data.ResouledBagOfTrash.InputIgnore - 1
        else
            data.ResouledBagOfTrash.InputIgnore = INPUT_IGNORE_DURATION
            data.ResouledBagOfTrash.SpacebarHoldDuration = (action == ButtonAction.ACTION_ITEM and actionPressed) and math.min(data.ResouledBagOfTrash.SpacebarHoldDuration + 1, ACTIVATE_HOLD_DURATION) or 0
        end

        if action == ButtonAction.ACTION_DROP then
            return false -- this prevents player from changing active slot when animation is playing so it doesnt screw up counting up contents
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_INPUT_ACTION, onActionTriggered)

---@param player EntityPlayer
---@param activeSlot ActiveSlot
---@param offset Vector
---@param alpha number
---@param scale number
---@param chargebarOffset Vector
local function onActiveItemRender(_, player, activeSlot, offset, alpha, scale, chargebarOffset)
    local itemDesc = player:GetActiveItemDesc(activeSlot)
    if itemDesc.Item == BAG_O_TRASH then

        if not BAG_ITEM_SPRITE:IsPlaying() then
            BAG_ITEM_SPRITE:Play(BAG_ITEM_SPRITE_DEFAULT_ANIMATION, true)
        end

        local frame = BAG_ITEM_SPRITE:GetFrame()
        if itemDesc.VarData >= USE_CHARGE and frame ~= BAG_ITEM_SPRITE_FULL_FRAME then
            BAG_ITEM_SPRITE:SetFrame(BAG_ITEM_SPRITE_DEFAULT_ANIMATION, BAG_ITEM_SPRITE_FULL_FRAME)
        elseif itemDesc.VarData < USE_CHARGE and frame ~= BAG_ITEM_SPRITE_EMPTY_FRAME then
            BAG_ITEM_SPRITE:SetFrame(BAG_ITEM_SPRITE_DEFAULT_ANIMATION, BAG_ITEM_SPRITE_EMPTY_FRAME)
        end
        BAG_ITEM_SPRITE.Offset = offset + scale*Vector(BAG_ITEM_SPRITE_WIDTH_HEIGHT,BAG_ITEM_SPRITE_WIDTH_HEIGHT)/2
        BAG_ITEM_SPRITE.Color = Color(1, 1, 1, alpha)
        BAG_ITEM_SPRITE.Scale = Vector(scale, scale)
        BAG_ITEM_SPRITE:Render(Vector.Zero)
        local text = tostring(itemDesc.VarData)
        local textWidth = Isaac.GetTextWidth(text)
        local textPosition = BAG_ITEM_SPRITE.Offset - Vector(textWidth/2, 0)
        Isaac.RenderScaledText(text, textPosition.X, textPosition.Y, scale, scale, 1, 1, 1, alpha)

        local playerData = player:GetData()
        if (activeSlot == ActiveSlot.SLOT_PRIMARY or activeSlot == ActiveSlot.SLOT_POCKET) and playerData.ResouledBagOfTrash and playerData.ResouledBagOfTrash.SpacebarHoldDuration > 0 and itemDesc.VarData >= USE_CHARGE then
            local chargeBarSprite = Game():GetHUD():GetChargeBarSprite()
            chargeBarSprite:Play(ANIMATION_CHARGEBAR_FULL, true)
            chargeBarSprite.Scale = Vector(scale, scale)
            local percentageHeld = playerData.ResouledBagOfTrash.SpacebarHoldDuration / ACTIVATE_HOLD_DURATION
            chargeBarSprite:Render(chargebarOffset, Vector(0, (1-percentageHeld)*CHARGEBAR_SPRITE_HEIGHT)*2)
        end
        return true
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_PLAYERHUD_RENDER_ACTIVE_ITEM, onActiveItemRender)