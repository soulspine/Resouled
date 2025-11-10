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
            {
                "Come back Isaac."
            }
        }
    }
)

AddProfile( --Satan
    {
        AppType = "Communication",

        Name = "Satan",

        Gfx = "gfx/isaacOS_profiles/satan.png",

        Prefixes = {
            "",
            "Dealer ",
            "Unholy ",
            "Cool ",
        },
        Suffixes = {
            ""
        },
        Messages = {
            {
                "Brimstone 50% off just today!",
                "Don't miss out on the deal!"
            },
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
            {
                "God's watching me do number two? Oh man",
                "I'm a sinner, and God's a pervert."
            },
            {
                "It'll be a good chance to get away from",
                "the evil monkey that lives in my closet."
            },
            {
                "I put honey on my back, and now",
                "the ants are carrying me home."
            }
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
            {
                "Jacob's ladder works better in flooded areas"
            },
            {
                "Secret rooms can't spawn near boss rooms",
                "and entrances blocked by grid"
            },
            {
                "Press space to use your active item"
            },
            {
                "To win the game, don't get hit"
            }
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
            {
                "Last One Who Survives a Room",
                "Full of Flies - Wins Holy Mantle!"
            },
            {
                "I Trapped 100 Isaacs in Basement",
                "Only One Will Leave Alive!",
            },
            {
                "Last One To Touch The Flame",
                "From Curse Room, Wins Godhead!"
            },
            {
                "I Put 100 Isaacs in a Blood Donation Machine",
                "It Got Messy"
            },
            {
                "Every Contestant Has to Beat a Floor Without Any",
                "Items - Winner Gets 100 Soul Hearts!"
            },
            {
                "If You Take Damage,",
                "I Remove One of Your Organs IRL!"
            },
            {
                "I Played The Binding of Isaac IRL",
                "— Whoever Dies First Loses $50,000!"
            },
            {
                "We Played Binding of Isaac Hide and Seek",
                "Loser Gets Sacrificed!"
            },
            {
                "I Opened 666 Chests to Summon MrBeast Satan"
            },
            {
                "I Challenged God Himself for",
                "1 000 000 Eternal Hearts"
            },
            {
                "Don't Make a Devil Deal at",
                "3AM (He Actually Showed Up)"
            },
            {
                "I Made 1000 Coins Rain Down From",
                "Heaven (The Angel Room Went Wild)"
            },
            {
                "I Offered $100,000 to God to",
                "Let Me Out of the Basement"
            },
            {
                "The Devil Offered Me a Sponsorship Deal"
            },
            {
                "I Paid Judas to Betray Me for $30 Again"
            },
            {
                "I Fed The Beggar Until He",
                "Ascended (Then He Took Me With Him)"
            },
            {
                "The Angel Gave Me Wings, Then Took My Eyes"
            },
            {
                "Every Time Someone Dies, I Gain Another Subscriber"
            }
        }
    }
)

local nameFont = Font()
nameFont:Load("font/teammeatfont12.fnt")
local nameSeparation = nameFont:GetBaselineHeight()

local messageFont = Font()
messageFont:Load("font/teammeatfont10.fnt")
local messageSeparation = messageFont:GetBaselineHeight()


local MESSAGE_APPEAR_TIME = 300
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
    return profile.Messages[math.random(#profile.Messages)]
end

local function queueNewMessage()
    local profile = selectRandomProfile()
    local app = selectRandomApp(profile.AppType)
    local gfx = getProfileGfx(profile)
    local name = selectRandomName(profile)
    local message = selectRandomMessage(profile)
    local maxWidth = nameFont:GetStringWidth(name) + ICON_SIZE.X
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

        MaxOnScreenTime = MESSAGE_APPEAR_TIME + 2,
        OnScreenTime = 2,
        Gain = 1
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

    if Isaac.GetFrameCount() % 60 == 0 and math.random() < 0.3 then
        queueNewMessage()
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