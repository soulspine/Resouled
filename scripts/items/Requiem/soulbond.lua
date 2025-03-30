local SOULBOND = Isaac.GetItemIdByName("Soulbond")

local DAMAGE_SHARE_AMOUNT = 0.25

local BOND_ENTITY_1_COLOR = Color(5, 5, 5, 0.7)
local BOND_ENTITY_2_COLOR = Color(0.5, 2, 10, 0.7)

local chainSprite = Sprite()
chainSprite:Load("gfx/soulbond_chain.anm2", true)
chainSprite:Play("Idle", true)

local function onRoomEnter()
    if PlayerManager.AnyoneHasCollectible(SOULBOND) then
        local player = Isaac.GetPlayer()
        local data = player:GetData()
        data.ResouledCorrectEnemies = {}
        ---@param entity Entity
        Resouled:IterateOverRoomEntities(function(entity)
            if entity:IsEnemy() then
                table.insert(data.ResouledCorrectEnemies, entity)
            end
        end)
        if #data.ResouledCorrectEnemies > 1 then
            local rng = RNG()
            RNG():SetSeed(Game():GetRoom():GetAwardSeed(), 0)
            local tableIndex = rng:RandomInt(#data.ResouledCorrectEnemies) + 1
            data.enemy1 = data.ResouledCorrectEnemies[tableIndex]
            table.remove(data.ResouledCorrectEnemies, tableIndex)
            Resouled:NewSeed()
            tableIndex = rng:RandomInt(#data.ResouledCorrectEnemies) + 1
            data.enemy2 = data.ResouledCorrectEnemies[tableIndex]
            data.enemy1.Color = BOND_ENTITY_1_COLOR
            data.enemy2.Color = BOND_ENTITY_2_COLOR
            data.enemy1:GetData().ResouledSoulBond = {}
            data.enemy2:GetData().ResouledSoulBond = {}
            data.enemy1:GetData().ResouledSoulBond.IsBonded = true
            data.enemy2:GetData().ResouledSoulBond.IsBonded = true
            data.enemy1:GetData().ResouledSoulBond.Twin = data.enemy2
            data.enemy2:GetData().ResouledSoulBond.Twin = data.enemy1
            data.enemy1:GetData().ResouledSoulBond.Color = BOND_ENTITY_1_COLOR
            data.enemy2:GetData().ResouledSoulBond.Color = BOND_ENTITY_2_COLOR
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, onRoomEnter)

---@param entity Entity
---@param amount integer
---@param source EntityRef
local function npcTakeDamage(_, entity, amount, source)
    local player = Isaac.GetPlayer()
    local playerData = player:GetData()
    local data = entity:GetData()
    if data.ResouledSoulBond then
        if data.ResouledSoulBond.IsBonded and data.ResouledSoulBond.Twin and not data.ResouledSoulBond.DontTakeDamage then
            if data.ResouledSoulBond.Twin.HitPoints > 0 then --Game would error without this
                data.ResouledSoulBond.Twin:GetData().ResouledSoulBond.DontTakeDamage = true
                data.ResouledSoulBond.Twin:TakeDamage(DAMAGE_SHARE_AMOUNT * amount, DamageFlag.DAMAGE_DEVIL, EntityRef(entity), 0)
            else
                data.ResouledSoulBond.Twin = nil
            end

            if entity.HitPoints - amount <= 0 and data.ResouledSoulBond.Twin then
                local ghost = Game():Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PURGATORY, entity.Position, Vector.Zero, nil, 1, entity.InitSeed)
                ghost.Target = data.ResouledSoulBond.Twin
                ghost.Color = data.ResouledSoulBond.Color
                playerData.enemy1 = nil
                playerData.enemy2 = nil
            end
        end

        if data.ResouledSoulBond.DontTakeDamage then
            data.ResouledSoulBond.DontTakeDamage = false
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, npcTakeDamage)

local function onRender()
    if PlayerManager.AnyoneHasCollectible(SOULBOND) then
        local player = Isaac.GetPlayer()
        local data = player:GetData()
        if data.enemy1 and data.enemy2 then
            local chain
            if not data.ResouledChain then
                chain = data.ResouledChain
            end
            
            if not chain then
                data.ResouledChain = Beam(chainSprite, 0, false, false)
                chain = data.ResouledChain
            end
            
            chain:Add(Isaac.WorldToScreen(data.enemy1.Position), 0)
            chain:Add(Isaac.WorldToScreen(data.enemy2.Position), 64)

            chain:Render()
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_RENDER, onRender)