local anm2path = "/gfx_resouled/status_effects/status_effects.anm2"

-- reference Resouled.Enums.StatusEffect when adding them
local effects = Resouled.Enums.StatusEffects

StatusEffectLibrary.RegisterStatusEffect(
    effects.BLACK_PROGLOTTID,
    Resouled:CreateLoadedSprite(anm2path, effects.BLACK_PROGLOTTID),
    Color(0.5, 0.5, 0.5),
    nil,
    true
)

StatusEffectLibrary.RegisterStatusEffect(
    effects.WHITE_PROGLOTTID,
    Resouled:CreateLoadedSprite(anm2path, effects.WHITE_PROGLOTTID),
    Color(1.2, 1.2, 1.2, 1, 0.2, 0.2, 0.2),
    nil,
    true
)

StatusEffectLibrary.RegisterStatusEffect(
    effects.PINK_PROGLOTTID,
    Resouled:CreateLoadedSprite(anm2path, effects.PINK_PROGLOTTID),
    Color(1, 0.75, 0.8),
    nil,
    true
)


StatusEffectLibrary.RegisterStatusEffect(
    effects.RED_PROGLOTTID,
    Resouled:CreateLoadedSprite(anm2path, effects.RED_PROGLOTTID),
    Color(1, 0, 0),
    nil,
    true
)

StatusEffectLibrary.RegisterStatusEffect(
    effects.MUGGER_BEAN,
    Resouled:CreateLoadedSprite(anm2path, effects.MUGGER_BEAN),
    Color(1, 1, 1),
    nil,
    true
)
