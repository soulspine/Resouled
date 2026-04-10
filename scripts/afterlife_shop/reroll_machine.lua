local buffPedestalConfig = Resouled.Stats.BuffPedestal

local rerollMachineConfig = Resouled.Stats.RerollMachine
local altar = rerollMachineConfig.Altar
local floorSign = rerollMachineConfig.FloorSign

local REROLL_CHANCE = 0.5
local REROLL_COOLDOWN = 30
local HITBOX_MULT = Vector(1, 0.6)

---@param pic EntityPickup
local function onPickupInit(_, pic)
    if pic.SubType == altar.SubType then
        pic.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
        
        local save = Resouled.AfterlifeShop.Goto:GetSave()
        local sprite = pic:GetSprite()
        sprite:SetFrame("Idle", save.WasDevil == true and 0 or 1)
        sprite:Stop()
        
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
        
        if data.Resouled_BuffRerollMachineCooldown then
            
            data.Resouled_BuffRerollMachineCooldown = data.Resouled_BuffRerollMachineCooldown - 1
            if data.Resouled_BuffRerollMachineCooldown == 0 then data.Resouled_BuffRerollMachineCooldown = nil end
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, onPickupUpdate, altar.Variant)

---@param pic EntityPickup
---@param en Entity
local function postPickupCollision(_, pic, en)
    local player = en:ToPlayer()
    local soulCount = Resouled:GetPossessedSoulsNum()
    if not player or pic.SubType ~= altar.SubType or soulCount <= 0 then return end

    local data = pic:GetData()
    if not data.Resouled_BuffRerollMachineCooldown then

        local varData = pic:GetVarData()

        local rollRNG = RNG(Resouled.Game:GetSeeds():GetStartSeed())
        for _ = 1, varData do rollRNG:Next() end

        if rollRNG:RandomFloat() < REROLL_CHANCE then
            local rolledBuffs = {}
            
            ---@param pic2 EntityPickup
            Resouled.Iterators:IterateOverRoomPickups(function(pic2)
                if pic2.Variant == buffPedestalConfig.Variant and pic2.SubType == buffPedestalConfig.SubType then
                    
                    local blacklist = {}
                    
                    blacklist[pic2:GetVarData()] = true
                    for _, id in ipairs(rolledBuffs) do
                        blacklist[id] = true
                    end
                    
                    pic2:SetVarData(Resouled:GetShopBuffRoll(pic2.InitSeed, varData, blacklist) or 0)
                    
                    table.insert(rolledBuffs, pic2:GetVarData())
                end
            end)
        end

        pic:SetVarData(varData + 1)

        data.Resouled_BuffRerollMachineCooldown = REROLL_COOLDOWN

        Resouled:SetPossessedSoulsNum(soulCount - 1)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PICKUP_COLLISION, postPickupCollision, altar.Variant)

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