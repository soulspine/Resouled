local COIL = Isaac.GetEntityTypeByName("Coil")
local COIL_VARIANT = Isaac.GetEntityVariantByName("Coil")
local COIL_SUBTYPE = Isaac.GetEntitySubTypeByName("Coil")

local COIL_FETUS_SUBTYPE = Isaac.GetEntitySubTypeByName("Coil Fetus")

local PLAYER_FOLLOW_SPEED = 0.005
local PLAYER_FOLLOW_VELOCITY_MULT = 0.9
local PLAYER_AVOID_SPEED = 0.001
local PLAYER_AVOID_VELOCITY_MULT = 1.1

local TEAR_COUNT = 3
local TEAR_SPEED = 5

local COIL_FETUS_TARGET_DIRECTION_SPEED_MULTIPLIER = 0.5
local COIL_FETUS_VELOCITY_MULTIPLIER = 0.95

---@param npc EntityNPC
local function postNpcInit(_, npc)
    if npc.Variant == COIL_VARIANT and npc.SubType == COIL_SUBTYPE then -- COIL
        local sprite = npc:GetSprite()
        sprite:Play("Idle", true)
        npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
    end

    if npc.Variant == COIL_VARIANT and npc.SubType == COIL_FETUS_SUBTYPE then -- FETUS
        local sprite = npc:GetSprite()
        sprite:Play("Idle", true)
        npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_INIT, postNpcInit, COIL)

---@param npc EntityNPC
local function onNpcUpdate(_, npc)
    local dirVector = (npc:GetPlayerTarget().Position - npc.Position)
    local sprite = npc:GetSprite()
    if npc.Variant == COIL_VARIANT and npc.SubType == COIL_SUBTYPE then -- COIL
        if npc:GetPlayerTarget().Position:Distance(npc.Position) > 100 then
            npc.Velocity = npc.Velocity * PLAYER_FOLLOW_VELOCITY_MULT + dirVector * PLAYER_FOLLOW_SPEED
        else
            npc.Velocity = npc.Velocity * PLAYER_AVOID_VELOCITY_MULT + -dirVector * PLAYER_AVOID_SPEED
            local randomNum = math.random()
            if Isaac.GetFrameCount() % 30 == 0 then
                for i = 1, TEAR_COUNT do
                    npc:FireProjectiles(npc.Position, (dirVector:Normalized() * TEAR_SPEED):Rotated((360/TEAR_COUNT)*(i-1)), 0, ProjectileParams())
                end
            end
        end
        npc.Pathfinder:EvadeTarget(npc:GetPlayerTarget().Position)

        if npc.Position.X - npc:GetPlayerTarget().Position.X < 0 then
            if sprite:GetLayer(1):GetFlipX() == false then
                sprite:GetLayer(1):SetFlipX(true)
            end
        else
            if sprite:GetLayer(1):GetFlipX() == true then
                sprite:GetLayer(1):SetFlipX(false)
            end
        end
    end

    if npc.Variant == COIL_VARIANT and npc.SubType == COIL_FETUS_SUBTYPE then -- FETUS
        npc.Velocity = (npc.Velocity + dirVector:Normalized() * COIL_FETUS_TARGET_DIRECTION_SPEED_MULTIPLIER) * COIL_FETUS_VELOCITY_MULTIPLIER --Adding the target direction to npc's velocity, then decreasing it so the npc doesn't fly everywhere
    end
end
Resouled:AddCallback(ModCallbacks.MC_NPC_UPDATE, onNpcUpdate, COIL)

---@param npc EntityNPC
local function postNpcDeath(_, npc)
    if npc.Variant == COIL_VARIANT and npc.SubType == COIL_SUBTYPE then
        local fetus = Game():Spawn(COIL, COIL_VARIANT, npc.Position, Vector.Zero, npc, COIL_FETUS_SUBTYPE, npc.InitSeed)
        fetus.FlipX = npc:GetSprite():GetLayer(1):GetFlipX()
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, postNpcDeath, COIL)