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

local MAX_OFFSET = 50
local CURSE_EFFECT_SPEED = 20
local MIN_PARTICLE_COUNT = 6
local MAX_PARTICLE_COUNT = 12
local MAX_VELOCITY = 6

local SCREEN_SHAKE = 25
local DARKNESS_TIMEOUT = 100
local DARKNESS_STRENGTH = 1
local CURSE_SOUND = SoundEffect.SOUND_MOM_VOX_EVILLAUGH
local BASE_REMOVE_CHANCE = 0.15
local REMOVE_CHANCE_PER_SOUL = 0.0075

local function postNewRoom()
    if Resouled:CustomCursePresent(Resouled.Curses.CURSE_OF_THE_HOLLOW) then
        local room = Game():GetRoom()
        local type = room:GetType()
        if room:IsFirstVisit() then
            if (type == RoomType.ROOM_DEFAULT or type == RoomType.ROOM_BOSS or type == RoomType.ROOM_MINIBOSS) or (room:IsMirrorWorld() and type == RoomType.ROOM_TREASURE) then
            else
                local curseActivationChance = BASE_REMOVE_CHANCE + (REMOVE_CHANCE_PER_SOUL * Resouled:GetPossessedSoulsNum())

                local rng = RNG()

                rng:SetSeed(room:GetAwardSeed())

                local randomNum = rng:RandomFloat()
                
                if randomNum < curseActivationChance then
                    local GRID_SAVE = SAVE_MANAGER.GetRoomSave()
                    GRID_SAVE.Resouled_CurseOfHollow = {}
                    ---@param entity Entity
                    Resouled.Iterators:IterateOverRoomEntities(function(entity)
                        local player = Resouled:TryFindPlayerSpawner(entity)
                        if not player then
                            entity:GetData().Resouled_CurseOfHollow = -math.random(MAX_OFFSET)
                        end
                    end)

                    Resouled.Iterators:IterateOverGridEntities(function(gridEntity, index)
                        if gridEntity:GetType() ~= GridEntityType.GRID_DOOR then
                            GRID_SAVE.Resouled_CurseOfHollow[tostring(index)] = -math.random(MAX_OFFSET)
                        end
                    end)

                    Game():ShakeScreen(SCREEN_SHAKE)
                    Game():Darken(DARKNESS_STRENGTH, DARKNESS_TIMEOUT)
                    SFXManager():Play(CURSE_SOUND)
                end
            end
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, postNewRoom)

---@param pos Vector
local function spawnExplodeEffect(pos, scale)
    for _ = 1, math.random(MIN_PARTICLE_COUNT, MAX_PARTICLE_COUNT) do
        local effect = Game():Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HAEMO_TRAIL, pos + Vector((0.5 - math.random()) * scale, -scale/2 + (0.5 - math.random()) * scale), Vector(1, 0):Rotated(math.random(360)) * math.random() * MAX_VELOCITY, nil, 0, Random())
        effect.Color = Color(0, 0, 0, 1)
    end
end

---@param entity Entity
local function doEntityCurseEffect(_, entity)
    if not Resouled:CustomCursePresent(Resouled.Curses.CURSE_OF_THE_HOLLOW) then return end
    local data = entity:GetData()
    if not data.Resouled_CurseOfHollow then return end

    if entity.EntityCollisionClass ~= EntityCollisionClass.ENTCOLL_NONE then
        entity.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
    end

    if entity.GridCollisionClass ~= EntityGridCollisionClass.GRIDCOLL_NONE then
        entity.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
    end

    local colorMultiplier = math.max(1 - math.max(data.Resouled_CurseOfHollow/CURSE_EFFECT_SPEED, 0), 0)

    entity:SetColor(Color(colorMultiplier, colorMultiplier, colorMultiplier), 2, 10000, false, false)

    data.Resouled_CurseOfHollow = data.Resouled_CurseOfHollow + 1
    if colorMultiplier <= 0 then
        spawnExplodeEffect(entity.Position, entity.Size)
        entity:Remove()
    end
end

---@param entity GridEntity
local function doGridEntityCurseEffect(_, entity)
    if not Resouled:CustomCursePresent(Resouled.Curses.CURSE_OF_THE_HOLLOW) then return end
    local GRID_SAVE = SAVE_MANAGER.GetRoomSave()
    if not GRID_SAVE.Resouled_CurseOfHollow then return end
    local key = tostring(entity:GetGridIndex())
    if not GRID_SAVE.Resouled_CurseOfHollow[key] then return end

    if entity.CollisionClass ~= GridCollisionClass.COLLISION_NONE then
        entity.CollisionClass = GridCollisionClass.COLLISION_NONE
    end

    local colorMultiplier = math.max(1 - math.max(GRID_SAVE.Resouled_CurseOfHollow[key]/CURSE_EFFECT_SPEED, 0), 0)

    local sprite = entity:GetSprite()
    sprite.Color = Color(colorMultiplier, colorMultiplier, colorMultiplier)

    GRID_SAVE.Resouled_CurseOfHollow[key] = GRID_SAVE.Resouled_CurseOfHollow[key] + 1
    if colorMultiplier <= 0 then
        spawnExplodeEffect(entity.Position, 32)
        sprite.Color = Color()
        entity:Destroy()
        GRID_SAVE.Resouled_CurseOfHollow[key] = nil
    end
end

Resouled:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, doEntityCurseEffect)
Resouled:AddCallback(ModCallbacks.MC_POST_PICKUP_RENDER, doEntityCurseEffect)
Resouled:AddCallback(ModCallbacks.MC_POST_BOMB_RENDER, doEntityCurseEffect)
Resouled:AddCallback(ModCallbacks.MC_POST_SLOT_RENDER, doEntityCurseEffect)
Resouled:AddCallback(ModCallbacks.MC_POST_GRID_ENTITY_WEB_RENDER, doGridEntityCurseEffect)
Resouled:AddCallback(ModCallbacks.MC_POST_GRID_ENTITY_DECORATION_RENDER, doGridEntityCurseEffect)
Resouled:AddCallback(ModCallbacks.MC_POST_GRID_ENTITY_FIRE_RENDER, doGridEntityCurseEffect)
Resouled:AddCallback(ModCallbacks.MC_POST_GRID_ENTITY_LOCK_RENDER, doGridEntityCurseEffect)
Resouled:AddCallback(ModCallbacks.MC_POST_GRID_ENTITY_PIT_RENDER, doGridEntityCurseEffect)
Resouled:AddCallback(ModCallbacks.MC_POST_GRID_ENTITY_POOP_RENDER, doGridEntityCurseEffect)
Resouled:AddCallback(ModCallbacks.MC_POST_GRID_ENTITY_PRESSUREPLATE_RENDER, doGridEntityCurseEffect)
Resouled:AddCallback(ModCallbacks.MC_POST_GRID_ENTITY_ROCK_RENDER, doGridEntityCurseEffect)
Resouled:AddCallback(ModCallbacks.MC_POST_GRID_ENTITY_SPIKES_RENDER, doGridEntityCurseEffect)
Resouled:AddCallback(ModCallbacks.MC_POST_GRID_ENTITY_TRAPDOOR_RENDER, doGridEntityCurseEffect)
Resouled:AddCallback(ModCallbacks.MC_POST_GRID_ENTITY_TNT_RENDER, doGridEntityCurseEffect)