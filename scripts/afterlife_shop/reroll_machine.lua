local buffPedestalConfig = Resouled.Stats.BuffPedestal

local rerollMachineConfig = Resouled.Stats.RerollMachine
local altar = rerollMachineConfig.Altar
local floorSign = rerollMachineConfig.FloorSign

local REROLL_CHANCE = 0.5
local HITBOX_MULT = Vector(1, 0.6)

---@param pic EntityPickup
local function onPickupInit(_, pic)
    if pic.SubType == altar.SubType then
        pic.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
        pic:GetSprite():Play("Idle", true)
        pic:GetData().Resouled_BuffRerollMachineSpawnPos = pic.Position
        Resouled.Game:Spawn(floorSign.Type, floorSign.Variant, pic.Position, Vector.Zero, pic, floorSign.SubType, 1)
        pic.SizeMulti = HITBOX_MULT
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, onPickupInit, altar.Variant)

---@param pic EntityPickup
local function onPickupUpdate(_, pic)
    if pic.SubType == altar.SubType then
        local data = pic:GetData()
        pic.Velocity = Vector.Zero
        pic.Position = data.Resouled_BuffRerollMachineSpawnPos
        if Resouled:GetPossessedSoulsNum() <= 0 then return end
        if pic.FrameCount % 2 == 0 then
            local save = Resouled.SaveManager.GetRoomSave()
            if not save.RollCount then save.RollCount = 0 end
            --[[
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
            ]]--
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, onPickupUpdate, altar.Variant)

local pentagramColor = Color()

---@param eff EntityEffect
local function postEffectInit(_, eff)
    if eff.SubType ~= floorSign.SubType then return end
    eff:GetSprite():Play("Idle")
    eff.Color.A = 0
    eff.DepthOffset = -100
end
Resouled:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, postEffectInit, floorSign.Variant)

---@param eff EntityEffect
local function postEffectUpdate(_, eff)
    if eff.SubType ~= floorSign.SubType then return end
    local layer = eff:GetSprite():GetLayer("layer")
    if layer then
        pentagramColor.A = 0.25 +  math.min(math.max(100 - Isaac.GetPlayer().Position:Distance(eff.Position), 0), 100)/100 * 0.75
        local colorMult = 0.5 + pentagramColor.A/2
        pentagramColor.R = colorMult
        pentagramColor.G = colorMult
        pentagramColor.B = colorMult
        layer:SetColor(pentagramColor)
        EntityEffect.CreateLight(eff.Position, pentagramColor.A * 2, 1, 6, pentagramColor)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, postEffectUpdate, floorSign.Variant)