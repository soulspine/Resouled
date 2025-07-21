Resouled.Stats = {}

Resouled.Stats.CursedEnemyMorphChance = 0.1

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
    TrailColor = Color(1, 1, 1, 0.75),
    TrailLength = 0.025, --The lower the number the longer
    SpriteOffset = Vector(0, -10),

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