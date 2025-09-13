local TRINKET = Isaac.GetTrinketIdByName("Game Squid")

local APPLY_CHANCE = 1

local TENTACLE = Resouled:GetEntityByName("Stun Tentacle (Pink)")
local TENTACLE_COOLDOWN_PER_ENEMY = 350

---@param entity Entity
---@param amount number
---@param flags DamageFlag
---@param source EntityRef
---@param countdown integer
local function onEntityDamage(_, entity, amount, flags, source, countdown)
    local npc = entity:ToNPC()
    if not npc or not npc:IsVulnerableEnemy() then return end

    local data = entity:GetData()
    if data.Resouled__GameSquidCooldown then return end

    if not source or not source.Entity then return end
    while source.Entity.Parent do
        source = EntityRef(source.Entity.Parent)
    end

    local player = source.Entity:ToPlayer()
    if not player or not player:HasTrinket(TRINKET) then return end

    local rng = RNG(npc.InitSeed, 43)
    if rng:RandomFloat() > APPLY_CHANCE then return end

    data.Resouled__GameSquidCooldown = TENTACLE_COOLDOWN_PER_ENEMY
    Game():Spawn(TENTACLE.Type, TENTACLE.Variant, npc.Position, Vector.Zero, player, TENTACLE.SubType, Resouled:NewSeed())
end
Resouled:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, onEntityDamage)

---@param npc EntityNPC
local function onNpcUpdate(_, npc)
    local data = npc:GetData()
    if not data.Resouled__GameSquidCooldown then return end

    if data.Resouled__GameSquidCooldown > 0 then
        data.Resouled__GameSquidCooldown = data.Resouled__GameSquidCooldown - 1
    else
        data.Resouled__GameSquidCooldown = nil
    end
end
Resouled:AddCallback(ModCallbacks.MC_NPC_UPDATE, onNpcUpdate)
