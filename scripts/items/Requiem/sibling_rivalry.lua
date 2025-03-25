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

---@param player EntityPlayer
---@param source EntityRef
local function prePlayerTakeDmg(_, player, source)
    local data = player:GetData()
    if data.SiblingRivalrySpin then
        return false
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_PLAYER_TAKE_DMG, prePlayerTakeDmg)

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

local function onUpdate()
    ---@param player EntityPlayer
    Resouled:IterateOverPlayers(function(player)
        local data = player:GetData()
        --print(player.Velocity)
        if data.SiblingRivalry then
            if not data.SiblingRivalrySpin and player:GetOtherTwin() then
                if player.Position:Distance(player:GetOtherTwin().Position) < 55 then
                    data.SiblingRivalrySpin = true
                    player:GetOtherTwin():GetData().SiblingRivalrySpin = true
                    data.SiblingRivalry = false
                    player:GetOtherTwin():GetData().SiblingRivalry = false
                    data.SRVelocity = player.Velocity * 3
                    player:GetOtherTwin():GetData().SRVelocity = data.SRVelocity
                end
            end
        else
        end
        if data.SiblingRivalrySpin then
            player.Visible = false
            if player:GetOtherTwin() then
                player:GetOtherTwin().Visible = false
                player:GetOtherTwin().Velocity = player:GetOtherTwin():GetData().SRVelocity
                player:GetOtherTwin().EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
                player:GetOtherTwin().Position = player.Position
            end
            player.Velocity = data.SRVelocity
        else
            player.Visible = true
            if player:GetOtherTwin() then
                player:GetOtherTwin().EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
            end
        end
    end)
end
Resouled:AddCallback(ModCallbacks.MC_POST_UPDATE, onUpdate)

---@param player EntityPlayer
---@param gridIndex integer
local function onPlayerGridCollision(_, player, gridIndex)
    local data = player:GetData()
    if not data.SiblingRivalrySpin and data.SiblingRivalry then
        data.SiblingRivalrySpin = true
        data.SiblingRivalry = false
        data.SRVelocity = player.Velocity * 3
    end

    Game():Spawn(EntityType.ENTITY_EFFECT, EffectVariant.COIN_PARTICLE, Game():GetRoom():GetGridPosition(gridIndex) , Vector.Zero, nil, 0, player.InitSeed)
    local dirHelper = Game():GetRoom():GetGridPosition(gridIndex) - player.Position
    if data.SRVelocity then
        if dirHelper.X > 0 and dirHelper.Y >= -20 and dirHelper.Y <= 20 then
            data.SRVelocity.X = -data.SRVelocity.X
        elseif dirHelper.X < 0 and dirHelper.Y >= -20 and dirHelper.Y <= 20 then
            data.SRVelocity.X = -data.SRVelocity.X
        elseif dirHelper.Y > 0 and dirHelper.X >= -20 and dirHelper.X <= 20 then
            data.SRVelocity.Y = -data.SRVelocity.Y
        elseif dirHelper.Y < 0 and dirHelper.X >= -20 and dirHelper.X <= 20 then
            data.SRVelocity.Y = -data.SRVelocity.Y
        end
        Game():ShakeScreen(5)
        data.SRVelocity = data.SRVelocity:Rotated(10)
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_PLAYER_GRID_COLLISION, onPlayerGridCollision)

---@param npc EntityNPC
---@param collider Entity
local function onNpcCollision(_, npc, collider)
    if collider.Type == EntityType.ENTITY_PLAYER then
        local data = collider:GetData()
        if data.SiblingRivalry then
            data.SRVelocity = collider.Velocity * 3
            data.SiblingRivalry = false
            data.SiblingRivalrySpin = true
        end
        if data.SiblingRivalrySpin then
            local dirHelper = npc.Position - collider.Position
            if dirHelper.X > 0 then
                data.SRVelocity.X = -data.SRVelocity.X
            elseif dirHelper.X < 0 then
                data.SRVelocity.X = -data.SRVelocity.X
            elseif dirHelper.Y > 0 then
                data.SRVelocity.Y = -data.SRVelocity.Y
            elseif dirHelper.Y < 0 then
                data.SRVelocity.Y = -data.SRVelocity.Y
            end
            Game():ShakeScreen(5)
            data.SRVelocity = data.SRVelocity:Rotated(10)
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_NPC_COLLISION, onNpcCollision)