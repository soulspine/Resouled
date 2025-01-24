ISAACS_LAST_WILL = Isaac.GetItemIdByName("Isaac's last will")

print("Loaded Isaac's last will")

local function onDeath(_)
    local player = Isaac.GetPlayer()
    if not Isaac.GetPlayer():HasCollectible(ISAACS_LAST_WILL) or player:WillPlayerRevive()
    then
        return
    end

    player:RemoveCollectible(ISAACS_LAST_WILL)
    player:AnimatePitfallOut()
    SFXManager():Play(SoundEffect.SOUND_LAZARUS_FLIP_ALIVE, 1, 10)
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

    for _, itemId in pairs(CollectibleType) do
        local itemCount = player:GetCollectibleNum(itemId)
        for _ = 1, itemCount do
            local rand = math.random(1, 2)
            if rand ~= 1 then 
                player:RemoveCollectible(itemId)
            end
        end
    end
    
    player:SetPocketActiveItem(CollectibleType.COLLECTIBLE_GUPPYS_PAW, ActiveSlot.SLOT_POCKET, false)

    --player:AddSoulHearts(1)
    player:AddMaxHearts(-player:GetMaxHearts())
    player:AddBoneHearts(-player:GetBoneHearts())
    player:AddBlackHearts(-player:GetBlackHearts())
    player:AddEternalHearts(-player:GetEternalHearts())
    player:AddGoldenHearts(-player:GetGoldenHearts())
    player:AddRottenHearts(-player:GetRottenHearts())

    player:AddSoulHearts(4-player:GetSoulHearts())
end
MOD:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, onDeath, EntityType.ENTITY_PLAYER)