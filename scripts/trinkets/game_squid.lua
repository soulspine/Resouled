local TRINKET = Resouled.Enums.Trinkets.GAME_SQUID
local TENTACLE = Resouled.Enums.Effects.STUN_TENTACLE_PINK

local CONFIG = {
    ApplyChance = 0.12,
    TentacleCooldown = 300,
    EidDescriptionPreFormat =
    "Damaging an enemy has a %s%% chance to summon a tentacle holding them in place#This effect can happen every %s seconds per enemy",
}

Resouled.EID:AddTrinket(TRINKET,
    string.format(
        CONFIG.EidDescriptionPreFormat,
        Resouled.EID:FormatFloat(CONFIG.ApplyChance * 100),
        Resouled.EID:FormatFloat(CONFIG.TentacleCooldown / 30)
    )
)
Resouled.EID:AddTrinketConditional(TRINKET, "Resouled__GameSquid_Golden",
    Resouled.EID.CommonConditions.HigherTrinketMult,
    function(desc)
        local mult = Resouled.EID:GetTrinketMultFromDesc(desc)
        local newChance = CONFIG.ApplyChance * mult * 100
        local newCooldown = CONFIG.TentacleCooldown / mult / 30

        desc.Description = string.format(
            CONFIG.EidDescriptionPreFormat,
            "{{ColorGold}}" .. Resouled.EID:FormatFloat(newChance) .. "{{ColorText}}",
            "{{ColorGold}}" .. Resouled.EID:FormatFloat(newCooldown) .. "{{ColorText}}"
        )
        return desc
    end
)

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

    local trinketMult = player:GetTrinketMultiplier(TRINKET)
    local applyChance = CONFIG.ApplyChance * trinketMult
    local cooldown = math.floor(CONFIG.TentacleCooldown / trinketMult)

    local rng = RNG(npc.InitSeed, 43)
    if rng:RandomFloat() > applyChance then return end

    data.Resouled__GameSquidCooldown = cooldown
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
