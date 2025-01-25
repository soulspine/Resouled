MOD = RegisterMod("Resouled", 1)

function GetMaxItemID()
    local itemConfig = Isaac.GetItemConfig()
    local maxItemId = CollectibleType.NUM_COLLECTIBLES

    while true do
        if itemConfig:GetCollectible(maxItemId) == nil then
            break
        end
        maxItemId = maxItemId + 1
    end

    return maxItemId - 1
end

function GetTotalHP(EntityPlayer)
    return EntityPlayer:GetHearts() + EntityPlayer:GetBoneHearts() + EntityPlayer:GetBlackHearts() + EntityPlayer:GetEternalHearts() + EntityPlayer:GetRottenHearts() + EntityPlayer:GetSoulHearts()
end

--import all item modules
include("custom_scripts.items")
include("custom_scripts.EID")