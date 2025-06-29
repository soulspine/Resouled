local GAVEL_VARIANT = Isaac.GetEntityVariantByName("Gavel")
local GAVEL_SUBTYPE = Isaac.GetEntitySubTypeByName("Gavel")

local SOUND_ID = Isaac.GetSoundIdByName("Gavel")

local MIN_VELOCITY = 3
local MAX_VELOCITY = 5

---@param effect EntityEffect
local function onEffectInit(_, effect)
    if effect.SubType == GAVEL_SUBTYPE then
        effect:GetSprite():Play("Hit", true)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, onEffectInit, GAVEL_VARIANT)

---@param effect EntityEffect
local function onEffectUpdate(_, effect)
    if effect.SubType == GAVEL_SUBTYPE then
        local sprite = effect:GetSprite()
        if sprite:IsFinished("Hit") then
            effect:Remove()
        end
        if sprite:IsEventTriggered("ResouledHit") then
            SFXManager():Play(SOUND_ID)

            local data = effect:GetData()
            if data.Resouled_DisappearItem then
                Resouled:SpawnItemDisappearEffect(data.Resouled_DisappearItem, effect.Position)

                local randomNum = math.random(4) + 1

                if randomNum == 1 then
                    for _ = 1, 10 do
                        Game():Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, effect.Position, Vector(math.random(MIN_VELOCITY, MAX_VELOCITY), 0):Rotated(math.random(0, 360)), nil, CoinSubType.COIN_PENNY, Resouled:NewSeed())
                    end
                elseif randomNum == 2 then
                    for _ = 1, 2 do
                        Game():Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, effect.Position, Vector(math.random(MIN_VELOCITY, MAX_VELOCITY), 0):Rotated(math.random(0, 360)), nil, CoinSubType.COIN_NICKEL, Resouled:NewSeed())
                    end
                elseif randomNum == 3 then
                    Game():Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, effect.Position, Vector(math.random(MIN_VELOCITY, MAX_VELOCITY), 0):Rotated(math.random(0, 360)), nil, CoinSubType.COIN_NICKEL, Resouled:NewSeed())
                    for _ = 1, 7 do
                        Game():Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, effect.Position, Vector(math.random(MIN_VELOCITY, MAX_VELOCITY), 0):Rotated(math.random(0, 360)), nil, CoinSubType.COIN_PENNY, Resouled:NewSeed())
                    end
                end
            end
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, onEffectUpdate, GAVEL_VARIANT)