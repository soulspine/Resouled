local GLITCH = Isaac.GetItemIdByName("Glitch")
local CHOOSE_TIME = 25

local ITEM_BLACKLIST = {
    [CollectibleType.COLLECTIBLE_R_KEY] = true,
    [CollectibleType.COLLECTIBLE_FORGET_ME_NOW] = true,
    [CollectibleType.COLLECTIBLE_WE_NEED_TO_GO_DEEPER] = true,
    [CollectibleType.COLLECTIBLE_INNER_CHILD] = true,
    [CollectibleType.COLLECTIBLE_WAVY_CAP] = true,
    [CollectibleType.COLLECTIBLE_MEGA_MUSH] = true,
    [CollectibleType.COLLECTIBLE_KEEPERS_BOX] = true,
    [CollectibleType.COLLECTIBLE_CLEAR_RUNE] = true,
    [CollectibleType.COLLECTIBLE_DEATH_CERTIFICATE] = true,
    [CollectibleType.COLLECTIBLE_SPINDOWN_DICE] = true,
    [CollectibleType.COLLECTIBLE_ESAU_JR] = true,
    [CollectibleType.COLLECTIBLE_ETERNAL_D6] = true,
    [CollectibleType.COLLECTIBLE_D_INFINITY] = true,
    [CollectibleType.COLLECTIBLE_RED_KEY] = true,
    [CollectibleType.COLLECTIBLE_FLIP] = true,
    [CollectibleType.COLLECTIBLE_BOOK_OF_SECRETS] = true,
    [CollectibleType.COLLECTIBLE_BLANK_CARD] = true,
    [CollectibleType.COLLECTIBLE_PLACEBO] = true,
    [CollectibleType.COLLECTIBLE_NECRONOMICON] = true,
}

---@param pickup EntityPickup
local function onPickupInit(_, pickup)
    local data = pickup:GetData()
    if pickup.SubType == GLITCH then
        data.IsGlitch = true
        data.GlitchItems = {}
        data.MorphCooldown = 0
        data.ChooseTime = 25
        data.CurrentItem = 1
    end
    if data.IsGlitch then
        local pool = Game():GetItemPool()
        for i = 1, 4 do
            local randomItem = pool:GetCollectible(ItemPoolType.POOL_SECRET, false)
            if not ITEM_BLACKLIST[randomItem] then
                table.insert(data.GlitchItems, randomItem)
            end
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, onPickupInit, PickupVariant.PICKUP_COLLECTIBLE)

---@param pickup EntityPickup
local function onPickupUpdate(_, pickup)
    local data = pickup:GetData()
    if data.IsGlitch then
        if data.MorphCooldown > 0 then
            data.MorphCooldown = data.MorphCooldown - 1
        end
        if data.MorphCooldown == 0 then
            pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, data.GlitchItems[data.CurrentItem], true, true, false)
            local newData = pickup:GetData()
            newData.IsGlitch = true
            newData.MorphCooldown = CHOOSE_TIME
            newData.CurrentItem = data.CurrentItem + 1
            newData.GlitchItems = data.GlitchItems
            if newData.CurrentItem > #newData.GlitchItems then
                newData.CurrentItem = 1
            end
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, onPickupUpdate, PickupVariant.PICKUP_COLLECTIBLE)

---@param pickup EntityPickup
---@param collider Entity
local function onPickupCollision(_, pickup, collider)
    local data = pickup:GetData()
    if data.IsGlitch and collider.Type == EntityType.ENTITY_PLAYER then
        collider:ToPlayer():AnimateCollectible(GLITCH)
        collider:ToPlayer():AddCollectible(GLITCH)
        SFXManager():Play(SoundEffect.SOUND_EDEN_GLITCH)
        if not collider:ToPlayer():GetData().GlitchItemEffects then
            collider:ToPlayer():GetData().GlitchItemEffects = {}
        end
        for i = 1, #data.GlitchItems do
            table.insert(collider:ToPlayer():GetData().GlitchItemEffects, data.GlitchItems[i])
        end
        collider:ToPlayer():GetData().CurrentItemEffect = 1
        pickup:Remove()
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, onPickupCollision, PickupVariant.PICKUP_COLLECTIBLE)

local function onNewRoom()
    ---@param player EntityPlayer
    Resouled:IterateOverPlayers(function(player)
        if player:HasCollectible(GLITCH) then
            local data = player:GetData()
            player:GetEffects():AddCollectibleEffect(data.GlitchItemEffects[data.CurrentItemEffect], true, 1)
            player:AddCacheFlags(CacheFlag.CACHE_ALL)
            player:EvaluateItems()
            data.CurrentItemEffect = data.CurrentItemEffect + 1
            if data.CurrentItemEffect > #data.GlitchItemEffects then
                data.CurrentItemEffect = 1
            end
        end
    end)
end
Resouled:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, onNewRoom)