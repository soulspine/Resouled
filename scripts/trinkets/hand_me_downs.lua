local HAND_ME_DOWNS = Isaac.GetTrinketIdByName("Hand me Downs")

local CONFIG = {
    EffectApplyChance = 0.1,
    EidDescriptionPreFormat = "Tears shot by your familiars have %s%% chance to inherit your tear effects"
}

Resouled.EID:AddTrinket(HAND_ME_DOWNS,
    string.format(CONFIG.EidDescriptionPreFormat, Resouled.EID:FormatFloat(CONFIG.EffectApplyChance * 100))
)

Resouled.EID:AddTrinketConditional(HAND_ME_DOWNS, "Resouled__HandMeDowns_Golden",
    Resouled.EID.CommonConditions.HigherTrinketMult,
    function(desc)
        local newChance = (CONFIG.EffectApplyChance * Resouled.EID.GetTrinketMultFromDesc(desc)) * 100

        desc.Description = string.format(
            CONFIG.EidDescriptionPreFormat,
            "{{ColorGold}}" .. Resouled.EID:FormatFloat(newChance) .. "{{ColorText}}"
        )

        return desc
    end
)

---@param tear EntityTear
local function postTearInit(_, tear)
    local player = Resouled:TryFindPlayerSpawnerIfEntityFamiliar(tear)
    if player then
        local mult = player:GetTrinketMultiplier(HAND_ME_DOWNS)
        if mult > 0 then
            print(CONFIG.EffectApplyChance * mult)
            if math.random() < CONFIG.EffectApplyChance * mult then
                local newTear = player:FireTear(tear.Position, tear.Velocity, true, false, false, tear.SpawnerEntity)
                newTear.CollisionDamage = tear.CollisionDamage
                tear:Remove()
            end
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_TEAR_INIT, postTearInit)
