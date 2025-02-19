local FOCUS = Isaac.GetItemIdByName("Focus")

local LEVEL_1_THRESHOLD = 3
local LEVEL_1_DAMAGE = 1
local LEVEL_2_THRESHOLD = 6
local LEVEL_2_CHARGE = 1
local LEVEL_3_THRESHOLD = 9

if EID then
    EID:addCollectible(FOCUS, "Clearing a room spawns a {{IsaacSmall}} Minisaac.#Depending on number of Minisaacs, Isaac gains different effects:#{{ArrowUp}} " .. LEVEL_1_THRESHOLD .. "+ {{Damage}} +" .. LEVEL_1_DAMAGE .. " Damage#{{ArrowUp}} " .. LEVEL_2_THRESHOLD .. "+ All active items gain " .. LEVEL_2_CHARGE .. " charge when entering an uncleared room for the first time. Items can get overcharged by this effect.#{{ArrowUp}} " .. LEVEL_3_THRESHOLD .. "+ {{Collectible313}} Holy Mantle effect.", "Focus")
end

---@param player EntityPlayer
local function countMiniIsaacs(player)
    return Isaac.CountEntities(player, EntityType.ENTITY_FAMILIAR, FamiliarVariant.MINISAAC)
end

local miniIsaacCount = 0
local miniIsaacJustDied = false
local miniIsaacJustSpawned = false

---@param entityType EntityType
---@param variant integer
---@param subtype integer
---@param position Vector
---@param velocity Vector
---@param spawner Entity
---@param seed integer
local function onEntitySpawn(_, entityType, variant, subtype, position, velocity, spawner, seed)
    if entityType == EntityType.ENTITY_FAMILIAR and variant == FamiliarVariant.MINISAAC then
        
        local player = spawner:ToPlayer()

        if player == nil then
            --print("Player is nil in onEntitySpawn")
            return
        end

        -- cannot update just the spawner
        -- it says AddCacheFlags is null for this object ?????

        Resouled:IterateOverPlayers(function(player, _)
            if player:HasCollectible(FOCUS) then
                miniIsaacJustSpawned = true
                player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
                player:EvaluateItems()
            end
        end)
    end
end

---@param entity Entity
local function onMiniIsaacKill(_, entity)
    local familiar = entity:ToFamiliar()

    if familiar == nil then
        return
    end

    if familiar.Variant == FamiliarVariant.MINISAAC then
        miniIsaacJustDied = true
        familiar.Player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
        familiar.Player:EvaluateItems()
    end
end

---@param player EntityPlayer
local function onRoomClear(player, _)
    for _ = 1, player:GetCollectibleNum(FOCUS) do
        player:AddMinisaac(player.Position)
    end
end

---@param player EntityPlayer
---@param cacheFlag CacheFlag
local function onCacheUpdate(_, player, cacheFlag)
    if cacheFlag & CacheFlag.CACHE_DAMAGE == CacheFlag.CACHE_DAMAGE then
        if player:HasCollectible(FOCUS) then
            miniIsaacCount = countMiniIsaacs(player) + (miniIsaacJustSpawned and 1 or 0) - (miniIsaacJustDied and 1 or 0)
            miniIsaacJustSpawned, miniIsaacJustDied = false, false

            if miniIsaacCount >= LEVEL_1_THRESHOLD then
                player.Damage = player.Damage + player:GetCollectibleNum(FOCUS) * LEVEL_1_DAMAGE
            end
        end
    end
end

---@param player EntityPlayer
---@param playerID integer
local function onNewRoomEnter(player, playerID)
    local itemCount = player:GetCollectibleNum(FOCUS)

    miniIsaacCount = countMiniIsaacs(player)
    if miniIsaacCount >= LEVEL_2_THRESHOLD then

        for _, slot in pairs(ActiveSlot) do
            local activeItemID = player:GetActiveItem(slot)

            if activeItemID == CollectibleType.COLLECTIBLE_NULL then
                goto continue
            end

            local itemConfig = Isaac.GetItemConfig()
            local itemData = itemConfig:GetCollectible(activeItemID)
            local maxCharge = itemData.MaxCharges

            local preCharge = player:GetActiveCharge(slot) + player:GetBatteryCharge(slot)
            local room = Game():GetRoom()
            if room:IsFirstVisit() and not room:IsClear() then
                player:SetActiveCharge(preCharge + itemCount * LEVEL_2_CHARGE, slot)
                
                local postCharge = player:GetActiveCharge(slot) + player:GetBatteryCharge(slot)
                if postCharge == preCharge then
                    goto continue
                end

                Game():GetHUD():FlashChargeBar(player, slot)
                local batteryVfxVector = player.Position
                batteryVfxVector.Y = batteryVfxVector.Y - 80
                Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BATTERY, BatterySubType.BATTERY_MICRO, batteryVfxVector, Vector.Zero, player)
                local batterySfx
                if postCharge % maxCharge == 0 then
                    batterySfx = SoundEffect.SOUND_BATTERYCHARGE
                else
                    batterySfx = SoundEffect.SOUND_BEEP
                end
                SFXManager():Play(batterySfx, 1, 0, false, 1)
            end
            ::continue::
        end
    end
    if miniIsaacCount >= LEVEL_3_THRESHOLD then
        local effects = player:GetEffects()
        if not effects:HasCollectibleEffect(CollectibleType.COLLECTIBLE_HOLY_MANTLE) then
            effects:AddCollectibleEffect(CollectibleType.COLLECTIBLE_HOLY_MANTLE, true, 1)
        end
    end
end

Resouled:AddCallback(ModCallbacks.MC_POST_NEW_ROOM,
    function()
        Resouled:IterateOverPlayers(onNewRoomEnter)
    end
)
Resouled:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, 
    function()
        Resouled:IterateOverPlayers(onRoomClear)
    end
)
Resouled:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, onCacheUpdate)

Resouled:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, onMiniIsaacKill, EntityType.ENTITY_FAMILIAR)

Resouled:AddCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, onEntitySpawn)