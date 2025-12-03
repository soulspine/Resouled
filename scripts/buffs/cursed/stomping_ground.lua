local quake = {
    MaxTime = 300,
    MaxStrength = 20,
    MaxOffset = 30,

    Time = -1,
    Gain = 0
}

local FREQUENCY = 120
local CHANCE = 0.05

--https://www.desmos.com/calculator/lmmug1mlkm

---@param time number
---@return Vector
local function getSpriteOffset(time)
    return Vector(0,
        -(2.5 * math.abs(
            math.sin(
                (math.max((quake.MaxStrength - math.min(time, quake.MaxStrength)), 1) * time)/quake.MaxStrength * 6
            )
        ) * (math.min(quake.Time/(quake.MaxTime/2), 1)) * quake.MaxStrength/4
    ))
end


local function curseActive()
    return Resouled:ActiveBuffPresent(Resouled.Buffs.STOMPING_GROUND) or Resouled:IsSpecialSeedEffectActive(Resouled.SpecialSeedEffects.EverythingIsCursed)
end

local function Earthquake()
    if not curseActive() or Game():IsPaused() then return end

    if quake.Time == -1 then
        local frames = Game():GetFrameCount()
        if frames > 100 and frames % FREQUENCY == 0 and math.random() < CHANCE then
            quake.Gain = 1
            quake.Time = 0
        end
    end

    quake.Time = math.max(math.min(quake.Time + quake.Gain, quake.MaxTime), -1)

    if quake.Time == quake.MaxTime then quake.Gain = -quake.Gain end

    if quake.Time == -1 then quake.Gain = 0 end

    Game():ShakeScreen((math.floor(quake.Time/2)))
end

local rng = RNG()

---@param en Entity
---@param offset Vector
local function earthquakeEntities(_, en, offset)
    if not curseActive() or en:IsFlying() then return end

    rng:SetSeed(en.InitSeed)

    local newOffset = offset + getSpriteOffset(Game():GetFrameCount() + rng:RandomInt(quake.MaxOffset)) - Game():GetRoom():GetRenderScrollOffset()

    if not Game():IsPaused() and newOffset.Y >= -1.5 and quake.Time > quake.MaxStrength/2 then
        en.Velocity = en.Velocity + Vector(2, 0):Rotated(360 * math.random()) * math.random()
    end

    return newOffset
end

---@param en GridEntity
---@param offset Vector
local function earthquakeGridEntities(_, en, offset)
    if not curseActive() then return end

    rng:SetSeed(math.floor(40 * en.Position.Y + en.Position.X) * 57219)

    return offset + getSpriteOffset(Game():GetFrameCount() + rng:RandomInt(quake.MaxOffset))
end

Resouled:AddCallback(ModCallbacks.MC_PRE_NPC_RENDER, earthquakeEntities)
Resouled:AddCallback(ModCallbacks.MC_PRE_PLAYER_RENDER, earthquakeEntities)
Resouled:AddCallback(ModCallbacks.MC_PRE_PICKUP_RENDER, earthquakeEntities)
Resouled:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_RENDER, earthquakeEntities)
Resouled:AddCallback(ModCallbacks.MC_PRE_BOMB_RENDER, earthquakeEntities)

Resouled:AddCallback(ModCallbacks.MC_PRE_GRID_ENTITY_ROCK_RENDER, earthquakeGridEntities)
Resouled:AddCallback(ModCallbacks.MC_PRE_GRID_ENTITY_TNT_RENDER, earthquakeGridEntities)
Resouled:AddCallback(ModCallbacks.MC_PRE_GRID_ENTITY_LOCK_RENDER, earthquakeGridEntities)
Resouled:AddCallback(ModCallbacks.MC_PRE_GRID_ENTITY_FIRE_RENDER, earthquakeGridEntities)
Resouled:AddCallback(ModCallbacks.MC_PRE_GRID_ENTITY_POOP_RENDER, earthquakeGridEntities)

Resouled:AddCallback(ModCallbacks.MC_POST_RENDER, Earthquake)

Resouled:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function()
    quake.Gain = 0
    quake.Time = -1
end)

Resouled:AddBuffToRemoveOnRunEnd(Resouled.Buffs.STOMPING_GROUND)