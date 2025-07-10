local TUMOR_BALL = Isaac.GetItemIdByName("Tumor Ball")
local FAMILIAR_VARIANT = Isaac.GetEntityVariantByName("Tumor Ball")
local FAMILIAR_SUBTYPE = Isaac.GetEntitySubTypeByName("Tumor Ball")

if EID then
    EID:addCollectible(TUMOR_BALL, "Spawns a familiar that blocks projectiles and grows # If it grows enough it splits into 2 tumor balls # Tumors can split only once per room")
end

local TUMOR_LIMIT = 20
local TUMOR_SPAWN_WHEN_SPLIT = 2

local BASE_ORBIT_DISTANCE = 20
local ORBIT_SIZE_TO_ADD_PER_TUMOR = 3

local TUMOR_SPLIT_VELOCITY = Vector(5, 0)

local VELOCITY_MULTIPLIER = 0.9
local PLAYER_FOLLOW_VELOCITY_SPEED = 0.25
local AVOID_SPEED = 0.75

local TUMOR_LOSS_PER_FLOOR = 4 -- 3/4 of the tumors get deleted

local TUMOR_LEVEL_1 = {
    SIZE = 9,
    HITS = 4,
    ANIMATION = "Stage1"
}
local TUMOR_LEVEL_2 = {
    SIZE = 12,
    HITS = 8,
    ANIMATION = "Stage2"
}
local TUMOR_LEVEL_3 = {
    SIZE = 16,
    HITS = 12,
    ANIMATION = "Stage3"
}
local TUMOR_LEVEL_4 = {
    SIZE = 20,
    HITS = 16,
    ANIMATION = "Stage4"
}

---@param player EntityPlayer
local function onCacheEval(_, player)
    local RUN_SAVE = SAVE_MANAGER.GetRunSave(player)
    local extra = 0
    if RUN_SAVE.Resouled_ExtraTumors then
        extra = RUN_SAVE.Resouled_ExtraTumors
    end
    local tumorNum = player:GetCollectibleNum(TUMOR_BALL) + extra
    if tumorNum > TUMOR_LIMIT then
        tumorNum = TUMOR_LIMIT
    end

    local rng = player:GetCollectibleRNG(TUMOR_BALL)
    rng:SetSeed(rng:GetSeed(), tumorNum)

    player:CheckFamiliar(FAMILIAR_VARIANT, tumorNum + player:GetEffects():GetCollectibleEffectNum(TUMOR_BALL), rng, Isaac.GetItemConfig():GetCollectible(TUMOR_BALL), FAMILIAR_SUBTYPE)
end
Resouled:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, onCacheEval, CacheFlag.CACHE_FAMILIARS)

---@param familiar EntityFamiliar
local function preFamiliarUpdate(_, familiar)
    if familiar.SubType == FAMILIAR_SUBTYPE then
        local player = Resouled:TryFindPlayerSpawner(familiar)
        if player then
            local RUN_SAVE = SAVE_MANAGER.GetRunSave(familiar)
            local PLAYER_RUN_SAVE = SAVE_MANAGER.GetRunSave(player)
            local sprite = familiar:GetSprite()
            local data = familiar:GetData()
            
            if not RUN_SAVE.Resouled_HitCount then
                RUN_SAVE.Resouled_HitCount = 0
            end
            
            if not PLAYER_RUN_SAVE.Resouled_ExtraTumors  then
                PLAYER_RUN_SAVE.Resouled_ExtraTumors = 0
            end
            local tumorBallCount = player:GetCollectibleNum(TUMOR_BALL) + PLAYER_RUN_SAVE.Resouled_ExtraTumors - 1

            local hitCount = RUN_SAVE.Resouled_HitCount

            if hitCount < TUMOR_LEVEL_1.HITS then
                if not sprite:IsPlaying(TUMOR_LEVEL_1.ANIMATION) then
                    sprite:Play(TUMOR_LEVEL_1.ANIMATION, true)
                end
                if familiar.Size ~= TUMOR_LEVEL_1.SIZE then
                    familiar.Size = TUMOR_LEVEL_1.SIZE 
                end
            end
            if hitCount >= TUMOR_LEVEL_1.HITS and hitCount < TUMOR_LEVEL_2.HITS then
                if not sprite:IsPlaying(TUMOR_LEVEL_2.ANIMATION) then
                    sprite:Play(TUMOR_LEVEL_2.ANIMATION, true)
                end
                if familiar.Size ~= TUMOR_LEVEL_2.SIZE then
                    familiar.Size = TUMOR_LEVEL_2.SIZE
                end
            end
            if hitCount >= TUMOR_LEVEL_2.HITS and hitCount < TUMOR_LEVEL_3.HITS then
                if not sprite:IsPlaying(TUMOR_LEVEL_3.ANIMATION) then
                    sprite:Play(TUMOR_LEVEL_3.ANIMATION, true)
                end
                if familiar.Size ~= TUMOR_LEVEL_3.SIZE then
                    familiar.Size = TUMOR_LEVEL_3.SIZE
                end
            end
            if hitCount >= TUMOR_LEVEL_3.HITS and hitCount < TUMOR_LEVEL_4.HITS then
                if not sprite:IsPlaying(TUMOR_LEVEL_4.ANIMATION) then
                    sprite:Play(TUMOR_LEVEL_4.ANIMATION, true)
                end
                if familiar.Size ~= TUMOR_LEVEL_4.SIZE then
                    familiar.Size = TUMOR_LEVEL_4.SIZE
                end
            end
            if hitCount >= TUMOR_LEVEL_4.HITS and not data.Resouled_TumorSplit and tumorBallCount <= TUMOR_LIMIT then
                PLAYER_RUN_SAVE.Resouled_ExtraTumors = PLAYER_RUN_SAVE.Resouled_ExtraTumors + 1

                local tumorCount = TUMOR_SPAWN_WHEN_SPLIT
                if player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
                    tumorCount = tumorCount + 1
                end
                
                for i = 1, tumorCount do
                    local newTumor = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FAMILIAR_VARIANT, FAMILIAR_SUBTYPE, familiar.Position, TUMOR_SPLIT_VELOCITY:Rotated(math.floor((360/tumorCount)*i)), player)

                    newTumor:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                    local newTumorSaveManager = SAVE_MANAGER.GetRunSave(newTumor)

                    if not newTumorSaveManager.Resouled_HitCount then
                        newTumorSaveManager.Resouled_HitCount = TUMOR_LEVEL_1.HITS
                    end

                    newTumor:GetData().Resouled_TumorSplit = true
                end
                familiar:Remove()
            end

            ---@param entity Entity
            Resouled.Iterators:IterateOverRoomEntities(function(entity)
                local familiar2 = entity:ToFamiliar()
                if familiar2 and familiar2.Variant == FAMILIAR_VARIANT and familiar2.SubType == FAMILIAR_SUBTYPE then
                    if Resouled:GetDistanceFromHitboxEdge(familiar, familiar2) < 0 then
                        familiar.Velocity = familiar.Velocity + (familiar.Position - familiar2.Position):Normalized()
                    end
                end
                local projectile = entity:ToProjectile()
                if projectile and Resouled:GetDistanceFromHitboxEdge(familiar, projectile) <= 0 then
                    projectile:Die()
                    RUN_SAVE.Resouled_HitCount = RUN_SAVE.Resouled_HitCount + 1
                end
            end)

            local distanceFromPlayer = familiar.Position:Distance(player.Position)
            
            local orbitSize = BASE_ORBIT_DISTANCE + (ORBIT_SIZE_TO_ADD_PER_TUMOR * tumorBallCount)
            local orbitRadiusOffset = (ORBIT_SIZE_TO_ADD_PER_TUMOR * (tumorBallCount/2))

            if distanceFromPlayer > orbitSize then
                familiar.Velocity = familiar.Velocity + (player.Position - familiar.Position):Normalized()
            end

            if distanceFromPlayer <= orbitSize + orbitRadiusOffset then
                familiar.Velocity = familiar.Velocity + (familiar.Position - player.Position):Normalized():Rotated(90) + (player.Velocity * PLAYER_FOLLOW_VELOCITY_SPEED)
            end

            if distanceFromPlayer < orbitSize - orbitRadiusOffset then
                familiar.Velocity = familiar.Velocity + (familiar.Position - player.Position):Normalized() * AVOID_SPEED
            end

            familiar.Velocity = familiar.Velocity * VELOCITY_MULTIPLIER
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_UPDATE, preFamiliarUpdate, FAMILIAR_VARIANT)

local function postNewRoom()
    ---@param familiar EntityFamiliar
    Resouled.Iterators:IterateOverRoomFamiliars(function(familiar)
        if familiar.Variant == FAMILIAR_VARIANT and familiar.SubType == FAMILIAR_SUBTYPE then
            familiar:GetData().Resouled_TumorSplit = nil
        end
    end)
end
Resouled:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, postNewRoom)

local function postNewFloor()
    ---@param player EntityPlayer
    Resouled.Iterators:IterateOverPlayers(function(player)
        local RUN_SAVE = SAVE_MANAGER.GetRunSave(player)
        if RUN_SAVE.Resouled_ExtraTumors then
            RUN_SAVE.Resouled_ExtraTumors = math.floor(RUN_SAVE.Resouled_ExtraTumors/TUMOR_LOSS_PER_FLOOR)
        end
        player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS, true)
    end)
end
Resouled:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, postNewFloor)