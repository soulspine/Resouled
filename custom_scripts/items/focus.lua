FOCUS = Isaac.GetItemIdByName("Focus")

print("Loaded Focus")

local LEVEL_1_THRESHOLD = 4
local LEVEL_1_DAMAGE = 1
local LEVEL_2_THRESHOLD = 8
local LEVEL_2_CHARGE = 1
local LEVEL_3_THRESHOLD = 12

if EID then
    EID:addCollectible(Isaac.GetItemIdByName("Focus"), "Clearing a room spawns a {{IsaacSmall}} Minisaac.#Depending on number of Minisaacs, Isaac gains different effects:#{{ArrowUp}} " .. LEVEL_1_THRESHOLD .. "+ {{Damage}} +" .. LEVEL_1_DAMAGE .. " Damage#{{ArrowUp}} " .. LEVEL_2_THRESHOLD .. "+ All active items gain " .. LEVEL_2_CHARGE .. " charge when entering an uncleared room for the first time. Items can get overcharged by this effect.#{{ArrowUp}} " .. LEVEL_3_THRESHOLD .. "+ {{Card51}} Holy Card effect refreshing on room enter.", "Focus")
end

local miniIsaacJustDied = false
local damageGrantedThisRoom = false

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

local function onRoomClear(player, playerID)
    for _ = 1, player:GetCollectibleNum(FOCUS) do
        player:AddMinisaac(player.Position)
    end
end

local function onCacheUpdate(_, player, cacheFlag)
    local miniCount = Isaac.CountEntities(player, EntityType.ENTITY_FAMILIAR, FamiliarVariant.MINISAAC)

    if miniIsaacJustDied then
        miniIsaacJustDied = false
        miniCount = miniCount - 1
    end

    if miniCount >= LEVEL_1_THRESHOLD and not damageGrantedThisRoom then
        player.Damage = player.Damage + player:GetCollectibleNum(FOCUS) * LEVEL_1_DAMAGE
        damageGrantedThisRoom = true
    end
end

---@param player EntityPlayer
---@param playerID integer
local function onNewRoomEnter(player, playerID)
    local miniCount = Isaac.CountEntities(player, EntityType.ENTITY_FAMILIAR, FamiliarVariant.MINISAAC)
    local itemCount = player:GetCollectibleNum(FOCUS)

    damageGrantedThisRoom = false

    if miniCount >= LEVEL_2_THRESHOLD then

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
                Game():GetHUD():FlashChargeBar(player, slot)
                local batteryVfxVector = player.Position
                batteryVfxVector.Y = batteryVfxVector.Y - 80
                Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BATTERY, BatterySubType.BATTERY_MICRO, batteryVfxVector, Vector.Zero, player)
                local postCharge = player:GetActiveCharge(slot) + player:GetBatteryCharge(slot)
                local batterySfx
                if postCharge == maxCharge or postCharge == 2*maxCharge then
                    batterySfx = SoundEffect.SOUND_BATTERYCHARGE
                else
                    batterySfx = SoundEffect.SOUND_BEEP
                end
                SFXManager():Play(batterySfx, 1, 0, false, 1)
            end
            ::continue::
        end
    end
    if miniCount >= LEVEL_3_THRESHOLD then
        local effects = player:GetEffects()
        if not effects:HasNullEffect(NullItemID.ID_HOLY_CARD) then
            effects:AddNullEffect(NullItemID.ID_HOLY_CARD, true, 1)
        end
    end
end

MOD:AddCallback(ModCallbacks.MC_POST_NEW_ROOM,
    function()
        IterateOverPlayers(onNewRoomEnter)
    end
)
MOD:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, 
    function(rng, spawnPostion)
        IterateOverPlayers(onRoomClear)
    end
)
MOD:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, onCacheUpdate)

MOD:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, onMiniIsaacKill, EntityType.ENTITY_FAMILIAR)

MOD:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, 
    function()
        IterateOverPlayers(
            function(player, playerID)
                player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
                player:EvaluateItems()
            end
        )
    end
)