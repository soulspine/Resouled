---@param entity Entity
---@param damage number
local function postPlayerTakeDamage(_, entity, damage)
    if not Resouled:ActiveBuffPresent(Resouled.Buffs.GLUTTONY) then return end
    local player = entity:ToPlayer()
    if player then
        local save = Resouled.SaveManager.GetRunSave(player)
        if not save.GluttonyBuffCounter then save.GluttonyBuffCounter = 0 end
        save.GluttonyBuffCounter = save.GluttonyBuffCounter + damage
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, postPlayerTakeDamage)

local function postNewFloor()
    if not Resouled:ActiveBuffPresent(Resouled.Buffs.GLUTTONY) then return end
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
Resouled:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, postNewFloor)

Resouled:AddBuffToRemoveOnRunEnd(Resouled.Buffs.GLUTTONY, true)