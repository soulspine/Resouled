local WiseSkull = Resouled.Stats.WiseSkull

---@param eye1 Color
---@param eye2 Color
---@return table
local function addPresetEyeColors(eye1, eye2)
    local table = {
        [1] = eye1, -- Eye1
        [2] = eye2 -- Eye2
    }
    return table
end

local Shuffle = {
    IDS = {
        Variant = Isaac.GetEntityVariantByName("Shuffle"),
        SubType = Isaac.GetEntitySubTypeByName("Shuffle"),
    },

    IDS_Chosen = {
        Variant = Isaac.GetEntityVariantByName("Shuffle Skull"),
        SubType = Isaac.GetEntitySubTypeByName("Shuffle Skull")
    },

    SkullCount = 8,
    ShufflesCount = 29, -- How many shuffle anims are in anm2

    KeyShuffleCount = 27,

    SkullPos = {
        [1] = Vector(24, 48),
        [2] = Vector(-24, 48),
        [3] = Vector(24, 16),
        [4] = Vector(-24, 16),
        [5] = Vector(24, -16),
        [6] = Vector(-24, -16),
        [7] = Vector(24, -48),
        [8] = Vector(-24, -48),
    },

    SkullColor = {
        [1] = Color(0, 125/255, 255/255),
        [2] = Color(255/255, 255/255, 0),
        [3] = Color(255/255, 0, 255/255),
        [4] = Color(0, 255/255, 175/255),
        [5] = Color(150/255, 255/255, 0),
        [6] = Color(125/255, 0, 255/255),
        [7] = Color(255/255, 0, 0),
        [8] = Color(0, 255/255, 255/255),
    },

    Events = {
        PosUpdate = "UpdateSkullPos",
        Start = "Start"
    },

    SkullSize = 18,

    FlashFadeSpeed = 0.025,

    Music = {
        Tutorial = Isaac.GetMusicIdByName("Limbo Tutorial"),
        ShuffleTheme = Isaac.GetMusicIdByName("Limbo")
    }
}


--KEY SHUFFLE EFFECT

---@param effect EntityEffect
local function onEffectInit(_, effect)
    if effect.SubType == Shuffle.IDS.SubType then

        local sprite = effect:GetSprite()
        local skull = math.random(Shuffle.SkullCount)

        sprite:Play("Start", true)

        local eyes = sprite:GetLayer("Eyes")

        if eyes then
            eyes:SetPos(Shuffle.SkullPos[skull])
        end

        effect:GetData().Resouled_ShuffleMiniGameSkull = {
            CurrentSkull = {CurrentIndex = skull, StartingIndex = skull},
            ShuffleCount = 0,
            SkullPositions = {
                [1] = 1,
                [2] = 2,
                [3] = 3,
                [4] = 4,
                [5] = 5,
                [6] = 6,
                [7] = 7,
                [8] = 8
            }
        }
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, onEffectInit, Shuffle.IDS.Variant)

---@param effect EntityEffect
local function setShuffleEyeColor(effect)
    local sprite = effect:GetSprite()
    local data = effect:GetData()
    for i = 1, Shuffle.SkullCount do

        local layerName = "Eyes"..tostring((data.Resouled_ShuffleMiniGameSkull.CurrentSkull.CurrentIndex + (i - 1))%8 + 1)
        local color = Shuffle.SkullColor[(data.Resouled_ShuffleMiniGameSkull.CurrentSkull.StartingIndex + (i - 1))%8 + 1]

        local eyes = sprite:GetLayer(layerName)
        if eyes then
            eyes:SetColor(color)
        end

        local eyesGlow = sprite:GetLayer("*"..layerName)
        if eyesGlow then
            eyesGlow:SetColor(color)
        end
    end
end

---@param position Vector
---@param seed integer
---@param disappear boolean
---@param correctSkull boolean
local function spawnSkull(color, position, seed, disappear, correctSkull)
    local skull = Game():Spawn(EntityType.ENTITY_EFFECT, Shuffle.IDS_Chosen.Variant, position, Vector.Zero, nil, Shuffle.IDS_Chosen.SubType, seed)

    local sprite = skull:GetSprite()

    if disappear then
        sprite:Play("Disappear", true)
    else
        sprite:Play("ChosenSkull", true)
    end

    if not correctSkull then
        local key = sprite:GetLayer("Key")
        if key then
            key:SetVisible(false)
        end
    end

    local glow = sprite:GetLayer("*Glow")
    local eyes = sprite:GetLayer("Eyes")
    if eyes and glow then
        eyes:SetColor(color)
        glow:SetColor(color)
    end
end

local music = MusicManager()

---@param effect EntityEffect
local function onEffectUpdate(_, effect)
    if effect.SubType == Shuffle.IDS.SubType then

        local data = effect:GetData()
        
        if data.Resouled_ShuffleMiniGameSkull then
            
            local sprite = effect:GetSprite()

            if sprite:IsFinished("Start") then
                music:Crossfade(Shuffle.Music.ShuffleTheme)
                music:Queue(Resouled.AfterlifeShop.Themes.Main)
            end
            
            if sprite:IsEventTriggered(Shuffle.Events.PosUpdate) then
                data.Resouled_ShuffleMiniGameSkull.CurrentSkull.CurrentIndex = math.floor(sprite:GetNullFrame("Skull"..tostring(data.Resouled_ShuffleMiniGameSkull.CurrentSkull.CurrentIndex).."Pos"):GetPos().X)

                for i = 1, Shuffle.SkullCount do
                    local newIndex = math.floor(sprite:GetNullFrame("Skull"..tostring(data.Resouled_ShuffleMiniGameSkull.SkullPositions[i]).."Pos"):GetPos().X)
                    data.Resouled_ShuffleMiniGameSkull.SkullPositions[i] = newIndex
                end
            end

            if sprite:IsFinished("End") then
                sprite:Play("FloatLoop", true)
            end

            if sprite:IsFinished(sprite:GetAnimation()) then
                data.Resouled_ShuffleMiniGameSkull.ShuffleCount = data.Resouled_ShuffleMiniGameSkull.ShuffleCount + 1

                if data.Resouled_ShuffleMiniGameSkull.ShuffleCount <= Shuffle.KeyShuffleCount then
                    sprite:Play(tostring(math.random(Shuffle.ShufflesCount)), true)
                else
                    if not sprite:IsPlaying("FloatLoop") then
                        sprite:Play("End", true)
                    end
                end
            end


            if sprite:IsPlaying("FloatLoop") then
                for i = 1, Shuffle.SkullCount do

                    local skull = sprite:GetNullFrame("Skull"..tostring(i).."Position")

                    if skull then
                        local players = Isaac.FindInRadius(skull:GetPos() * 1.5 + effect.Position, Shuffle.SkullSize, EntityPartition.PLAYER)

                        if #players > 0 then
                            local flashColor = sprite:GetLayer("Eyes"..tostring(i)):GetColor()
                            Resouled:FlashCornerOverlay(flashColor, Shuffle.FlashFadeSpeed)
                            for j = 1, Shuffle.SkullCount do
                                
                                local skull2 = sprite:GetNullFrame("Skull"..tostring(j).."Position")
                                
                                if skull2 then
                                    local color = sprite:GetLayer("Eyes"..tostring(j)):GetColor()
                                    local disappear = true
                                    local correctSkull = false
                                    
                                    if j == i then
                                        disappear = false
                                    end
                                    
                                    local correctSkullIdx = data.Resouled_ShuffleMiniGameSkull.CurrentSkull.CurrentIndex
                                    if correctSkullIdx <= 0 then
                                        correctSkullIdx = 8
                                    end

                                    if j == correctSkullIdx then
                                        correctSkull = true
                                    end
                                    
                                    spawnSkull(color, skull2:GetPos() * 1.5 + effect.Position, effect.InitSeed, disappear, correctSkull)
                                end
                            end
                            effect:Remove()
                        end
                    end
                end
            end
        end
    elseif effect.SubType == Shuffle.IDS_Chosen.SubType then
        local sprite = effect:GetSprite()

        local key = sprite:GetLayer("Key")
        if sprite:IsEventTriggered("KeySpawn") and key and key:IsVisible() then
            Resouled.AfterlifeShop:SetShuffleComplete(true)
        end

        if sprite:IsFinished("Disappear") then
            effect:Remove()
        end

        if sprite:IsFinished("ChosenSkull") then
            sprite:Play("Disappear", true)
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, onEffectUpdate, Shuffle.IDS.Variant)

---@param effect EntityEffect
Resouled:AddCallback(ModCallbacks.MC_PRE_EFFECT_UPDATE, function(_, effect)
    if effect.SubType == Shuffle.IDS.SubType then
        if effect:GetSprite():IsEventTriggered(Shuffle.Events.PosUpdate) then
            setShuffleEyeColor(effect)
        end
    end
end, Shuffle.IDS.Variant)

--END

local presetColors = {
    FriendInsideMe = addPresetEyeColors(Color(255, 225, 0), Color(255, 0, 225)),
    Sans = addPresetEyeColors(Color(0, 200, 255), Color(0, 0, 0)),
    Red = addPresetEyeColors(Color(255, 0, 0), Color(255, 0, 0))
}

---@return table
local function getRandomPresetEyeColors()
    local presets = {}
    for _, colorTable in pairs(presetColors) do
        table.insert(presets, colorTable)
    end

    return presets[math.random(#presets)]
end

---@param npc EntityNPC
local function onNpcInit(_, npc)
    if npc.Variant == WiseSkull.Variant and npc.SubType == WiseSkull.SubType then
        local sprite = npc:GetSprite()
        
        sprite:Play("Idle", true)


        local eye1 = sprite:GetLayer("Eye1")
        local eye2 = sprite:GetLayer("Eye2")

        if eye1 and eye2 then
            local colors = getRandomPresetEyeColors()

            eye1:SetColor(colors[1])
            eye2:SetColor(colors[2])
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_INIT, onNpcInit, WiseSkull.Type)

---@return boolean
function Resouled.AfterlifeShop:IsShuffleComplete()
    local FileSave = SAVE_MANAGER.GetPersistentSave()

    if not FileSave then FileSave = {} end
    if not FileSave.ShuffleGameDone then FileSave.ShuffleGameDone = false end

    return FileSave.ShuffleGameDone
end

---@param complete boolean
function Resouled.AfterlifeShop:SetShuffleComplete(complete)
    local FileSave = SAVE_MANAGER.GetPersistentSave()

    if not FileSave then FileSave = {} end
    if not FileSave.ShuffleGameDone then FileSave.ShuffleGameDone = complete return end

    FileSave.ShuffleGameDone = complete
end