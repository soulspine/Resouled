local BAG_O_TRASH = Isaac.GetItemIdByName("Bag-O-Trash")

local KNIFE_VARIANT = Isaac.GetEntityVariantByName("Bag-O-Trash")

local BAG_SPRITE = Sprite()
BAG_SPRITE:Load("resources/gfx/008.004_bag of crafting.anm2", true)

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
        player:AnimateCollectible(BAG_O_TRASH, ANIMATION_PLAYER_HIDE_ITEM, ANIMATION_PICKUP_PLAYER_PICKUP)
        data.ResouledBagOfTrash = nil
    else
        player:AnimateCollectible(BAG_O_TRASH, ANIMATION_PLAYER_LIFT_ITEM, ANIMATION_PICKUP_PLAYER_PICKUP)
        data.ResouledBagOfTrash = player:GetActiveItemDesc(activeSlot).VarData
    end 
end
Resouled:AddCallback(ModCallbacks.MC_USE_ITEM, onActiveUse, BAG_O_TRASH)

---@param player EntityPlayer
local function onPlayerUpdate(_, player)
    local data = player:GetData()
    local aimDirection = player:GetAimDirection()

    if data.ResouledBagOfTrash and aimDirection:Length() > 0 then
        player:AnimateCollectible(BAG_O_TRASH, ANIMATION_PLAYER_HIDE_ITEM, ANIMATION_PICKUP_PLAYER_PICKUP)
        SFXManager():Play(SFX_SWING)
        local hitboxOffset = HITBOX_OFFSET*aimDirection
        local knife = Game():Spawn(EntityType.ENTITY_KNIFE, KNIFE_VARIANT, player.Position + hitboxOffset, Vector.Zero, player, KNIFE_VARIANT, Resouled:NewSeed()):ToKnife()
        if knife then
            knife.SizeMulti = HITBOX_SCALE
            knife.DepthOffset = player.DepthOffset - 1
            knife.Parent = player
            knife.SpriteOffset = SPRITE_OFFSET - hitboxOffset/2
            knife.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
            local swingAnimation = ANIMATIONS_BAG_SWING[math.random(#ANIMATIONS_BAG_SWING)]
            knife:GetSprite():Play(swingAnimation, true)
            knife.SpriteRotation = Vector(aimDirection.Y, -aimDirection.X):GetAngleDegrees()
            knife:GetData().ResouledBagOfTrashHitboxOffset = hitboxOffset
        end
        data.ResouledBagOfTrash = nil
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, onPlayerUpdate)

---@param knife EntityKnife
local function onKniufeUpdate(_, knife)
    if knife.Variant == KNIFE_VARIANT then
        local player = knife.Parent
        local data = player:GetData()

        knife.Position = knife.Parent.Position + knife:GetData().ResouledBagOfTrashHitboxOffset

        local capsule = knife:GetCollisionCapsule()
        for _, entity in ipairs(Isaac.FindInCapsule(capsule, EntityPartition.PICKUP)) do
            if entity:ToPickup() and PICKUP_WHITELSIT[entity.Variant] then
                local weight = UNSPECIFIED_WEIGHT
                if entity.Variant == PickupVariant.PICKUP_COIN then
                    weight = (COIN_WEIGHT[entity.SubType] == nil and 1 or COIN_WEIGHT[entity.SubType])
                end

                if weight ~= 0 then
                    data.ResouledBagOfTrash = data.ResouledBagOfTrash + weight
                    entity:Remove()
                    print("bag of trash", data.ResouledBagOfTrash)
                    player:SetActiveVarData(data.ResouledBagOfTrash, ActiveSlot.SLOT_PRIMARY)
                end
            end
        end

        if knife:GetSprite():IsFinished() then
            knife:Remove()
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_KNIFE_UPDATE, onKniufeUpdate)

---@param knife EntityKnife
---@param collider Entity
---@param low boolean
local function onKnifeCollision(_, knife, collider, low)
    if knife.Variant == KNIFE_VARIANT then
        print("knife collision", collider.Type, collider.Variant, low)
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_KNIFE_COLLISION, onKnifeCollision)