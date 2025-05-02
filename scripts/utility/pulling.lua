---@class PullingModule
local pullingModule = {}

local MOD = Resouled

---@param entity EntityNPC
---@param radius number
---@param visualColor? Color
---@return boolean
function pullingModule:TryEnableCustomPlayerPulling(entity, radius, visualColor)
    local data = entity:GetData()
    if not data.CustomPlayerPulling then
        local effect = Game():Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PULLING_EFFECT, entity.Position, Vector.Zero, entity, 0, 0)
        effect.Parent = entity
        effect.Color = visualColor or Color(1, 1, 1, 1)
        
        data.CustomPlayerPulling = {
            Radius = radius,
            Visual = EntityRef(effect),
        }
        return true
    end
    return false
end

---@param effect EntityEffect
MOD:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function (_, effect)
    if effect.Parent then
        local parentData = effect.Parent:GetData()
        if parentData.CustomPlayerPulling then
            effect.Position = effect.Parent.Position

            for i = 0, Game():GetNumPlayers() - 1 do
                local player = Game():GetPlayer(i)
                local distance = player.Position:Distance(effect.Position)
                if distance < parentData.CustomPlayerPulling.Radius then
                    local penaltyMult = 1 - distance / parentData.CustomPlayerPulling.Radius
                    local penaltyVec = (effect.Position - player.Position):Normalized() * penaltyMult
                    player.Velocity = player.Velocity + penaltyVec
                end
            end
        end
    end
end)

---@param entity EntityNPC
---@return boolean
function pullingModule:TryDisableCustomPlayerPulling(entity)
    local data = entity:GetData()
    if data.CustomPlayerPulling then
        data.CustomPlayerPulling.Visual.Entity:Remove()
        data.CustomPlayerPulling = nil
        return true
    end
    return false
end

return pullingModule