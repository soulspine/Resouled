---@param entity Entity
---@param damage number
local function postPlayerTakeDamage(_, entity, damage)
    local player = entity:ToPlayer()
    if player then
        local save = Resouled.SaveManager.GetRunSave(player)
        if not save.GluttonyBuffCounter then save.GluttonyBuffCounter = 0 end
        save.GluttonyBuffCounter = save.GluttonyBuffCounter + damage
    end
end

local function postNewFloor()
    ---@param player EntityPlayer
    Resouled.Iterators:IterateOverPlayers(function(player)
        local save = Resouled.SaveManager.GetRunSave(player)
        if save.GluttonyBuffCounter then
            local healthType = player:GetHealthType()

            local amount = math.ceil(save.GluttonyBuffCounter/4)

            if healthType == HealthType.RED then
                
                player:AddHearts(amount)

            elseif healthType == HealthType.SOUL then
                
                player:AddSoulHearts(amount)

            elseif healthType == HealthType.COIN then
                
                player:AddCoins(amount)

            elseif healthType == HealthType.BONE then
                
                player:AddBoneHearts(amount)

            end

            save.GluttonyBuffCounter = 0
        end
    end)
end

Resouled:AddBuffToRemoveOnRunEnd(Resouled.Buffs.GLUTTONY, true)

Resouled:AddBuffCallbackConfig(Resouled.Buffs.GLUTTONY, {
    {
        CallbackID = ModCallbacks.MC_POST_ENTITY_TAKE_DMG,
        Function = postPlayerTakeDamage
    },
    {
        CallbackID = ModCallbacks.MC_POST_NEW_LEVEL,
        Function = postNewFloor
    }
})