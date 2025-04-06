local A_FRIEND = Isaac.GetItemIdByName("A Friend")

---@param type CollectibleType
---@param player EntityPlayer
local function postAddCollectible(_, type, player)
    if type == A_FRIEND then
        Game():Spawn(EntityType.ENTITY_FAMILIAR, 228, Isaac.GetPlayer(player).Position, Vector.Zero, Isaac.GetPlayer(player), 1, Isaac.GetPlayer(player).InitSeed)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, postAddCollectible)