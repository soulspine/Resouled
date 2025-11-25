Resouled.Stats = {}

Resouled.Stats.CursedEnemyMorphChance = function()
    return Resouled:GetOptionValue("Cursed Enemy Morph Chance")/100
end

Resouled.Stats.CursedProjectileColor = Color(0.5, 0, 0.75, 1, 0.5 * 0.45, 0, 0.75 * 0.45)
Resouled.Stats.CursedProjectileVariant = ProjectileVariant.PROJECTILE_TEAR

---@return ProjectileParams
function Resouled.Stats:GetCursedProjectileParams()
    local x = ProjectileParams()
    x.Color = Resouled.Stats.CursedProjectileColor
    x.Variant = Resouled.Stats.CursedProjectileVariant
    return x
end

Resouled.Stats.BlueKingCrownBuff = {
    [PickupVariant.PICKUP_BOMB] = {
        [BombSubType.BOMB_NORMAL] = {[1] = BombSubType.BOMB_DOUBLEPACK, [2] = BombSubType.BOMB_GOLDEN}
    },
    [PickupVariant.PICKUP_COIN] = {
        [CoinSubType.COIN_PENNY] = {[1] = CoinSubType.COIN_NICKEL, [2] = CoinSubType.COIN_STICKYNICKEL, [3] = CoinSubType.COIN_LUCKYPENNY, [4] = CoinSubType.COIN_DIME, [5] = CoinSubType.COIN_DOUBLEPACK, [6] = CoinSubType.COIN_GOLDEN}
    },
    [PickupVariant.PICKUP_CHEST] = {
        [1] = PickupVariant.PICKUP_BOMBCHEST, [2] = PickupVariant.PICKUP_LOCKEDCHEST, [3] = PickupVariant.PICKUP_WOODENCHEST
    },
    [PickupVariant.PICKUP_KEY] = {
        [KeySubType.KEY_NORMAL] = {[1] = KeySubType.KEY_CHARGED, [2] = KeySubType.KEY_GOLDEN, [3] = KeySubType.KEY_DOUBLEPACK}
    },
    [PickupVariant.PICKUP_LIL_BATTERY] = {
        [BatterySubType.BATTERY_MICRO] = {[1] = BatterySubType.BATTERY_NORMAL}
    },
    Level1Chance = {
        Pickup = 0.025,
        Champion = 0.15,
    },
    Level2Chance = {
        Pickup = 0.05,
        Champion = 0.10
    },
    Level3Chance = {
        Pickup = 0.075,
        Champion = 0.05,
        Keys = 0.05,
    },
}

Resouled.Stats.Soul = {
    Variant = Isaac.GetEntityVariantByName("Soul"),
    SubType = Isaac.GetEntitySubTypeByName("Soul"),
    SubTypeStatue = Isaac.GetEntitySubTypeByName("Soul Statue Target"),
    StartVelocity = Vector(10, 0),
    TrailColor = Color(1, 1, 1, 0.8),
    Trail2Color = Color(1, 1, 1, 0.9),
    TrailLength = 0.025, --The lower the number the longer
    Trail2Length = 0.020,
    SpriteOffset = Vector(0, -10),
    TrailScale = Vector(0.8, 0.8),
    Trail2Scale = Vector(1.7, 1.7),
    TrailDepthOffset = -30,

    PlayPickupSound = function()
        SFXManager():Play(Isaac.GetSoundIdByName("Soul Pickup "..tostring(math.random(4))))
    end,

    Max = 99
}

Resouled.Stats.DeathStatue = {
    Variant = Isaac.GetEntityVariantByName("Death Statue"),
    SubType = Isaac.GetEntitySubTypeByName("Death Statue"),
    Size = 20,
}

Resouled.Stats.ResouledHitbox = {
    Type = Isaac.GetEntityTypeByName("ResouledHitbox"),
    Variant = Isaac.GetEntityVariantByName("ResouledHitbox"),
    SubType = Isaac.GetEntitySubTypeByName("ResouledHitbox")
}

Resouled.Stats.FiendBuff = {
    BombChance = 0.00075
}

Resouled.Stats.DemonBuff = {
    OnDeathChance = 0.05,
    OnHitForBossChance = 0.01,
    BigDamage = 60,
    SmallDamage = 15,
}

Resouled.Stats.CurseOfAmnesia = {
    DisappearChance = 0.35,
    AppearChance = 0.50,
}

Resouled.Stats.GuppyItems = {}

local itemConfig = Isaac.GetItemConfig()
for i = 1, #itemConfig:GetCollectibles() do
    local item = itemConfig:GetCollectible(i)
    if item and item:HasTags(ItemConfig.TAG_GUPPY) then
        table.insert(Resouled.Stats.GuppyItems, i)
    end
end

Resouled.Stats.BuffPedestal = {
    Type = Isaac.GetEntityTypeByName("Buff Pedestal"),
    Variant = Isaac.GetEntityVariantByName("Buff Pedestal"),
    SubType = Isaac.GetEntitySubTypeByName("Buff Pedestal")
}

Resouled.Stats.Casket = {
    Type = Isaac.GetEntityTypeByName("Casket"),
    Variant = Isaac.GetEntityVariantByName("Casket"),
    SubType = Isaac.GetEntitySubTypeByName("Casket"),
    Speed = 0.5,
    AnimIn = "Trapdoor",
    AnimOut = "JumpOut",
    SizeMulti = Vector(1.5, 1)
}

Resouled.Stats.WiseSkull = {
    Type = Isaac.GetEntityTypeByName("Wise Skull"),
    Variant = Isaac.GetEntityVariantByName("Wise Skull"),
    SubType = Isaac.GetEntitySubTypeByName("Wise Skull")
}

Resouled.Stats.BuffDescriptions = {}
---@param buffId ResouledBuff
---@param description string
function Resouled:AddBuffDescription(buffId, description)
    Resouled.Stats.BuffDescriptions[buffId] = description
end

Resouled.Stats.AfterlifeBackdropFix = {
    Variant = Isaac.GetEntityVariantByName("Afterlife Backdrop Fix"),
    SubType = Isaac.GetEntitySubTypeByName("Afterlife Backdrop Fix")
}

Resouled.Stats.RerollMachine = {
    Type = EntityType.ENTITY_EFFECT,
    Variant = Isaac.GetEntityVariantByName("Afterlife Shop Reroll Machine"),
    SubType = Isaac.GetEntitySubTypeByName("Afterlife Shop Reroll Machine")
}