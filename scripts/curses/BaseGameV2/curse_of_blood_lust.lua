local TIME_BEFORE_TAKING_DAMAGE = 45 * 30

local mapId = Resouled.CursesMapId[Resouled.Curses.CURSE_OF_BLOOD_LUST]

local ANIMATION_FRAME_NUM = 46

local cachedTimer = 0

MinimapAPI:AddMapFlag(
    mapId,
    function()
        return Resouled:CustomCursePresent(Resouled.Curses.CURSE_OF_BLOOD_LUST)
    end,
    Resouled.CursesSprite,
    mapId,
    function()
        return cachedTimer
     end
)


local function onUpdate()
    local FLOOR_SAVE_MANAGER = SAVE_MANAGER.GetFloorSave()
    
    if Resouled:CustomCursePresent(Resouled.Curses.CURSE_OF_BLOOD_LUST) and not FLOOR_SAVE_MANAGER.ResouledCurseOfBloodLustTimer then
        FLOOR_SAVE_MANAGER.ResouledCurseOfBloodLustTimer = TIME_BEFORE_TAKING_DAMAGE
    elseif not Resouled:CustomCursePresent(Resouled.Curses.CURSE_OF_BLOOD_LUST) and FLOOR_SAVE_MANAGER.ResouledCurseOfBloodLustTimer then
        FLOOR_SAVE_MANAGER.ResouledCurseOfBloodLustTimer = nil
    end
    
    if FLOOR_SAVE_MANAGER.ResouledCurseOfBloodLustTimer then
        if FLOOR_SAVE_MANAGER.ResouledCurseOfBloodLustTimer > 0 then
            FLOOR_SAVE_MANAGER.ResouledCurseOfBloodLustTimer = FLOOR_SAVE_MANAGER.ResouledCurseOfBloodLustTimer - 1
        end
        if FLOOR_SAVE_MANAGER.ResouledCurseOfBloodLustTimer <= 0  then
            ---@param player EntityPlayer
            Resouled:IterateOverPlayers(function(player)
                player:TakeDamage(1, DamageFlag.DAMAGE_COUNTDOWN, EntityRef(player), 0)
            end)
            FLOOR_SAVE_MANAGER.ResouledCurseOfBloodLustTimer = TIME_BEFORE_TAKING_DAMAGE / 2
        end
        cachedTimer = (FLOOR_SAVE_MANAGER.ResouledCurseOfBloodLustTimer + FLOOR_SAVE_MANAGER.ResouledCurseOfBloodLustTimer//30)//30 --not FLOOR_SAVE_MANAGER.ResouledCurseOfBloodLustTimer//30 because frame 46 wouldn't appear
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_UPDATE, onUpdate)

---@param npc EntityNPC
local function postNpcDeath(_, npc)
    local FLOOR_SAVE_MANAGER = SAVE_MANAGER.GetFloorSave()
    if FLOOR_SAVE_MANAGER.ResouledCurseOfBloodLustTimer then
        if npc.Type ~= EntityType.ENTITY_PLAYER and npc:IsEnemy() and npc:IsActiveEnemy(true) then
            FLOOR_SAVE_MANAGER.ResouledCurseOfBloodLustTimer = TIME_BEFORE_TAKING_DAMAGE
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, postNpcDeath)