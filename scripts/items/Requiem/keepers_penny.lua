local KEEPERS_PENNY = Isaac.GetItemIdByName("Keeper's Penny")

local MAX_CHARGE = 12
local CHARGE_INCREMENT = 1

---@param type CollectibleType
---@param rng RNG
---@param player EntityPlayer
---@param flags UseFlag
---@param slot ActiveSlot
---@param data integer
local function onActiveUse(_, type, rng, player, flags, slot, data)
    player:AnimateCollectible(type, "UseItem", "PlayerPickupSparkle")
    local itemDesc = player:GetActiveItemDesc(slot)
    for _ = 1, itemDesc.VarData do
        Game():Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, Isaac.GetFreeNearPosition(player.Position, 0), Vector.Zero, nil, CoinSubType.COIN_PENNY, Resouled:NewSeed())
    end

    if itemDesc.VarData < MAX_CHARGE then
        itemDesc.VarData = math.min(MAX_CHARGE ,itemDesc.VarData + CHARGE_INCREMENT)
    end
end
Resouled:AddCallback(ModCallbacks.MC_USE_ITEM, onActiveUse, KEEPERS_PENNY)

---@param type CollectibleType
---@param player EntityPlayer
---@param data integer
---@param currentMaxCharge integer
local function playerGetActiveMaxCharge(_, type, player, data, currentMaxCharge)
    local slot = player:GetActiveItemSlot(type)
    if slot > -1 then
        local itemDesc = player:GetActiveItemDesc(slot)
        if itemDesc.VarData == 0 then
            itemDesc.VarData = 1
        end
        return itemDesc.VarData
    end
end
Resouled:AddCallback(ModCallbacks.MC_PLAYER_GET_ACTIVE_MAX_CHARGE, playerGetActiveMaxCharge, KEEPERS_PENNY)

local chargebarSprite = Sprite()
chargebarSprite:Load("gfx/ui/ui_chargebar.anm2", true)

local BAR_ANIMATION_EMPTY = "BarEmpty"
local BAR_ANIMATION_FULL = "BarFull"
local BAR_ANIMATION_OVERLAY = "BarOverlay1"

local BAR_DEFAULT_TOP_LEFT_CLAMP = Vector(0, 3)
local BAR_DEFAULT_BOTTOM_RIGHT_CLAMP = Vector(0, 6)

local BAR_SPRITE_ACTUAL_HEIGHT = 23

local itemSprite = Sprite()
itemSprite:Load("gfx/ui/active_item.anm2")
itemSprite:ReplaceSpritesheet(0, "gfx/items/collectibles/keepers_penny.png")
itemSprite:LoadGraphics()

local ITEM_ANIMATION_BACKDROP = "Backdrop"
local ITEM_ANIMATION_IDLE = "Idle"

local ITEM_SPRITE_WIDTH_HEIGHT = 32

---@param player EntityPlayer
---@param activeSlot ActiveSlot
---@param offset Vector
---@param alpha number
---@param scale number
---@param chargebarOffset Vector
local function preActiveRender(_, player, activeSlot, offset, alpha, scale, chargebarOffset)
    local itemDesc = player:GetActiveItemDesc(activeSlot)
    if itemDesc and itemDesc.Item == KEEPERS_PENNY then

        local maxCharge = itemDesc.VarData
        print(activeSlot, maxCharge)
        local normalCharge = player:GetActiveCharge(activeSlot)
        local batteryCharge = player:GetBatteryCharge(activeSlot)

        local normalChargeClamp = BAR_DEFAULT_TOP_LEFT_CLAMP + Vector(0, (1 - normalCharge / maxCharge) * BAR_SPRITE_ACTUAL_HEIGHT)
        local batteryChargeClamp = BAR_DEFAULT_TOP_LEFT_CLAMP + Vector(0, (1 - batteryCharge / maxCharge) * BAR_SPRITE_ACTUAL_HEIGHT)

        itemSprite.Scale = Vector(1, 1) * scale
        itemSprite.Color = Color(1, 1, 1, alpha)
        itemSprite.Offset = offset + Vector(ITEM_SPRITE_WIDTH_HEIGHT, ITEM_SPRITE_WIDTH_HEIGHT)/2 * scale -- ACCOUNT FOR OFFSET RETURNING TOP LEFT POINT OF ITEM SLOT
        
        chargebarSprite.Scale = itemSprite.Scale
        chargebarSprite.Color = itemSprite.Color
        chargebarSprite.Offset = chargebarOffset

        -- RENDERING WHITE BACKDROP WHEN ITEM IS AT LEAST AT MAXCHARGE
        if normalCharge == maxCharge then

            if not itemSprite:IsPlaying(ITEM_ANIMATION_BACKDROP) then
                itemSprite:Play(ITEM_ANIMATION_BACKDROP, true)
            end

            itemSprite:Render(Vector.Zero)
        end

        -- RENDERING ACTUAL ITEM ICON
        if not itemSprite:IsPlaying(ITEM_ANIMATION_IDLE) then
            itemSprite:Play(ITEM_ANIMATION_IDLE, true)
        end

        itemSprite:Render(Vector.Zero)

        -- RENDERING CHARGEBAR FOR PROCEDURAL MAXCHARGE TO SEPARATORS IN
        if not chargebarSprite:IsPlaying(BAR_ANIMATION_EMPTY) then
            chargebarSprite:Play(BAR_ANIMATION_EMPTY, true)
        end

        chargebarSprite:Render(Vector.Zero)

        -- RENDERING GREEN CHARGE BAR
        if normalCharge > 0 then
            if not chargebarSprite:IsPlaying(BAR_ANIMATION_FULL) then
                chargebarSprite:Play(BAR_ANIMATION_FULL, true)
            end

            chargebarSprite:Render(Vector.Zero, normalChargeClamp)

        end

        -- RENDERING BATTERY CHARGE BAR
        if batteryCharge > 0 then
            if not chargebarSprite:IsPlaying(BAR_ANIMATION_FULL) then
                chargebarSprite:Play(BAR_ANIMATION_FULL, true)
            end
            
            chargebarSprite.Color:SetOffset(255, 0 ,0)
            chargebarSprite:Render(Vector.Zero, batteryChargeClamp)
            chargebarSprite.Color:SetOffset(0, 0 ,0)
            
            if not chargebarSprite:IsPlaying(BAR_ANIMATION_OVERLAY) then
                chargebarSprite:Play(BAR_ANIMATION_OVERLAY, true)
            end

            chargebarSprite:Render(Vector.Zero)
        end

        Resouled.ProceduralMaxCharge:InvokeManually(player, activeSlot, offset, alpha, scale, chargebarOffset, maxCharge)

        return true
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_PLAYERHUD_RENDER_ACTIVE_ITEM, preActiveRender)