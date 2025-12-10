local SiblingRivalry = {
    ID = Resouled.Enums.Items.SIBLING_RIVALRY,

    ChanceToGetAngry = 0.05,
    AngryChanceRate = 30,

    Damage = 5,
    Knockback = 20,

    HitRangeMultiplier = 1.5,
    AdditionalRange = 20,
}

local shader = "shaders_resouled/sibling_rivalry/shader"

---@param npc EntityNPC
local function tryMakeAngry(npc)
    ---@type EntityNPC | nil
    local nearest = nil
    ---@param npc2 EntityNPC
    Resouled.Iterators:IterateOverRoomNpcs(function(npc2)
        if npc2.Type == npc.Type and Resouled:IsValidEnemy(npc2) and npc2.Index ~= npc.Index then
            if not nearest then
                nearest = npc2
            else
                if nearest.Position:Distance(npc.Position) > npc2.Position:Distance(npc.Position) then
                    nearest = npc2
                end
            end
        end
    end)

    if nearest then
        npc.Target = nearest
        npc:GetData().Resouled_SiblingRivalryAngry = true
    end
end

---@param npc EntityNPC
---@return boolean
local function checkAngry(npc)
    local data = npc:GetData()
    if not data.Resouled_SiblingRivalryAngry or not npc.Target or (npc.Target.Type ~= npc.Type and data.Resouled_SiblingRivalryAngry) or npc:IsDead() or npc.HitPoints <= 0 then
        data.Resouled_SiblingRivalryAngry = nil
        return false
    end
    return true
end

---@param npc EntityNPC
local function tryPunch(npc)
    if not npc.Target then return end
    if Resouled:GetDistanceFromHitboxEdge(npc, npc.Target) - SiblingRivalry.AdditionalRange <= 0 then
        npc.Target:TakeDamage(SiblingRivalry.Damage, DamageFlag.DAMAGE_NO_MODIFIERS, EntityRef(npc), 0)

        npc.Target.Velocity = npc.Target.Velocity + (npc.Target.Position - npc.Position):Resized(SiblingRivalry.Knockback)

        npc:GetData().Resouled_SiblingRivalryAngry = nil
        npc.Target = nil
    end
end

---@param npc EntityNPC
local function onNpcUpdate(_, npc)
    if not PlayerManager.AnyoneHasCollectible(SiblingRivalry.ID) or not Resouled:IsValidEnemy(npc) then return end

    local angry = checkAngry(npc)
    if not angry and npc.FrameCount % SiblingRivalry.AngryChanceRate == 0 and math.random() < SiblingRivalry.ChanceToGetAngry then
        tryMakeAngry(npc)
        return
    end

    local sprite = npc:GetSprite()

    if angry then
        if not sprite:HasCustomShader(shader) then
            sprite:SetCustomShader(shader)
        end

        tryPunch(npc)
    else
        if sprite:HasCustomShader(shader) then
            sprite:ClearCustomShader()
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_NPC_UPDATE, onNpcUpdate)

---@param entity Entity
local function entityTakeDMG(_, entity, amount)
    local npc = entity:ToNPC()
    if not npc then return end
    if npc.HitPoints - amount <= 0 then
        if checkAngry(npc) then
            npc:GetSprite():ClearCustomShader()
            npc:GetData().Resouled_SiblingRivalryAngry = nil
            npc.Target = nil
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, entityTakeDMG)