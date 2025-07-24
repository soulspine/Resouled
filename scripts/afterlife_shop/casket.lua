local Casket = Resouled.Stats.Casket

---@param pickup EntityPickup
local function onPickupInit(_, pickup)
    if pickup.SubType == Casket.SubType then
        pickup:GetSprite():Play("Idle", true)
        pickup.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
        pickup.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, onPickupInit, Casket.Variant)

---@param pickup EntityPickup
---@param collider EntityPlayer
local function onPickupCollision(_, pickup, collider)
    if pickup.SubType == Casket.SubType then
        local player = collider:ToPlayer()
        if player then
            ---@param player2 EntityPlayer
            Resouled.Iterators:IterateOverPlayers(function(player2)
                player2:AnimateTrapdoor()
                player2:AddControlsCooldown(10000000)
                player2:GetData().Resouled_CasketTargetPos = pickup.Position
                player2.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
                player2.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
            end)
            pickup.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PICKUP_COLLISION, onPickupCollision, Casket.Variant)

---@param player EntityPlayer
local function onPlayerUpdate(_, player)
    local data = player:GetData()
    if data.Resouled_CasketTargetPos then
        player.Velocity = (player.Velocity + (data.Resouled_CasketTargetPos - player.Position)/10) * Casket.Speed

        if player.Position:Distance(data.Resouled_CasketTargetPos) < 3 then
            player.Velocity = Vector.Zero
            data.Resouled_CasketTargetPos = nil
        end
    end


    if Resouled.AfterlifeShop:IsAfterlifeShop() then
        local sprite = player:GetSprite()
        
        if sprite:IsPlaying(Casket.AnimIn) then
            Game():FinishChallenge()
            
            if sprite:IsEventTriggered("Poof") then
                player:SetColor(Color(0, 0, 0, 0), 1000000, 10000000000, false, false)
            end
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, onPlayerUpdate)