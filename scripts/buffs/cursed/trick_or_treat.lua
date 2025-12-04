local HEALTH_BOOST = 1.1125

local function curseActive()
    return Resouled:ActiveBuffPresent(Resouled.Buffs.TRICK_OR_TREAT) or Resouled:IsSpecialSeedEffectActive(Resouled.SpecialSeedEffects.EverythingIsCursed)
end

local rng = RNG()

---@param seed integer
---@return string
local function trickOrTreat(seed)
    rng:SetSeed(seed)
    if rng:RandomInt(2) == 1 then
        return "Trick"
    end
    return "Treat"
end

---@param room Room
---@param desc RoomDescriptor
local function preNewRoom(_, room, desc)
    if not curseActive() then return end
    local save = Resouled.SaveManager.GetRoomFloorSave()
    if save.Trick_or_Treat then return end
    save.Trick_or_Treat = trickOrTreat(desc.AwardSeed)
end
Resouled:AddCallback(ModCallbacks.MC_PRE_NEW_ROOM, preNewRoom)

---@param npc EntityNPC
local function onNpcInit(_, npc)
    if not curseActive() or not (npc:IsEnemy() and npc:IsActiveEnemy()) then return end
    local save = Resouled.SaveManager.GetRoomFloorSave()
    if save.Trick_or_Treat == "Treat" then
        npc.MaxHitPoints = npc.MaxHitPoints * HEALTH_BOOST
        npc.HitPoints = npc.MaxHitPoints
    end
end
Resouled:AddPriorityCallback(ModCallbacks.MC_POST_NPC_INIT, CallbackPriority.IMPORTANT, onNpcInit)

---@param player EntityPlayer
---@param damage number
---@param flags DamageFlag
---@param source EntityRef
---@param iFrames integer
local function prePlayerTakeDMG(_, player, damage, flags, source, iFrames)
    local npc = source and source.Entity and source.Entity:ToNPC()
    if not curseActive() or damage > 1 or not (npc and npc:IsActiveEnemy() and npc:IsEnemy()) then return end

    player:TakeDamage(math.max(damage, 2), flags, source, iFrames)
    return false
end
Resouled:AddCallback(ModCallbacks.MC_PRE_PLAYER_TAKE_DMG, prePlayerTakeDMG)

Resouled:AddBuffToRemoveOnRunEnd(Resouled.Buffs.TRICK_OR_TREAT)