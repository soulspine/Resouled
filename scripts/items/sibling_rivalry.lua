local SiblingRivalry = {
    ID = Isaac.GetItemIdByName("Sibling Rivalry"),

    ChanceToGetAngry = 0.05,
    AngryChanceRate = 30,

    Damage = 10,
    Knockback = 50,

    HitRangeMultiplier = 1.5,
    AdditionalRange = 16,
}

local e = Resouled.EID

if EID then
    EID:addCollectible(SiblingRivalry.ID, e:AutoIcons("Has a "..tostring(SiblingRivalry.ChanceToGetAngry*100).."% chance to make a random enemy angry # Angey enemies target a random other enemy of the same type # If the enemy gets close it punches the targeted enemy for "..tostring(SiblingRivalry.Damage).." damage and applies huge knockback"))
end

---@param npc EntityNPC
local function makeAngry(npc)
    local validEnemies = {}

    ---@param npc2 EntityNPC
    Resouled.Iterators:IterateOverRoomNpcs(function(npc2)
        if npc2.Index ~= npc.Index and npc2.Type == npc.Type and not npc2:IsBoss() then
            table.insert(validEnemies, EntityRef(npc2))
        end
    end)

    if #validEnemies > 0 then
        local data = npc:GetData()
        
        ---@type EntityRef
        data.Resouled_SiblingRivalryAngryTarget = validEnemies[math.random(#validEnemies)]
    end
end

---@param npc EntityNPC
local function clearTarget(npc)
    local data = npc:GetData()
    if data.Resouled_SiblingRivalryAngryTarget then
        data.Resouled_SiblingRivalryAngryTarget = nil

        npc.Target = npc:GetPlayerTarget()
    end
end

---@param npc EntityNPC
local function checkTarget(npc)
    local data = npc:GetData()
    ---@return EntityRef | nil
    local target = data.Resouled_SiblingRivalryAngryTarget
    if target then
        ---@type Entity | nil
        local targetE = target.Entity
        if targetE then
            if targetE:IsDead() or targetE.HitPoints <= 0 then
                clearTarget(npc)
            end
        else
            clearTarget(npc)
        end
    end
end

---@param npc EntityNPC
---@return EntityRef | nil
local function getTarget(npc)
    return npc:GetData().Resouled_SiblingRivalryAngryTarget
end

---@param npc EntityNPC
local function isNearTarget(npc)
    local target = getTarget(npc)
    if target then
        return target.Entity.Position:Distance(npc.Position) <= npc.Size * SiblingRivalry.HitRangeMultiplier + SiblingRivalry.AdditionalRange
    end
end

local function hitTarget(npc)
    local target = getTarget(npc)
    if target then
        target.Entity:TakeDamage(SiblingRivalry.Damage, DamageFlag.DAMAGE_NO_MODIFIERS, EntityRef(npc), 0)

        target.Entity:AddVelocity((target.Entity.Position - npc.Position):Normalized() * SiblingRivalry.Knockback)

        clearTarget(npc)
    end
end

---@param npc EntityNPC
local function onNpcUpdate(_, npc)
    local target = getTarget(npc)

    if not target and npc.FrameCount % SiblingRivalry.AngryChanceRate == 0 and not npc:IsBoss() and npc:IsActiveEnemy() and math.random() < SiblingRivalry.ChanceToGetAngry and PlayerManager.AnyoneHasCollectible(SiblingRivalry.ID) then
        makeAngry(npc)
    end

    if target then
        local color = npc.Color
        npc:SetColor(Color(color.R, color.G, color.B, color.A, color.RO + 1, color.GO, color.BO), 2, 1, false, true)

        npc.Target = target.Entity

        if isNearTarget(npc) then
            hitTarget(npc)
        end

        checkTarget(npc)
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, onNpcUpdate)