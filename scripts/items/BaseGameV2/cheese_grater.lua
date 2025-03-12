local CHEESE_GRATER = Isaac.GetItemIdByName("Cheese Grater")

local DAMAGE_MULTIPLIER = 2.5
local COOLDOWN = 100

local GRATED_OFF_ENEMY_HEALTH_FRACTION = 0.01
local GRATED_OFF_ENEMY_TYPE = EntityType.ENTITY_SMALL_MAGGOT
local GRATED_OFF_ENEMY_VARIANT = 0
local GRATED_OFF_ENEMY_SUBTYPE = 0

if EID then
    EID:addCollectible(CHEESE_GRATER, "Reveals all {{QuestionMark}} question mark items.#Works on alt path choices and {{CurseBlind}} Curse of the Blind.", "Cheese Grater")
end

---@param luck number
---@return number
local APPLY_TEAR_EFFECT_CHANCE = function(luck)
    return ((6 + luck) / 18)^2
end

---@param tear EntityTear
local function onTearInit(_, tear)
    local player = tear.SpawnerEntity:ToPlayer()
    if player and player:HasCollectible(CHEESE_GRATER) and tear:GetDropRNG():RandomFloat() < APPLY_TEAR_EFFECT_CHANCE(player.Luck) then
        Resouled:ApplyCustomTearEffect(tear, Resouled.TearEffects.CHEESE_GRATER)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_TEAR_INIT, onTearInit)

---@param entity Entity
---@param amount number
---@param damageFlag integer
---@param source EntityRef
---@param countdown integer
local function onEntityTakeDamage(_, entity, amount, damageFlag, source, countdown)
    if source.Entity then
        local player = source.Entity:ToPlayer()
        local tear = source.Entity:ToTear()
        local npc = entity:ToNPC()
        if
        (player and player:HasCollectible(CHEESE_GRATER) and player:GetCollectibleRNG(CHEESE_GRATER):RandomFloat() < APPLY_TEAR_EFFECT_CHANCE(player.Luck)) or
        (tear and Resouled:GetCustomTearEffects(tear) and Resouled:GetCustomTearEffects(tear) | Resouled.TearEffects.CHEESE_GRATER == Resouled.TearEffects.CHEESE_GRATER) then
            if npc and npc:IsVulnerableEnemy() and not (damageFlag & DamageFlag.DAMAGE_FAKE == DamageFlag.DAMAGE_FAKE) and not Resouled:IsCustomTearEffectOnCooldown(npc, Resouled.TearEffects.CHEESE_GRATER) then
                entity:TakeDamage(DAMAGE_MULTIPLIER * amount, damageFlag | DamageFlag.DAMAGE_FAKE, source, countdown)
                Resouled:ApplyCustomTearEffectCooldown(npc, Resouled.TearEffects.CHEESE_GRATER, COOLDOWN)

                if npc.HitPoints - DAMAGE_MULTIPLIER * amount > 0 then
                    local gratedOffEntity = Game():Spawn(GRATED_OFF_ENEMY_TYPE, GRATED_OFF_ENEMY_VARIANT, npc.Position, Vector.FromAngle(math.random(360)):Normalized(), npc, GRATED_OFF_ENEMY_SUBTYPE, npc.DropSeed)
                    gratedOffEntity:AddHealth(-1*(1-GRATED_OFF_ENEMY_HEALTH_FRACTION)*gratedOffEntity.MaxHitPoints)
                end

                return false
            end
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, onEntityTakeDamage)

---@param pickup EntityPickup
local function oncCollectibleUpdate(_, pickup)
-- THIS HAS TO BE POST UPDATE BECAUSE POST INIT THERE IS NO SPRITE LOADED YET
-- POST RENDER ALSO DOES NOT WORK CORRECTLY BECAUSE IT GOES BACK AND FORTH BETWEEN BEING A QUESTION MARK AND NOT
    if Resouled:CollectiblePresent(CHEESE_GRATER) then
        Resouled:TryRevealQuestionMarkItem(pickup)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, oncCollectibleUpdate, PickupVariant.PICKUP_COLLECTIBLE)