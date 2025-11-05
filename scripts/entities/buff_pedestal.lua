local BUFF_PEDESTAL_TYPE = Isaac.GetEntityTypeByName("Buff Pedestal")
local BUFF_PEDESTAL_VARIANT = Isaac.GetEntityVariantByName("Buff Pedestal")
local BUFF_PEDESTAL_SUBTYPE = Isaac.GetEntitySubTypeByName("Buff Pedestal")

local Soul = Resouled.Stats.Soul

local SIZE_MULTI = Vector(1.2, 0.8)
local BUFF_REFRESH_COOLDOWN = 60

local font = Font()
font:Load("font/teammeatfont10.fnt")

local ANIMATION_PEDESTAL_MAIN = "Pedestal"
local ANIMATION_PEDESTAL_EMPTY = "Empty"

local PICKUP_VOLUME = 1

---@param sprite Sprite
---@param buffId ResouledBuff
local function loadProperSprite(sprite, buffId)
    local buff = Resouled:GetBuffById(buffId)
    if buff then
        local animationName = Resouled:GetBuffRarityById(buff.Rarity).Name
        if not sprite:IsOverlayPlaying(animationName) then
            sprite:ReplaceSpritesheet(0, Resouled:GetBuffFamilyById(buff.Family).Spritesheet, true)
            sprite:PlayOverlay(animationName, true)
        end
        
        if not sprite:IsPlaying(ANIMATION_PEDESTAL_MAIN) then
            sprite:Play(ANIMATION_PEDESTAL_MAIN, true)
        end
        
    end
end

---@param player EntityPlayer
---@param pedestalSprite Sprite
local function playBuffPickupAnimation(player, pedestalSprite)
    pedestalSprite:Play(ANIMATION_PEDESTAL_EMPTY, true)
    player:AnimatePickup(pedestalSprite, true)
    pedestalSprite:Play(ANIMATION_PEDESTAL_MAIN, true)
end

---@param pickup EntityPickup
local function onInit(_, pickup)
    if pickup.SubType == BUFF_PEDESTAL_SUBTYPE then
        -- leaving vardata as 0 means it will roll a random buff on 1st update
        pickup.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
        local sprite = pickup:GetSprite()
        sprite:Play("Pedestal", true)
        
        local varData = pickup:GetVarData()
        if varData > 0 then
            loadProperSprite(sprite, varData)
        end
        
        pickup:GetData().Resouled_BuffPedestalInitPosition = pickup.Position
        
        pickup.SizeMulti = SIZE_MULTI
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, onInit, BUFF_PEDESTAL_VARIANT)

---@param pickup EntityPickup
local function postPickupUpdate(_, pickup)
    if pickup.SubType == BUFF_PEDESTAL_SUBTYPE then

        local varData = pickup:GetVarData()
        local sprite = pickup:GetSprite()
        local data = pickup:GetData()
        if varData < 1 and not data.Resouled_PickedUpBuff then
            ::BuffWasPresent::
            local chosenBuff = Resouled:GetRandomWeightedBuff(pickup:GetDropRNG())
            
            if chosenBuff then
                if Resouled:ActiveBuffPresent(chosenBuff) and not Resouled:GetBuffById(chosenBuff).Stackable then
                    goto BuffWasPresent
                end
                pickup:SetVarData(chosenBuff)
            end
        end
        
        varData = pickup:GetVarData() -- in case it was refreshed in previous if block
        
        if data.Resouled_PickedUpBuff then
            if data.Resouled_PickedUpBuff > 0 then
                data.Resouled_PickedUpBuff = data.Resouled_PickedUpBuff - 1
            elseif data.Resouled_PickedUpBuff == 0 then
                data.Resouled_PickedUpBuff = nil
            end
        end
        
        if varData > 0 then
            loadProperSprite(sprite, pickup:GetVarData())
        elseif varData == 0 then -- STOP ANIMATION
            sprite:ReplaceSpritesheet(0, "gfx/buffs/placeholder.png", true)
            sprite:PlayOverlay(ANIMATION_PEDESTAL_EMPTY, true)
        end
        
        --- HOLD IT IN PLACE
        if data.Resouled_BuffPedestalInitPosition then
            pickup.Position = data.Resouled_BuffPedestalInitPosition
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, postPickupUpdate, BUFF_PEDESTAL_VARIANT)

---@param pickup EntityPickup
---@param collider Entity
local function postPickupCollision(_, pickup, collider)
    if pickup.SubType == BUFF_PEDESTAL_SUBTYPE then
        local player = collider:ToPlayer()
        local data = pickup:GetData()
        if player and not data.Resouled_PickedUpBuff and pickup:GetVarData() > 0 and Resouled:GetPossessedSoulsNum() >= Resouled:GetBuffById(pickup:GetVarData()).Price then
            local price = Resouled:GetBuffById(pickup:GetVarData()).Price
            Resouled:SetPossessedSoulsNum(Resouled:GetPossessedSoulsNum() - price)
            
            local pickupSprite = Sprite()
            pickupSprite:Load("gfx/buffs/buffs.anm2", true)
            pickupSprite:ReplaceSpritesheet(0, Resouled:GetBuffFamilyById(Resouled:GetBuffById(pickup:GetVarData()).Family).Spritesheet, true)
            pickupSprite:PlayOverlay(pickup:GetSprite():GetOverlayAnimation().."Pickup", true)
            
            playBuffPickupAnimation(player, pickupSprite)
            
            Resouled:AddPendingBuff(pickup:GetVarData())
            
            SFXManager():Play(Isaac.GetSoundIdByName("Buff"..tostring(Resouled:GetBuffById(pickup:GetVarData()).Rarity)), PICKUP_VOLUME)
            
            pickup:SetVarData(0)

            data.Resouled_PickedUpBuff = BUFF_REFRESH_COOLDOWN
            
            for i = 1, price do
                Game():Spawn(EntityType.ENTITY_PICKUP, Soul.Variant, player.Position, Vector.Zero, nil, Soul.SubTypeStatue, player.InitSeed + i)
            end
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PICKUP_COLLISION, postPickupCollision, BUFF_PEDESTAL_VARIANT)

---@param pickup EntityPickup
local function postPickupRender(_, pickup)
    if pickup.SubType == BUFF_PEDESTAL_SUBTYPE then
        local varData = pickup:GetVarData()
        if varData > 0 then
            local buff = Resouled:GetBuffById(varData)
            if buff and buff.Price > 0 then
                local renderPos = Isaac.WorldToScreen(Vector(pickup.Position.X-1, pickup.Position.Y - 15))
                font:DrawString(tostring(Resouled:GetBuffById(varData).Price), renderPos.X, renderPos.Y, KColor(1, 1, 1, 1), 1, true)
            end
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PICKUP_RENDER, postPickupRender, BUFF_PEDESTAL_VARIANT)