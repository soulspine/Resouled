local SOULBOND = Isaac.GetItemIdByName("Soulbond")

local e = Resouled.EID

if EID then
    EID:addCollectible(SOULBOND,
    e:AutoIcons("Creates a bond between 2 enemies # There can be more than one bond # Bond shares 25% of the damage taken"))
end

local DAMAGE_SHARE = 0.25

local BEAM_SPRITE_MIN = 0
local BEAM_SPRITE_MAX = 64

local EFFECT_VARIANT = Isaac.GetEntityVariantByName("Chain Particle")
local EFFECT_SUBTYPE = Isaac.GetEntitySubTypeByName("Chain Particle")
local CHAIN_PARTICLES_SPAWN_CHANCE_ON_BREAK_PER_POINT = 0.33
local SPAWN_HEIGHT = 15
local SPEED_UPWARD = 10
local WEIGHT = 0.4
local BOUNCINESS = 0.5
local FRICTION = 0.75
local SPEED_MAX = 20
local SPEED_MIN = 10

---@param position Vector
local function spawnChainParticles(position)
    for _ = 1, math.random(2, 6) do
        Resouled:SpawnPrettyParticles(EFFECT_VARIANT, EFFECT_SUBTYPE, math.random(SPEED_MIN, SPEED_MAX), SPEED_UPWARD, 0, 90, position, SPAWN_HEIGHT, nil, nil, WEIGHT, BOUNCINESS, FRICTION, GridCollisionClass.COLLISION_SOLID)
    end
end

local hitSounds = {
    [1] = Isaac.GetSoundIdByName("Soulbond1"),
    [2] = Isaac.GetSoundIdByName("Soulbond2"),
    [3] = Isaac.GetSoundIdByName("Soulbond3")
}

local function playHitSound()
    local randomNum = math.random(3)
    SFXManager():Play(hitSounds[randomNum])
end

local PITCH = 3

local chainSprite = Sprite()
chainSprite:Load("gfx/soulbond_chain.anm2", true)
chainSprite:Play("Idle", true)

local chainLockSprite = Sprite()
chainLockSprite:Load("gfx/soulbond_chain_2.anm2", true)
chainLockSprite:Play("Idle", true)


local TARGET_BONDS_COUNT = function(enemyCount)
    return math.max(math.floor(enemyCount / 4), 1)
end

---@param entity1 EntityRef
---@param entity2 EntityRef
local function createBond(entity1, entity2)
    SFXManager():Play(SoundEffect.SOUND_CHAIN_LOOP, nil, nil, nil, PITCH)

    local data1 = entity1.Entity:GetData()
    local data2 = entity2.Entity:GetData()
    data1.ResouledSoulbond = {
        Other = entity2,
        Beam = Beam(chainSprite, 0, false, false),
    }
    data1.ResouledSoulbondBlock = true
    data2.ResouledSoulbond = {
        Other = entity1,
    }
    data2.ResouledSoulbondBlock = true
end

---@param entity Entity
local function checkBondedTwin(entity)
    local data = entity:GetData()
    if data.ResouledSoulbond then
        ---@type Entity
        local x = data.ResouledSoulbond.Other.Entity
        if x.HitPoints <= 0 or not x:IsActiveEnemy(false) or not x:IsVulnerableEnemy() then
            return false
        end
        return true
    end
end

---@param entity Entity
local function destroyBond(entity)
    local data = entity:GetData()
    local other = data.ResouledSoulbond.Other.Entity
    local currentPos = entity.Position
    local otherPos = other.Position
    local dirVector = (otherPos - currentPos):Normalized() * (BEAM_SPRITE_MAX/5)
    local dirVectorLength = dirVector:Length()
    local distance = currentPos:Distance(otherPos)
    local pointPos = currentPos
    while distance - dirVectorLength > dirVectorLength do
        local randomNum = math.random()
        if randomNum < CHAIN_PARTICLES_SPAWN_CHANCE_ON_BREAK_PER_POINT then
            spawnChainParticles(pointPos)
        end
            
        pointPos = pointPos + dirVector
        distance = distance - dirVectorLength
    end

    spawnChainParticles(currentPos) spawnChainParticles(otherPos)
    SFXManager():Play(SoundEffect.SOUND_CHAIN_BREAK, nil, nil, nil, PITCH)

    data.ResouledSoulbond = nil
    other:GetData().ResouledSoulbond = nil
end

local function onUpdate()
    if PlayerManager.AnyoneHasCollectible(SOULBOND) then
        local bondedEnemies = 0
        local totalEnemies = 0
        local bindableEnemies = {}
        ---@param entity Entity
        Resouled.Iterators:IterateOverRoomEntities(function(entity)
            if entity:IsVulnerableEnemy() and entity:IsActiveEnemy() and entity:IsEnemy() then
                totalEnemies = totalEnemies + 1
                local data = entity:GetData()
                if data.ResouledSoulbond then
                    bondedEnemies = bondedEnemies + 1
                elseif not data.ResouledSoulbondBlock then
                    table.insert(bindableEnemies, EntityRef(entity))
                end
            end
        end)
        local targetbondedEnemies = TARGET_BONDS_COUNT(totalEnemies) * 2

        if targetbondedEnemies > bondedEnemies and #bindableEnemies > 1 then
            local enemyIndex1 = math.random(1, #bindableEnemies)
            local enemy1 = bindableEnemies[enemyIndex1]
            table.remove(bindableEnemies, enemyIndex1)
            local enemy2 = bindableEnemies[math.random(1, #bindableEnemies)]
            createBond(enemy1, enemy2)
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_UPDATE, onUpdate)

---@param npc EntityNPC
local function onNpcUpdate(_, npc)
    local data = npc:GetData()
    if data.ResouledSoulbond then
        if not checkBondedTwin(npc) then
            destroyBond(npc)
        end
    elseif not data.ResouledSoulbond and data.ResouledSoulBondBlock then
        data.ResouledSoulBondBlock = nil
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, onNpcUpdate)

---@param npc EntityNPC
---@param offset Vector
local function onNpcRender(_, npc, offset)
    local data = npc:GetData()
    if data.ResouledSoulbond then
        ---@type Entity
        local other = data.ResouledSoulbond.Other.Entity
        
        --Get the positions
        local currentPos = npc.Position
        local otherPos = other.Position
        --Apply the sprite offset
        currentPos = currentPos + npc.SpriteOffset + Vector(0, -(npc.Size/2))
        otherPos = otherPos + other.SpriteOffset + Vector(0, -(other.Size/2))
        if data.ResouledSoulbond.Beam then
            ---@type Beam
            local beam = data.ResouledSoulbond.Beam
            
            local dirVector = (otherPos - currentPos):Normalized() * BEAM_SPRITE_MAX
            local dirVectorLength = dirVector:Length()
            local distance = currentPos:Distance(otherPos)
            local pointPos = currentPos
            
            while distance - dirVectorLength > dirVectorLength do
                beam:Add(Isaac.WorldToScreen(pointPos), BEAM_SPRITE_MIN)
                beam:Add(Isaac.WorldToScreen(pointPos + dirVector), math.floor(pointPos:Distance(pointPos + dirVector)/2))
                
                pointPos = pointPos + dirVector
                distance = distance - dirVectorLength
            end
            
            beam:Add(Isaac.WorldToScreen(pointPos), BEAM_SPRITE_MIN)
            beam:Add(Isaac.WorldToScreen(otherPos), math.floor(pointPos:Distance(otherPos)/2))
            
            beam:Render()
        end

        chainLockSprite:Render(Isaac.WorldToScreen(currentPos))

    end

    if data.Resouled_NewAlpha then
        npc:SetColor(Color(npc.Color.R, npc.Color.G, npc.Color.B, data.Resouled_NewAlpha), 2, 1, false, true)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, onNpcRender)

---@param entity Entity
---@param amount integer
---@param damageFlags DamageFlag
---@param source EntityRef
---@param countdown integer
local function npcTakeDamage(_, entity, amount, damageFlags, source, countdown)
    local data = entity:GetData()
    if damageFlags | DamageFlag.DAMAGE_FAKE ~= 0 and data.ResouledSoulbond and not data.ResouledSoulbond.Damage then
        ---@type Entity
        local other = data.ResouledSoulbond.Other.Entity
        local otherData = other:GetData()
        if otherData.ResouledSoulbond then
            otherData.ResouledSoulbond.Damage = true
            other:TakeDamage(amount * DAMAGE_SHARE, damageFlags, source, countdown)
            if otherData.ResouledSoulbond then --Would error if entity died there
                otherData.ResouledSoulbond.Damage = nil
            end

            playHitSound()
        end
        
        local newAlpha = (1 - (entity.HitPoints / entity.MaxHitPoints))/2
        local newAlphaOther = (1 - (other.HitPoints / other.MaxHitPoints))/2

        data.Resouled_NewAlpha = 1 - newAlpha
        otherData.Resouled_NewAlpha = 1 - newAlphaOther
    end

    if data.ResouledSoulbond and entity.HitPoints - amount <= 0 then
        destroyBond(entity)
    end
end
Resouled:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, npcTakeDamage)

---@param itemConfig ItemConfigItem
---@param player EntityPlayer
local function preAddCostume(_, itemConfig, player)
    if itemConfig:IsCollectible() and itemConfig.ID == SOULBOND and player:GetPlayerType() == PlayerType.PLAYER_THELOST_B then
        return true
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_PLAYER_ADD_COSTUME, preAddCostume)