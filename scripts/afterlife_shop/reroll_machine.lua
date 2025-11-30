local buffPedestalConfig = Resouled.Stats.BuffPedestal

local restockMachineConfig = Resouled.Stats.RerollMachine

local REROLL_CHANCE = 0.5
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
        if Resouled:GetPossessedSoulsNum() <= 0 then return end
        if eff.FrameCount % 2 == 0 then
            local save = Resouled.SaveManager.GetRoomSave()
            if not save.RollCount then save.RollCount = 0 end
            local data = eff:GetData()
            local players = Isaac.FindInRadius(eff.Position, COLLISION_RADIUS, EntityPartition.PLAYER)
            if #players > 0 then
                if not data.Resouled_AfterlifeShopRerollMachineActiveCooldown then
    
                    if math.random() < REROLL_CHANCE then
                        local rolledBuffs = {}
                        
                        ---@param pic EntityPickup
                        Resouled.Iterators:IterateOverRoomPickups(function(pic)
                            if pic.Variant == buffPedestalConfig.Variant and pic.SubType == buffPedestalConfig.SubType then
                                
                                local blacklist = {}
                                
                                blacklist[pic:GetVarData()] = true
                                for _, id in ipairs(rolledBuffs) do
                                    blacklist[id] = true
                                end
                                
                                pic:SetVarData(Resouled:GetShopBuffRoll(pic.InitSeed, save.RollCount, blacklist) or 0)
                                
                                table.insert(rolledBuffs, pic:GetVarData())
                            end
                        end)
                        
                        save.RollCount = save.RollCount + 1
                    end

                    Resouled:SetPossessedSoulsNum(Resouled:GetPossessedSoulsNum() - 1)

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