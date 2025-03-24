local SIBLING_RIVALRY = Isaac.GetItemIdByName("Sibling Rivalry")

---@param type CollectibleType
---@param rng RNG
---@param player EntityPlayer
---@param flags UseFlag
---@param slot ActiveSlot
---@param data integer
local function onActiveUse(_, type, rng, player, flags, slot, data)
    local data = player:GetData()
    if not player:GetOtherTwin() then
        player:AnimateCollectible(SIBLING_RIVALRY, "UseItem")
        data.SiblingRivalry = true
    else
        player:AddControlsCooldown(6)
        player:GetOtherTwin():AddControlsCooldown(6)
        player.Velocity = -(player.Position - player:GetOtherTwin().Position):Normalized() * (player.Position:Distance(player:GetOtherTwin().Position) / 13)
        player:GetOtherTwin().Velocity = -(player:GetOtherTwin().Position - player.Position):Normalized() * (player:GetOtherTwin().Position:Distance(player.Position) / 13)
        player:AnimateCollectible(SIBLING_RIVALRY, "UseItem")
        player:GetOtherTwin():AnimateCollectible(SIBLING_RIVALRY, "UseItem")
        data.SiblingRivalry = true
        player:GetOtherTwin():GetData().SiblingRivalry = true
    end
end
Resouled:AddCallback(ModCallbacks.MC_USE_ITEM, onActiveUse, SIBLING_RIVALRY)

local function onRender()
    Resouled:IterateOverPlayers(function(player)
        local data = player:GetData()
        if data.SiblingRivalrySpin then
            if not data.TORNADO then
                data.TORNADO_ANM_PATH = "gfx/spinjitzu.anm2"
                data.TORNADO = Sprite()
            end
            if not data.TORNADO:IsLoaded() then
                data.TORNADO:Load(data.TORNADO_ANM_PATH, true)
                data.TORNADO:Play("Spin", true)
            end
            data.TORNADO:Update()
            data.TORNADO:Render(Isaac.WorldToRenderPosition(player.Position))
        end
    end)
end
Resouled:AddCallback(ModCallbacks.MC_POST_RENDER, onRender)

local function onUpdate()
    ---@param player EntityPlayer
    Resouled:IterateOverPlayers(function(player)
        local data = player:GetData()
        if data.SiblingRivalry then
            player.Velocity = player.Velocity * 1.3
            if player.Position:Distance(player:GetOtherTwin().Position) < 22 then
                if not data.SiblingRivalrySpin then
                    data.SiblingRivalry = true
                end
            end
        end
        if data.SiblingRivalrySpin then
            player.Visible = false
            if data.SpinVelocity then
                player.Velocity = data.SpinVelocity
                data.SpinVelocity = data.SpinVelocity * 0.95
                if data.SpinVelocity:Length() < 0.1 then
                    data.SiblingRivalrySpin = false
                end
            end
        else
            player.Visible = true
        end
    end)
end
Resouled:AddCallback(ModCallbacks.MC_POST_UPDATE, onUpdate)

---@param npc EntityNPC
---@param collider Entity
local function onNpcCollision(_, npc, collider)
    if collider.Type == EntityType.ENTITY_PLAYER then
        if collider:ToPlayer():GetData().SiblingRivalry then
            collider.Velocity = -(collider.Velocity * 3)
            collider:ToPlayer():GetData().SiblingRivalry = false
            collider:ToPlayer():GetData().SiblingRivalrySpin = true
            collider:ToPlayer():GetData().SpinVelocity = collider.Velocity
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_NPC_COLLISION, onNpcCollision)