ISAACS_LAST_WILL = Isaac.GetItemIdByName("Isaac's last will")

print("Loaded Isaac's last will")

local game = Game()
local sfx = SFXManager()
local revivedPlayers = {}

local function onRoomEnter()
    revivedPlayers = {}
end

local function onOtherEntityDeath(player, playerID)
    --print("Other entity death")
    if not revivedPlayers[playerID]
    then
        return
    end
    --print("EntityType: " .. entity.Type)
    local preSoulHearts = player:GetSoulHearts()
    local preSoulCharge = player:GetEffectiveSoulCharge()
    player:AddSoulHearts(1)
    local postSoulHearts = player:GetSoulHearts()
    local postSoulCharge = player:GetEffectiveSoulCharge()
    if preSoulHearts < postSoulHearts or preSoulCharge < postSoulCharge
    then
        sfx:Play(SoundEffect.SOUND_HOLY, 0.7, 10)
    end
end

local function onPlayerDeath(player, playerID)
    if not player:HasCollectible(ISAACS_LAST_WILL) or not player:IsDead() or player:WillPlayerRevive()
    then
        return
    end

    player:RemoveCollectible(ISAACS_LAST_WILL)
    sfx:Play(SoundEffect.SOUND_LAZARUS_FLIP_ALIVE, 1, 10)

    -- DO NOT ANIMATE, REMOVES ISAAC'S HEAD UPON DYING AFTER TAKING A DEVIL DEAL
    --player:AnimateSad()
    
    game:ShakeScreen(30)
    game:Darken(1, 30)

    player:GetEffects():AddNullEffect(NullItemID.ID_LAZARUS_SOUL_REVIVE, false, 1)
    revivedPlayers[playerID] = true
    
    -- add guppy transformation
    -- its very sketchy, but it works
    if not player:HasPlayerForm(PlayerForm.PLAYERFORM_GUPPY)
    then
        --print("Adding Guppy transformation")
        local trinket1 = player:GetTrinket(0)
        local trinket2 = player:GetTrinket(1)
        for _ = 1, 4 do
            player:AddTrinket(TrinketType.TRINKET_KIDS_DRAWING, true)
        end
        
        player:TryRemoveTrinket(TrinketType.TRINKET_KIDS_DRAWING)
        
        if trinket1 ~= 0 then
            player:AddTrinket(trinket1, false)
        end
        
        if trinket2 == 0 then
            player:TryRemoveTrinket(trinket1)
        else
            player:AddTrinket(trinket2, false)
        end
    end

    local pocketId = player:GetActiveItem(ActiveSlot.SLOT_POCKET)

    local maxItemId = GetMaxItemID()

    local checkCount = 1;
    for itemId = 1, maxItemId do
        if itemId == pocketId then --skip removing pocket for tainted
            goto continue
        end
        local itemCount = player:GetCollectibleNum(itemId)
        for _ = 1, itemCount do
            local currentStage = game:GetLevel():GetStage()
            local stageSeed = game:GetSeeds():GetStageSeed(currentStage)
            local rand = (stageSeed//((itemId*checkCount)+1)) % 2
            --print(rand)
            if rand == 1 then -- 50% chance to remove item
                player:RemoveCollectible(itemId)
            end
            checkCount = checkCount + 1
        end
        ::continue::
    end
    
    if pocketId == 0 then
        player:SetPocketActiveItem(CollectibleType.COLLECTIBLE_GUPPYS_PAW, ActiveSlot.SLOT_POCKET, false)
    end
end

MOD:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL,
    function(_, entity)
        if entity.Type == EntityType.ENTITY_PLAYER
        then
            IterateOverPlayers(onPlayerDeath)
        else
            IterateOverPlayers(onOtherEntityDeath)
        end
    end
)
--MOD:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL)
MOD:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, onRoomEnter)