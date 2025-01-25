ISAACS_LAST_WILL = Isaac.GetItemIdByName("Isaac's last will")

print("Loaded Isaac's last will")

local function onDeath(_)
    local game = Game()
    local playerID = game:GetNumPlayers() - 1
    ::checkAnotherPlayer::
    if playerID < 0 -- no more players
    then
        return
    end
    local player = Isaac.GetPlayer(playerID)
    --print(GetTotalHP(player))
    if not player:HasCollectible(ISAACS_LAST_WILL) or not player:IsDead() or player:WillPlayerRevive()
    then
        playerID = playerID - 1
        goto checkAnotherPlayer
    end

    player:RemoveCollectible(ISAACS_LAST_WILL)
    SFXManager():Play(SoundEffect.SOUND_LAZARUS_FLIP_ALIVE, 1, 10)

    -- DO NOT ANIMATE, REMOVES ISAAC'S HEAD UPON DYING AFTER TAKING A DEVIL DEAL
    --player:AnimateSad()
    
    game:ShakeScreen(30)
    game:Darken(1, 30)

    player:Revive()
    
    local guppyCount = player:HasPlayerForm(PlayerForm.PLAYERFORM_GUPPY)
    -- add guppy transformation
    -- its very sketchy, but it works
    if not guppyCount
    then
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
        if itemCount ~= 0 then
            print("removing item: " .. itemId .. " count: " .. itemCount)
        end
        for _ = 1, itemCount do
            local currentStage = game:GetLevel():GetStage()
            local stageSeed = game:GetSeeds():GetStageSeed(currentStage)
            local rand = (stageSeed//((itemId*checkCount)+1)) % 2
            print(rand)
            if rand == 1 then --50% chance to remove item
                player:RemoveCollectible(itemId)
            end
            checkCount = checkCount + 1
        end
        ::continue::
    end
    
    if pocketId == 0 then
        player:SetPocketActiveItem(CollectibleType.COLLECTIBLE_GUPPYS_PAW, ActiveSlot.SLOT_POCKET, false)
    end
    
    player:AddMaxHearts(-player:GetMaxHearts())
    player:AddBoneHearts(-player:GetBoneHearts())
    player:AddBlackHearts(-player:GetBlackHearts())
    player:AddEternalHearts(-player:GetEternalHearts())
    player:AddGoldenHearts(-player:GetGoldenHearts())
    player:AddRottenHearts(-player:GetRottenHearts())
    
    player:AddSoulHearts(4-player:GetSoulHearts())
end
MOD:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, onDeath, EntityType.ENTITY_PLAYER)