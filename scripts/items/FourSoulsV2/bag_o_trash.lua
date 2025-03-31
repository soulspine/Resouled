local BAG_O_TRASH = Isaac.GetItemIdByName("Bag-O-Trash")

local USE_CHARGE = 3

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

local ANIMATIONS_BAG_SWING = {
    "Swing",
    "Swing2",
    "SwingDown",
    "SwingDown2"
}

local UNSPECIFIED_WEIGHT = 1

local PICKUP_WHITELSIT = {
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
        }
        player:AnimateCollectible(BAG_O_TRASH, ANIMATION_PLAYER_LIFT_ITEM, ANIMATION_PICKUP_PLAYER_PICKUP)
    end 
end
Resouled:AddCallback(ModCallbacks.MC_USE_ITEM, onActiveUse, BAG_O_TRASH)

---@param player EntityPlayer
local function onPlayerUpdate(_, player)
    local data = player:GetData()
    local aimDirection = player:GetAimDirection()

    if data.ResouledBagOfTrash and not data.ResouledBagOfTrash.Swung and aimDirection:Length() > 0 then
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
            if entity:ToPickup() and not entity:IsDead() and PICKUP_WHITELSIT[entity.Variant] then
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

                if weight ~= 0 then
                    local effect = Game():Spawn(EntityType.ENTITY_EFFECT, VFX_PICKUP_VARIANT, entity.Position, Vector.Zero, nil, 0, Resouled:NewSeed())
                    effect:GetSprite().Scale = VFX_PICKUP_SCALE
                    entity:Remove()
                    local activeSlot = knifeData.ResouledBagOfTrash.ActiveSlot 
                    player:SetActiveVarData(player:GetActiveItemDesc(activeSlot).VarData + weight, activeSlot)
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
    if entity and (action == ButtonAction.ACTION_DROP) and entity.Type == EntityType.ENTITY_PLAYER and entity:GetData().ResouledBagOfTrash then
        return false -- this prevents player from changing active slot when animation is playing so it doesnt screw up counting up contents
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
        return true
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_PLAYERHUD_RENDER_ACTIVE_ITEM, onActiveItemRender)