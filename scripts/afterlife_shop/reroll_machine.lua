local buffPedestalConfig = Resouled.Stats.BuffPedestal

local restockMachineConfig = Resouled.Stats.RerollMachine

local COLLISION_RADIUS = 25

---@param eff EntityEffect
local function onEffectInit(_, eff)
    if eff.SubType == restockMachineConfig.SubType then
        eff:GetSprite():Play("Idle", true)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, onEffectInit, restockMachineConfig.Variant)

---@param eff EntityEffect
local function onUpdate(_, eff)
    if eff.SubType == restockMachineConfig.SubType then
        if eff.FrameCount % 2 == 0 then
            local save = Resouled.SaveManager.GetRoomSave()
            if not save.RollCount then save.RollCount = 0 end
            local data = eff:GetData()
            local players = Isaac.FindInRadius(eff.Position, COLLISION_RADIUS, EntityPartition.PLAYER)
            if #players > 0 then
                if not data.Resouled_AfterlifeShopRerollMachineActiveCooldown then
                    
                    local i = 0
                    ---@param pic EntityPickup
                    Resouled.Iterators:IterateOverRoomPickups(function(pic)
                        if pic.Variant == buffPedestalConfig.Variant and pic.SubType == buffPedestalConfig.SubType then
                            Resouled:RollShopBuffPedestalBuff(pic, i * save.RollCount)
                            i = i + 1
                        end
                    end)

                    save.RollCount = save.RollCount + 1

                    data.Resouled_AfterlifeShopRerollMachineActiveCooldown = true
                end
            else
                if data.Resouled_AfterlifeShopRerollMachineActiveCooldown then
                    data.Resouled_AfterlifeShopRerollMachineActiveCooldown = nil
                end
            end
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, onUpdate, restockMachineConfig.Variant)