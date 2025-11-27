local donoConfig = Resouled.Stats.DontionMachine

local SIZE_MULTI = Vector(1.2, 0.9)
local DONO_COOLDOWN = 7

local font = Font()
font:Load("font/teammeatfont10.fnt")

---@param pic EntityPickup
local function postPickupInit(_, pic)
    if pic.SubType == donoConfig.SubType then
        pic:GetSprite():Play("Idle", true)
        pic:GetData().Resouled_AfterlifeShopDonatiobnMachinePositionLock = pic.Position
        pic.SizeMulti = SIZE_MULTI
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, postPickupInit, donoConfig.Variant)

---@param pic EntityPickup
local function onPickupUpdate(_, pic)
    if pic.SubType == donoConfig.SubType then
        local data = pic:GetData()
        pic.Position = data.Resouled_AfterlifeShopDonatiobnMachinePositionLock

        if data.Resouled_AfterlifeShopDonatiobnMachineCooldown then
            data.Resouled_AfterlifeShopDonatiobnMachineCooldown = data.Resouled_AfterlifeShopDonatiobnMachineCooldown - 1
            if data.Resouled_AfterlifeShopDonatiobnMachineCooldown <= 0 then
                data.Resouled_AfterlifeShopDonatiobnMachineCooldown = nil
            end
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, onPickupUpdate, donoConfig.Variant)

---@param pic EntityPickup
---@param collider Entity
local function onCollision(_, pic, collider)
    if pic.SubType == donoConfig.SubType then
        local soulsNum = Resouled:GetPossessedSoulsNum()
        local data = pic:GetData()

        if collider:ToPlayer() and soulsNum > 0 and not data.Resouled_AfterlifeShopDonatiobnMachineCooldown then
            Resouled:SetPossessedSoulsNum(soulsNum - 1)
            data.Resouled_AfterlifeShopDonatiobnMachineCooldown = DONO_COOLDOWN
            pic:SetColor(Color(1, 1, 1, 1, 0.5, 0.5, 0.5), 10, 1, true, true)

            local statSave = Resouled.StatTracker:GetSave()
            if not statSave[Resouled.StatTracker.Fields.SoulsDonated] then statSave[Resouled.StatTracker.Fields.SoulsDonated] = 0 end
            statSave[Resouled.StatTracker.Fields.SoulsDonated] = statSave[Resouled.StatTracker.Fields.SoulsDonated] + 1

            local save = Resouled.SaveManager.GetPersistentSave()
            if not save then save = {} end
            if not save.SoulsInUrn then save.SoulsInUrn = 0 end
            save.SoulsInUrn = save.SoulsInUrn + 1
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PICKUP_COLLISION, onCollision, donoConfig.Variant)

---@param pic EntityPickup
local function postPickupRender(_, pic)
    if pic.SubType == donoConfig.SubType then
        local save = Resouled.SaveManager.GetPersistentSave()
        if save and save.SoulsInUrn then
            local pos = Isaac.WorldToScreen(pic.Position)
            local string = tostring(save.SoulsInUrn)
            font:DrawString(string, pos.X, pos.Y - 52, KColor(1, 1, 1, 1), math.floor(font:GetStringWidth(string)/2 + 0.5))
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PICKUP_RENDER, postPickupRender, donoConfig.Variant)