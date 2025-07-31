-- I PUT THE ACTUAL LOGIC BEHIND THEIR EFFECT IN RESPECIVE PROGLOTTID FILES
-- THIS JUST REPLACES THEIR SPRITESHEETS AND ADDS TEAR FLAGS

local BLACK_PROGLOTTIDS_EGG = Resouled:GetEntityByName("Black Proglottid's Egg")
local PINK_PROGLOTTIDS_EGG = Resouled:GetEntityByName("Pink Proglottid's Egg")
local WHITE_PROGLOTTIDS_EGG = Resouled:GetEntityByName("White Proglottid's Egg")
local RED_PROGLOTTIDS_EGG = Resouled:GetEntityByName("Red Proglottid's Egg")

local CLEAR_EGG_SPRITESHEET = "gfx/tears/egg_clear.png"
local PINK_EGG_SPRITESHEET = "gfx/tears/egg_pink.png"
local WHITE_EGG_SPRITESHEET = "gfx/tears/egg_white.png"

local SPRITESHEET_LAYER = 0

local TEAR_FALLING_SPEED = 1         -- -90
local TEAR_FALLIING_ACCELERATION = 1 -- 7
local TEAR_FLAGS = TearFlags.TEAR_SPECTRAL | TearFlags.TEAR_HOMING

local ANIMATION_IDLE = "Idle"

local SPRITESHEETS = {
    [BLACK_PROGLOTTIDS_EGG.SubType] = PINK_EGG_SPRITESHEET,
    [WHITE_PROGLOTTIDS_EGG.SubType] = WHITE_EGG_SPRITESHEET,
    [PINK_PROGLOTTIDS_EGG.SubType] = WHITE_EGG_SPRITESHEET,
    [RED_PROGLOTTIDS_EGG.SubType] = CLEAR_EGG_SPRITESHEET,
}

---@param tear EntityTear
local function onTearInit(_, tear)
    if SPRITESHEETS[tear.SubType] then
        local sprite = tear:GetSprite()
        sprite:ReplaceSpritesheet(SPRITESHEET_LAYER, SPRITESHEETS[tear.SubType], true)
        sprite:Play(ANIMATION_IDLE, true)
        tear:AddTearFlags(TEAR_FLAGS)
        tear.FallingAcceleration = TEAR_FALLIING_ACCELERATION
        tear.FallingSpeed = TEAR_FALLING_SPEED
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_TEAR_INIT, onTearInit, BLACK_PROGLOTTIDS_EGG.Variant)
