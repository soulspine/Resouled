local function curseActive()
    return Resouled:ActiveBuffPresent(Resouled.Buffs.KRAMPUS_CHRISTMAS) or Resouled:IsSpecialSeedEffectActive(Resouled.SpecialSeedEffects.EverythingIsCursed)
end

---@return RoomConfigRoom
local function randomKrampusRoom(seed)
    local x = 2300 + RNG(seed):RandomInt(7)
    local roomDesc = RoomConfig.GetRandomRoom(1, false, StbType.SPECIAL_ROOMS, RoomType.ROOM_MINIBOSS, RoomShape.ROOMSHAPE_1x1, x, x, nil, nil, nil, RoomSubType.MINIBOSS_KRAMPUS)

    return roomDesc
end

local sheol = XMLData.GetEntryById(XMLNode.BACKDROP, 14)

local GRID_FIX_GFX = {
    [GridEntityType.GRID_ROCK] = "gfx/grid/"..sheol.rocks,
    [GridEntityType.GRID_ROCKB] = "gfx/grid/"..sheol.rocks,
    [GridEntityType.GRID_ROCKT] = "gfx/grid/"..sheol.rocks,
    [GridEntityType.GRID_PIT] = "gfx/grid/"..sheol.pit,
    [GridEntityType.GRID_ROCK_ALT] = "gfx/grid/"..sheol.rocks,
    [GridEntityType.GRID_ROCK_ALT2] = "gfx/grid/"..sheol.rocks,
    [GridEntityType.GRID_ROCK_BOMB] = "gfx/grid/"..sheol.rocks,
    [GridEntityType.GRID_ROCK_GOLD] = "gfx/grid/"..sheol.rocks,
    [GridEntityType.GRID_ROCK_SPIKED] = "gfx/grid/"..sheol.rocks,
    [GridEntityType.GRID_ROCK_SS] = "gfx/grid/"..sheol.rocks
}

local CHANCE = 1/2
local SPRITESHEET = "gfx/grid/door_07_devilroomdoor.png"
local TARGET = "gfx/grid/door_01_normaldoor.png"


local fix = false

local function fixDoors()
    local room = Game():GetRoom()
    for i = 0, DoorSlot.NUM_DOOR_SLOTS - 1 do
        local door = room:GetDoor(i)
    
        if door then
            local sprite = door:GetSprite()
                
            for j = 0, sprite:GetLayerCount() - 1 do
                local layer = sprite:GetLayer(j)
                if layer then
                    if layer:GetSpritesheetPath():find(TARGET) then
                        sprite:ReplaceSpritesheet(j, SPRITESHEET, false)
                    end

                    if j == 3 then layer:SetPos(layer:GetPos() + Vector(0, -2)) end
                end
            end
            sprite:LoadGraphics()
        end
    end
end

local function fixGrid()
    ---@param gEn GridEntity
    Resouled.Iterators:IterateOverGridEntities(function(gEn)
        local type = gEn:GetType()
        if GRID_FIX_GFX[type] then
            local sprite = gEn:GetSprite()
            for i = 0, sprite:GetLayerCount() - 1 do
                if sprite:GetLayer(i):GetSpritesheetPath() ~= GRID_FIX_GFX[type] then
                    sprite:ReplaceSpritesheet(i, GRID_FIX_GFX[type], false)
                end
            end
            sprite:LoadGraphics()
        end
    end)
end

local function fixSounds()
    if SFXManager():IsPlaying(SoundEffect.SOUND_CHOIR_UNLOCK) then
        SFXManager():Stop(SoundEffect.SOUND_CHOIR_UNLOCK)
        SFXManager():Play(SoundEffect.SOUND_SATAN_ROOM_APPEAR)
    end
end

local function replaceDealWithKrampus()
    local level = Game():GetLevel()
    
    level:InitializeDevilAngelRoom(false, false)

    local room = level:GetRoomByIdx(GridRooms.ROOM_DEVIL_IDX)

    if room.Data.Type == RoomType.ROOM_DEVIL then
        local desc = randomKrampusRoom(room.SpawnSeed)
        
        room.Data = desc
        
        local save = Resouled.SaveManager.GetRoomFloorSave(nil, nil, room.ListIndex)
        
        save.Krampus_Christmas = true

        fix = true
    end
end

local function postNewRoom()
    if not curseActive() then return end
    local room = Game():GetLevel():GetCurrentRoomDesc()
    local save = Resouled.SaveManager.GetRoomFloorSave(nil, nil, room.ListIndex)
    local room1 = Game():GetRoom()

    if save.Krampus_Christmas then
        room1:SetBackdropType(BackdropType.SHEOL, 1)
        fixDoors()
        fixGrid()
    end

    if room.Data.Type == RoomType.ROOM_BOSS then
        fixDoors()
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, postNewRoom)

local function clearAward()
    if not curseActive() then return end
    if Game():GetLevel():GetCurrentRoomDesc().Data.Type == RoomType.ROOM_BOSS and fix then
        fixDoors()

        fixSounds()

        fix = false
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_ROOM_TRIGGER_CLEAR, clearAward)

local function preClearAward()
    if not curseActive() then return end
    if Game():GetLevel():GetCurrentRoomDesc().Data.Type == RoomType.ROOM_BOSS then
        if Game():GetLevel():GetDevilAngelRoomRNG():PhantomFloat() < CHANCE then
            replaceDealWithKrampus()
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_ROOM_TRIGGER_CLEAR, preClearAward)

Resouled:AddBuffToRemoveOnRunEnd(Resouled.Buffs.KRAMPUS_CHRISTMAS)