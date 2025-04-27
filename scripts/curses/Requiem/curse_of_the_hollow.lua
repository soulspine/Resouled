local mapId = Resouled.CursesMapId[Resouled.Curses.CURSE_OF_THE_HOLLOW]

MinimapAPI:AddMapFlag(
    mapId,
    function()
        return Resouled:CustomCursePresent(Resouled.Curses.CURSE_OF_THE_HOLLOW)
    end,
    Resouled.CursesSprite,
    mapId,
    1
)

local SCREEN_SHAKE = 25
local DARKNESS_TIMEOUT = 100
local DARKNESS_STRENGTH = 1
local CURSE_SOUND = SoundEffect.SOUND_MOM_VOX_EVILLAUGH

local function postNewRoom()
    if Resouled:CustomCursePresent(Resouled.Curses.CURSE_OF_THE_HOLLOW) then
        local room = Game():GetRoom()
        local type = room:GetType()
        if room:IsFirstVisit() then
            if type == RoomType.ROOM_DEFAULT or type == RoomType.ROOM_BOSS or type == RoomType.ROOM_MINIBOSS then
            else
                local curseActivationChance = 0.15 + (0.025 * Resouled:GetPossessedSoulsNum())

                local rng = RNG()

                rng:SetSeed(room:GetAwardSeed())

                local randomNum = rng:RandomFloat()
                
                if randomNum < curseActivationChance then
                    ---@param entity Entity
                    Resouled:IterateOverRoomEntities(function(entity)
                        if entity.Type ~= EntityType.ENTITY_PLAYER then
                            if entity.SpawnerEntity then
                                if entity.SpawnerEntity.Type == EntityType.ENTITY_PLAYER then
                                else
                                    entity:Remove()
                                    Game():ShakeScreen(SCREEN_SHAKE)
                                    Game():Darken(DARKNESS_STRENGTH, DARKNESS_TIMEOUT)
                                    SFXManager():Play(CURSE_SOUND)
                                end
                            else
                                entity:Remove()
                                Game():ShakeScreen(SCREEN_SHAKE)
                                Game():Darken(DARKNESS_STRENGTH, DARKNESS_TIMEOUT)
                                SFXManager():Play(CURSE_SOUND)
                            end
                        end
                    end)
                end
            end
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, postNewRoom)