---@class ProceduralMaxChargeModule
local proceduralMaxChargeModule = {}

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

MOD:AddCallback(ModCallbacks.MC_POST_PLAYERHUD_RENDER_ACTIVE_ITEM,
---@param player EntityPlayer
---@param activeSlot ActiveSlot
---@param offset Vector
---@param alpha number
---@param scale number
---@param chargebarOffset Vector
function(_, player, activeSlot, offset, alpha, scale, chargebarOffset)
    local maxCharge = player:GetActiveMaxCharge(activeSlot)
    if maxCharge > 0 and not MAXCHARGE_RENDER_BLACKLIST[maxCharge] then
        separatorSprite.Scale = Vector(1.5, 1) * scale
        separatorSprite.Color = Color(1, 1, 1, alpha)
        
        separatorSprite.Scale.Y = separatorSprite.Scale.Y * math.min(1, 12 / maxCharge)
        print(maxCharge, separatorSprite.Scale.Y)

        local startingOffset = chargebarOffset + Vector(0, 12) * scale
        local offsetDelta = Vector(0, -23 / maxCharge) * scale
        for i = 1, maxCharge - 1 do
            separatorSprite:Render(startingOffset + offsetDelta * i)
        end
    end
end)

return proceduralMaxChargeModule