---@class ProceduralMaxChargeModule
local proceduralMaxChargeModule = {}

local CUSTOM_TAG = "alwaysproceduralcharge"

local separatorSprite = Sprite()
separatorSprite:Load("gfx/ui/chargebar_separator.anm2", true)
separatorSprite:Play("Separator", true)

local MOD = Resouled

local MAXCHARGE_RENDER_BLACKLIST = {
    [1] = true,
    [2] = true,
    [3] = true,
    [4] = true,
    [5] = true,
    [6] = true,
    [8] = true,
    [12] = true,
}

---@param player EntityPlayer
---@param activeSlot ActiveSlot
---@param offset Vector
---@param alpha number
---@param scale number
---@param chargebarOffset Vector
---@param customMaxCharge integer|nil
local function renderer(_, player, activeSlot, offset, alpha, scale, chargebarOffset, customMaxCharge)
    local maxCharge = customMaxCharge or player:GetActiveCharge(activeSlot)
    
    local itemDesc = Isaac.GetItemConfig():GetCollectible(player:GetActiveItem(activeSlot))

    if itemDesc and itemDesc.ChargeType ~= 1 then
        
        if maxCharge > 0 and (not MAXCHARGE_RENDER_BLACKLIST[maxCharge] or itemDesc:HasCustomTag(CUSTOM_TAG)) then
            separatorSprite.Scale = Vector(1.25, 1) * scale
            separatorSprite.Color = Color(1, 1, 1, alpha)
            
            separatorSprite.Scale.Y = separatorSprite.Scale.Y * math.min(1, 12 / maxCharge)
            
            local startingOffset = chargebarOffset + Vector(0, 12) * scale
            local offsetDelta = Vector(0, -23 / maxCharge) * scale
            for i = 1, maxCharge - 1 do
                separatorSprite:Render(startingOffset + offsetDelta * i)
            end
        end
    end
end

---@param player EntityPlayer
---@param activeSlot ActiveSlot
---@param offset Vector
---@param alpha number
---@param scale number
---@param chargebarOffset Vector
---@param customMaxCharge integer|nil If specified, max charge will not be retrieved using player:GetActiveCharge(activeSlot) but will use this value instead
function proceduralMaxChargeModule:InvokeManually(player, activeSlot, offset, alpha, scale, chargebarOffset, customMaxCharge)
    renderer(nil, player, activeSlot, offset, alpha, scale, chargebarOffset, customMaxCharge)
end

MOD:AddCallback(ModCallbacks.MC_POST_PLAYERHUD_RENDER_ACTIVE_ITEM, renderer)

return proceduralMaxChargeModule