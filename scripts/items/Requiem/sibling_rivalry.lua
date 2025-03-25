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
            local bodyColorTranslation = {
                [-1] = "_grey.png",
                [0] = "_grey.png",
                [1] = "_black.png",
                [2] = "_blue.png",
                [3] = "_red.png",
                [4] = "_green.png",
                [5] = "_grey.png",
                [6] = "_grey.png",
            }
            if not data.TORNADO then
                data.TORNADO_ANM_PATH = "gfx/spinjitzu.anm2"
                data.TORNADO = Sprite()
            end
            if not data.TORNADO:IsLoaded() then
                data.TORNADO:Load(data.TORNADO_ANM_PATH, true)
                data.TORNADO:ReplaceSpritesheet(0, "gfx/effects/spinjitzu" .. bodyColorTranslation[player:GetBodyColor()])
                data.TORNADO:Play("Spin", true)
            end
            data.TORNADO.Scale = Vector(0.75, 0.75) + Vector(player.Velocity:Length() / 25, player.Velocity:Length() / 25)
            data.TORNADO:Update()
            data.TORNADO:Render(Isaac.WorldToRenderPosition(player.Position))
        end
    end)
end
Resouled:AddCallback(ModCallbacks.MC_POST_RENDER, onRender)

---@param player EntityPlayer
---@param source EntityRef
local function prePlayerTakeDmg(_, player, source)
    local data = player:GetData()
    if data.SiblingRivalrySpin then
        return false
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_PLAYER_TAKE_DMG, prePlayerTakeDmg)

local function onUpdate()
    ---@param player EntityPlayer
    Resouled:IterateOverPlayers(function(player)
        local data = player:GetData()
        if data.SiblingRivalry then
            player.Velocity = player.Velocity * 1.15
            if player:GetOtherTwin() then
                if player.Position:Distance(player:GetOtherTwin().Position) < 55 then
                    if not data.SiblingRivalrySpin then
                        data.SiblingRivalrySpin = true
                        data.SiblingRivalry = false
                    end
                end
            end
        end
        if data.SiblingRivalrySpin then
            player.Visible = false
            player.Friction = 1.2
            player.Velocity = player.Velocity * 1.05
            if data.SpinVelocity then
                player.Velocity = data.SpinVelocity
                data.SpinVelocity = data.SpinVelocity * 0.95
                if data.SpinVelocity:Length() < 0.1 then
                    data.SiblingRivalrySpin = false
                end
            end
        else
            player.Visible = true
            player.Friction = 1
        end
    end)
end
Resouled:AddCallback(ModCallbacks.MC_POST_UPDATE, onUpdate)

---@param player EntityPlayer
---@param collider Entity
local function onPlayerCollision(_, player, collider)
    local data = player:GetData()
    local cData = collider:GetData()
    if player and collider.Type == EntityType.ENTITY_PLAYER then
        if data.SiblingRivalrySpin then
            player.Velocity = -(player.Velocity * 0.7)
        end
        if cData.SiblingRivalrySpin then
            collider.Velocity = -(collider.Velocity * 0.7)
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_PLAYER_COLLISION, onPlayerCollision)

local function onNewRoom()
    Resouled:IterateOverPlayers(function(player)
        player:GetData().SiblingRivalrySpin = false
        player:GetData().SiblingRivalry = false
    end)
end
Resouled:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, onNewRoom)

---@param player EntityPlayer
---@param gridIndex integer
local function onPlayerGridCollision(_, player, gridIndex)
    local data = player:GetData()
    if data.SiblingRivalry then
        data.SiblingRivalry = false
        data.SiblingRivalrySpin = true
    end
    if data.SiblingRivalrySpin then
        player:AddControlsCooldown(1)
        player.Velocity = -(player.Velocity * 0.7)
    end
end
Resouled:AddCallback(ModCallbacks.MC_PLAYER_GRID_COLLISION, onPlayerGridCollision)

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