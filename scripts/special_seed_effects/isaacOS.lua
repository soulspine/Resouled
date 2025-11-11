local PROFILES = {}
local APPS = {}

local function AddProfile(profile)
    table.insert(PROFILES, profile)
end

---@param type string
---@param string string
local function AddApp(type, string)
    if not APPS[type] then APPS[type] = {} end
    table.insert(APPS[type], string)
end

AddApp("Communication", "Basecord")
AddApp("Communication", "Contacts")
AddApp("Communication", "Facement")
AddApp("Communication", "WhatsBasement")

AddApp("Platform", "IsaacTube")

AddApp("None", "")

AddProfile( --Mom
    {
        AppType = "Communication",

        Name = "Mom",

        Gfx = "gfx/isaacOS_profiles/mom.png",

        Prefixes = {
            "",
            "Your ",
            "Scary ",
            "Intimidating "
        },
        Suffixes = {
            ""
        },
        Messages = {
            function() return{
                "Come back Isaac."
            }end
        }
    }
)

AddProfile( --Devil
    {
        AppType = "Communication",

        Name = "Devil",

        Gfx = "gfx/isaacOS_profiles/satan.png",

        Prefixes = {
            "",
            "Dealer ",
            "Unholy ",
            "Cool ",
        },
        Suffixes = {
            "",
            " Guy"
        },
        Messages = {
            function() return{
                "Back again, little lamb? You never learn"
            }end,
            function() return{
                "Mother can't hear you down here"
            }end,
            function() return{
                "Every death feeds me"
            }end,
            function() return{
                "The angels lie. I deliver"
            }end,
            function() return{
                "You think you've escaped me?",
                "Look around"
            }end,
            function() return{
                "Even your faith is a weapon I forged"
            }end,
            function() return{
                "Brimstone discounted just for you",
                "if you abandon god"
            }end
        }
    }
)

AddProfile( --Chris Griffin
    {
        AppType = "Communication",

        Name = "Chris Griffin",

        Gfx = "gfx/isaacOS_profiles/chris_griffin.png",

        Prefixes = {
            ""
        },
        Suffixes = {
            ""
        },
        Messages = {
            function() return{
                "God's watching me do number two? Oh man",
                "I'm a sinner, and God's a pervert."
            }end,
            function() return{
                "It'll be a good chance to get away from",
                "the evil monkey that lives in my closet."
            }end,
            function() return{
                "I put honey on my back, and now",
                "the ants are carrying me home."
            }end
        }
    }
)

AddProfile( --Announcer
    {
        AppType = "None",

        Name = "Announcer",

        Gfx = "gfx/isaacOS_profiles/announcer.png",

        Prefixes = {
            ""
        },
        Suffixes = {
            ""
        },
        Messages = {
            function() return{
                "Jacob's ladder works better in flooded areas"
            }end,
            function() return{
                "Secret rooms can't spawn near boss rooms",
                "and entrances blocked by grid"
            }end,
            function() return{
                "Press space to use your active item"
            }end,
            function() return{
                "To win the game, don't get hit"
            }end,
            function()
                local frames = Game():GetFrameCount()
                local seconds = frames//30
                local minutes = seconds//60
                local hours = minutes//60
                return{
                    "You're playing this run for",
                    tostring(hours).."h "..tostring(minutes%60).."m "..tostring(seconds%60).."s"
            }end
        }
    }
)

AddProfile( --Beast
    {
        AppType = "Platform",

        Name = "Beast",

        Gfx = "gfx/isaacOS_profiles/beast.png",

        Prefixes = {
            ""
        },
        Suffixes = {
            ""
        },
        Messages = {
            function() return{
                "Last One Who Survives a Room",
                "Full of Flies - Wins Holy Mantle!"
            }end,
            function() return{
                "I Trapped 100 Isaacs in Basement",
                "Only One Will Leave Alive!",
            }end,
            function() return{
                "Last One To Touch The Flame",
                "From Curse Room, Wins Godhead!"
            }end,
            function() return{
                "I Put 100 Isaacs in a Blood Donation Machine",
                "It Got Messy"
            }end,
            function() return{
                "Every Contestant Has to Beat a Floor Without Any",
                "Items - Winner Gets 100 Soul Hearts!"
            }end,
            function() return{
                "If You Take Damage,",
                "I Remove One of Your Organs IRL!"
            }end,
            function() return{
                "I Played The Binding of Isaac IRL",
                "— Whoever Dies First Loses $50,000!"
            }end,
            function() return{
                "We Played Binding of Isaac Hide and Seek",
                "Loser Gets Sacrificed!"
            }end,
            function() return{
                "I Opened 666 Chests to Summon MrBeast Satan"
            }end,
            function() return{
                "I Challenged God Himself for",
                "1 000 000 Eternal Hearts"
            }end,
            function() return{
                "Don't Make a Devil Deal at",
                "3AM (He Actually Showed Up)"
            }end,
            function() return{
                "I Made 1000 Coins Rain Down From",
                "Heaven (The Angel Room Went Wild)"
            }end,
            function() return{
                "I Offered $100,000 to God to",
                "Let Me Out of the Basement"
            }end,
            function() return{
                "The Devil Offered Me a Sponsorship Deal"
            }end,
            function() return{
                "I Paid Judas to Betray Me for $30 Again"
            }end,
            function() return{
                "I Fed The Beggar Until He",
                "Ascended (Then He Took Me With Him)"
            }end,
            function() return{
                "The Angel Gave Me Wings, Then Took My Eyes"
            }end,
            function() return{
                "Every Time Someone Dies, I Gain Another Subscriber"
            }end
        }
    }
)

AddProfile( --Spam
    {
        AppType = "Communication",

        Name = "Spam",

        Gfx = "gfx/isaacOS_profiles/spam.png",

        Prefixes = {
            ""
        },
        Suffixes = {
            ""
        },
        Messages = {
            function()return{
                "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
                "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
                "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
                "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
                "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
                "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
                "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
                "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
                "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
                "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
                "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
                "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
                "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
                "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
            }end
        }
    }
)

local function getTime()
    local frames = Game():GetFrameCount()
    local seconds = frames//30
    local minutes = seconds//60
    local hours = minutes//60
    return tostring(hours).."h "..tostring(minutes%60).."m "..tostring(seconds%60).."s"
end

local nameFont = Font()
nameFont:Load("font/teammeatfont12.fnt")
local nameSeparation = nameFont:GetBaselineHeight()

local messageFont = Font()
messageFont:Load("font/teammeatfont10.fnt")
local messageSeparation = messageFont:GetBaselineHeight()


local MESSAGE_APPEAR_TIME = 225
local ICON_SIZE = Vector(46, 46)
local messageQueue = {}

local function selectRandomApp(type)
    return APPS[type][math.random(#APPS[type])]
end

local function selectRandomProfile()
    return PROFILES[math.random(#PROFILES)]
end

local function selectRandomName(profile)
    local prefix = nil
    if #profile.Prefixes > 0 then
        prefix = profile.Prefixes[math.random(#profile.Prefixes)]
    end
    local suffix = nil
    if #profile.Suffixes > 0 then
        suffix = profile.Suffixes[math.random(#profile.Suffixes)]
    end

    return (prefix or "")..profile.Name..(suffix or "")
end

local function getProfileGfx(profile)
    return profile.Gfx
end

local function selectRandomMessage(profile)
    return profile.Messages[math.random(#profile.Messages)]()
end

---@param profile? table
---@param appearTime? integer
local function queueNewMessage(profile, appearTime)
    profile = profile or selectRandomProfile()
    local app = selectRandomApp(profile.AppType)
    local gfx = getProfileGfx(profile)
    local name = selectRandomName(profile)
    local message = selectRandomMessage(profile)
    local time = getTime()
    local maxWidth = math.max(nameFont:GetStringWidth(name), messageFont:GetStringWidth(app) + messageFont:GetStringWidth(time)) + ICON_SIZE.X
    local maxHeight = ICON_SIZE.Y/2
    for _, string in pairs(message) do
        maxWidth = math.max(maxWidth, messageFont:GetStringWidth(string) - 13, ICON_SIZE.X + messageFont:GetStringWidth(app))
        maxHeight = maxHeight + messageSeparation
    end
    maxHeight = math.max(ICON_SIZE.Y/2, maxHeight - messageSeparation)

    local messageConfig = {
        App = app,
        Name = name,
        Message = message,

        Gfx = gfx,

        Width = 0,
        Height = 0,
        MaxWidth = maxWidth,
        MaxHeight = maxHeight,

        MaxOnScreenTime = (appearTime or MESSAGE_APPEAR_TIME) + 2,
        OnScreenTime = 2,
        Gain = 1,

        Time = time
    }

    local i = #messageQueue
    while i > 0 do
        messageQueue[i + 1] = messageQueue[i]

        i = i - 1
    end

    messageQueue[1] = messageConfig
end

local popupSprite = Sprite()
popupSprite:Load("gfx/isaacOS_profiles/popup.anm2", true)
local MAX_POPUP_ALPHA = 0.75

local iconSprite = Sprite()
iconSprite:Load("gfx/isaacOS_profiles/profile.anm2", true)
iconSprite:Play("Idle", true)

local function startPos()
    return Vector(Isaac.GetScreenWidth()/2, 26)
end

local function render()
    if not Resouled:IsSpecialSeedEffectActive(Resouled.SpecialSeedEffects.IsaacIOS) or RoomTransition.GetTransitionMode() == 4 then return end

    if Isaac.GetFrameCount() % 60 == 0 and math.random() < 0.1 then
        --queueNewMessage()
    end

    if #messageQueue > 0 then
        
        local offset = Vector(0, 0)

        for i, messageConfig in ipairs(messageQueue) do
            local pos = startPos() + offset

            local iconAlpha = math.max(math.min(math.log(math.max(messageConfig.OnScreenTime - 40, 0), messageConfig.OnScreenTime) * 1.1, 1), 0)
            local scale = math.max(math.min(math.log(math.max(messageConfig.OnScreenTime - 50, 0), messageConfig.OnScreenTime/1.5), 1), 0)
            local textAlpha1 = math.log(math.max(messageConfig.OnScreenTime - 60, 0), messageConfig.OnScreenTime/1.5)
            if textAlpha1 == math.huge then
                textAlpha1 = 0
            end
            local textAlpha = math.max(math.min(textAlpha1, 1), 0)
            messageConfig.Height = messageConfig.MaxHeight * scale
            messageConfig.Width = messageConfig.MaxWidth * scale

            local textSize = Vector(messageConfig.Width/messageConfig.MaxWidth, messageConfig.Height/messageConfig.MaxHeight)

            if pos.Y - 52 <= Isaac.GetScreenHeight() then
                
                iconSprite:ReplaceSpritesheet(1, messageConfig.Gfx, true)
                
                popupSprite.Color.A = MAX_POPUP_ALPHA * iconAlpha
                
                popupSprite.Scale = Vector(1, 1)
                popupSprite:Play("TopLeft", true)
                popupSprite:Render(pos - Vector(messageConfig.Width/2, 0))
                
                popupSprite:Play("Top", true)
                popupSprite.Scale.X = messageConfig.Width
                popupSprite:Render(pos - Vector(messageConfig.Width/2, 0))
                
                popupSprite:Play("Left", true)
                popupSprite.Scale = Vector(1, messageConfig.Height)
                popupSprite:Render(pos - Vector(messageConfig.Width/2, 0))
                
                popupSprite:Play("Middle", true)
                popupSprite.Scale.X = messageConfig.Width
                popupSprite:Render(pos - Vector(messageConfig.Width/2, 0))
                
                popupSprite:Play("TopRight", true)
                popupSprite.Scale = Vector(1, 1)
                popupSprite:Render(pos + Vector(messageConfig.Width/2, 0))
                
                popupSprite:Play("Right", true)
                popupSprite.Scale.Y = messageConfig.Height
                popupSprite:Render(pos + Vector(messageConfig.Width/2, 0))
                
                popupSprite:Play("BottomLeft", true)
                popupSprite.Scale = Vector(1, 1)
                popupSprite:Render(pos + Vector(-messageConfig.Width/2, messageConfig.Height))
                
                popupSprite:Play("Bottom", true)
                popupSprite.Scale.X = messageConfig.Width
                popupSprite:Render(pos + Vector(-messageConfig.Width/2, messageConfig.Height))
                
                popupSprite:Play("BottomRight", true)
                popupSprite.Scale = Vector(1, 1)
                popupSprite:Render(pos + Vector(messageConfig.Width/2, messageConfig.Height))



                messageFont:DrawStringScaled(messageConfig.App, pos.X -messageConfig.Width/2 + 26, pos.Y - messageSeparation * 1.5, textSize.X, textSize.Y, KColor(1, 1, 1, textAlpha * 0.75))

                messageFont:DrawStringScaled(messageConfig.Time, pos.X +messageConfig.Width/2 - messageFont:GetStringWidth(messageConfig.Time) * scale, pos.Y - messageSeparation * 1.5, textSize.X, textSize.Y, KColor(1, 1, 1, textAlpha * 0.75))

                nameFont:DrawStringScaled(messageConfig.Name, pos.X -messageConfig.Width/2 + 26, pos.Y - messageSeparation * 0.5, textSize.X, textSize.Y, KColor(1, 1, 1, textAlpha))
                
                iconSprite.Color.A = iconAlpha
                iconSprite:Render(pos - Vector(messageConfig.Width/2, 0))
                
                local messagePos = Vector(pos.X, pos.Y + messageSeparation)
                for _, string in ipairs(messageConfig.Message) do
                    messagePos.Y = messagePos.Y + messageSeparation * textSize.Y
                    messageFont:DrawStringScaled(string, messagePos.X -messageConfig.Width/2, messagePos.Y, textSize.X, textSize.Y, KColor(1, 1, 1, textAlpha))
                end
            end

            offset = offset + Vector(0, messageConfig.Height) + Vector(0, 52 * iconAlpha)

            if messageConfig.OnScreenTime == messageConfig.MaxOnScreenTime then
                messageConfig.Gain = -messageConfig.Gain
            end

            messageConfig.OnScreenTime = math.min(messageConfig.OnScreenTime + messageConfig.Gain, messageConfig.MaxOnScreenTime)

            if messageConfig.OnScreenTime == 2 then
                table.remove(messageQueue, i)
            end
        end

    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_RENDER, render)


---@param name string
local function fixName(name)
    local newName = ""
    for i = 1, name:len() do
        local char = name:sub(i, i)
        if char == "#" then
        elseif char == "_" then
            newName = newName.." "
        else
            newName = newName..char:lower()
        end
    end
    return newName
end

---@param entity Entity
---@return string
local function getName(entity)

    local name = fixName(EntityConfig.GetEntity(entity.Type, entity.Variant, entity.SubType):GetName())

    local npc = entity:ToNPC()
    if npc and npc:IsChampion() then
        name = "champion "..name
    end

    return name
end

---@param entity Entity
---@param amount number
---@param source EntityRef
Resouled:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, entity, amount, _, source)
    if not Resouled:IsSpecialSeedEffectActive(Resouled.SpecialSeedEffects.IsaacIOS) then return end
    entity = entity.SpawnerEntity or entity
    
    if entity.HitPoints > amount or not entity:IsEnemy() or not entity:IsActiveEnemy() or entity:IsDead() or entity:GetData().Resouled_MessageSent then return end

    if not source.Entity then return end

    local player = Resouled:TryFindPlayerSpawner(source.Entity)

    if not player then return end

    queueNewMessage({
        AppType = "Communication",

        Name = getName(entity),

        Gfx = "gfx/isaacOS_profiles/dead_enemy.png",

        Prefixes = {
            "",
        },
        Suffixes = {
            ""
        },
        Messages = {
            function() return{
                "Fuck You"
            }end,
            function() return{
                "I'll get you next time"
            }end,
            function() return{
                "I hope you die"
            }end,
            function() return{
                "You just got lucky"
            }end,
            function() return{
                "Watch your steps lil bro"
            }end,
            function() return{
                "I'm gonna tell your mom"
            }end
        }
    }, math.floor(MESSAGE_APPEAR_TIME/2))
    entity:GetData().Resouled_MessageSent = true
end)