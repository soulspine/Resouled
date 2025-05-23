local mapId = Resouled.CursesMapId[Resouled.Curses.CURSE_OF_FATIGUE]

local cachedIndicatorFrame = 0

MinimapAPI:AddMapFlag(
    mapId,
    function()
        return Resouled:CustomCursePresent(Resouled.Curses.CURSE_OF_FATIGUE)
    end,
    Resouled.CursesSprite,
    mapId,
    function()
        return cachedIndicatorFrame
    end
)

local function onUpdate()
    local FLOOR_SAVE_MANAGER = SAVE_MANAGER.GetFloorSave()
    if (Resouled:CustomCursePresent(Resouled.Curses.CURSE_OF_FATIGUE)) then
        if not FLOOR_SAVE_MANAGER.ResouledCurseOfFatigue then
            FLOOR_SAVE_MANAGER.ResouledCurseOfFatigue = 0
            cachedIndicatorFrame = 0
        end
    else
        if FLOOR_SAVE_MANAGER.ResouledCurseOfFatigue then
            FLOOR_SAVE_MANAGER.ResouledCurseOfFatigue = nil
        end        

        Resouled.Iterators:IterateOverPlayers(function(player)
            local playerData = player:GetData()
            if playerData.ResouledCurseOfFatigue then
                playerData.ResouledCurseOfFatigue = nil
            end
        end)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_UPDATE, onUpdate)

---@param entity Entity
---@param amount number
---@param flags integer
---@param source EntityRef
---@param countdown integer
local function onPlayerHit(_, entity, amount, flags, source, countdown)
    local entityData = entity:GetData()
    if entity.Type == EntityType.ENTITY_PLAYER and Resouled:CustomCursePresent(Resouled.Curses.CURSE_OF_FATIGUE) then
        local FLOOR_SAVE_MANAGER = SAVE_MANAGER.GetFloorSave()
        FLOOR_SAVE_MANAGER.ResouledCurseOfFatigue = 1
        cachedIndicatorFrame = FLOOR_SAVE_MANAGER.ResouledCurseOfFatigue
    end
end
Resouled:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, onPlayerHit, EntityType.ENTITY_PLAYER)

---@param player EntityPlayer
local function prePlayerUpdate(_, player)
    local FLOOR_SAVE_MANAGER = SAVE_MANAGER.GetFloorSave()
    local playerData = player:GetData()
    if Resouled:CustomCursePresent(Resouled.Curses.CURSE_OF_FATIGUE) then
        if not playerData.ResouledCurseOfFatigue then
            playerData.ResouledCurseOfFatigue = {}
        end

        for i = 0, 3 do
            playerData.ResouledCurseOfFatigue[i] = player:GetActiveCharge(i)
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_PLAYER_UPDATE, prePlayerUpdate)

local function preClearReward()
    if Resouled:CustomCursePresent(Resouled.Curses.CURSE_OF_FATIGUE) then
        local FLOOR_SAVE_MANAGER = SAVE_MANAGER.GetFloorSave()

        if FLOOR_SAVE_MANAGER.ResouledCurseOfFatigue == 1 then
            ---@param player EntityPlayer
            Resouled.Iterators:IterateOverPlayers(function(player)
                for i = 0, 3 do
                    if player:GetActiveCharge(i) ~= player:GetData().ResouledCurseOfFatigue[i] then
                        player:SetActiveCharge(player:GetActiveCharge(i)-1, i)
                    end
                end
            end)
            
            if SFXManager():IsPlaying(SoundEffect.SOUND_BEEP) then
                SFXManager():Stop(SoundEffect.SOUND_BEEP)
            end
            
            if SFXManager():IsPlaying(SoundEffect.SOUND_BATTERYCHARGE) then
                SFXManager():Stop(SoundEffect.SOUND_BATTERYCHARGE)
            end

            FLOOR_SAVE_MANAGER.ResouledCurseOfFatigue = 0
        end
        cachedIndicatorFrame = FLOOR_SAVE_MANAGER.ResouledCurseOfFatigue
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, preClearReward)