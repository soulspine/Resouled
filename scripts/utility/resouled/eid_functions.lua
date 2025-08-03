---@class ResouledEID
local Reid = {
    TextColors = {}
}
---@param shortcut string
---@param color? KColor
---@param colorFunction? function
function Reid:RegisterColor(shortcut, color, colorFunction)
    local key = "Resouled"..shortcut
    
    if not Reid.TextColors[shortcut] then
        Reid.TextColors[shortcut] = "{{"..key.."}}"
    else
        Resouled:LogError("Trying to overwrite an already registered color")
    end
    
    EID:addColor(key, color, colorFunction)
end


---@param shortcut string
---@return string | nil
function Reid:GetColorByShortcut(shortcut)
    return Reid.TextColors[shortcut]
end


---@param shortcut string
---@param color KColor
---@param speed integer --The higher the number the slower it flashes
---@param maxColor? KColor --The max color the fade can achieve
function Reid:RegisterFadeColor(shortcut, color, speed, maxColor)
    Reid:RegisterColor(shortcut, nil, function(color2)
        local maxAnimTime = speed
        local maxAnimTime2 = speed * 2
        local animTime = Isaac.GetFrameCount() % maxAnimTime / maxAnimTime
        local animTime2 = Isaac.GetFrameCount() % maxAnimTime2 / maxAnimTime2
        
        animTime = math.abs(animTime - animTime2) * 2
        
        local color2nd = animTime
        
        if not maxColor then
            maxColor = KColor(1, 1, 1, 1)
        end
        
        color2 = KColor(
            (color.Red + (color2nd * (1 - color.Red))) * maxColor.Red,
            (color.Green + (color2nd * (1 - color.Green))) * maxColor.Green,
            (color.Blue + (color2nd * (1 - color.Blue))) * maxColor.Blue,
            1)
            
        return color2
    end)
end
    

---@return string
function Reid:ResetColorModifiers()
    return "{{ColorReset}}"
end


Reid:RegisterFadeColor("FadeNegativeStat", KColor(1, 0, 0, 1), 50)
---@param String string
---@return string
function Reid:FadeNegativeStat(String)
    return "{{ArrowDown}}"..Reid:GetColorByShortcut("FadeNegativeStat")..String..Reid:ResetColorModifiers()
end


---@param String string
---@return string
function Reid:FadeNegativeStatNextLine(String)
    return "#{{ArrowDown}} ".." "..Reid:GetColorByShortcut("FadeNegativeStat")..String..Reid:ResetColorModifiers()
end


Reid:RegisterFadeColor("FadePositiveStat", KColor(0, 1, 0, 1), 50)
---@param String string
---@return string
function Reid:FadePositiveStat(String)
    return "{{ArrowUp}}"..Reid:GetColorByShortcut("FadePositiveStat")..String..Reid:ResetColorModifiers()
end


---@param String string
---@return string
function Reid:FadePositiveStatNextLine(String)
    return "#{{ArrowUp}} ".." "..Reid:GetColorByShortcut("FadePositiveStat")..String..Reid:ResetColorModifiers()
end


Reid:RegisterColor("PositiveStat", KColor(0, 1, 0, 1))
---@param String string
---@return string
function Reid:PositiveStat(String)
    return "{{ArrowUp}}"..Reid:GetColorByShortcut("PositiveStat")..String..Reid:ResetColorModifiers()
end


---@param String string
---@return string
function Reid:PositiveStatNextLine(String)
    return "#{{ArrowUp}} ".." "..Reid:GetColorByShortcut("PositiveStat")..String..Reid:ResetColorModifiers()
end


Reid:RegisterColor("NegativeStat", KColor(1, 0, 0, 1))
---@param String string
---@return string
function Reid:NegativeStat(String)
    return "{{ArrowDown}}"..Reid:GetColorByShortcut("NegativeStat")..String..Reid:ResetColorModifiers()
end


---@param String string
---@return string
function Reid:NegativeStatNextLine(String)
    return "#{{ArrowDown}} ".." "..Reid:GetColorByShortcut("NegativeStat")..String..Reid:ResetColorModifiers()
end


---@param String string
---@return string
function Reid:Fade(String)
    return "{{ColorFade}}"..String..Reid:ResetColorModifiers()
end


---@param String string
---@return string
function Reid:Rainbow(String)
    return "{{ColorRainbow}}"..String..Reid:ResetColorModifiers()
end


Reid:RegisterFadeColor("FadeWarning", KColor(1, 1, 0, 1), 50)
---@param String string
---@return string
function Reid:FadeWarning(String)
    return "{{Warning}}"..Reid:GetColorByShortcut("FadeWarning")..String..Reid:ResetColorModifiers()
end


---@param String string
---@return string
function Reid:FadeWarningNextLine(String)
    return "#{{Warning}} ".." "..Reid:GetColorByShortcut("FadeWarning")..String..Reid:ResetColorModifiers()
end


Reid:RegisterColor("Warning", KColor(1, 1, 0, 1))
---@param String string
---@return string
function Reid:Warning(String)
    return "{{Warning}}"..Reid:GetColorByShortcut("Warning")..String..Reid:ResetColorModifiers()
end


---@param String string
---@return string
function Reid:WarningNextLine(String)
    return "#{{Warning}} ".." "..Reid:GetColorByShortcut("Warning")..String..Reid:ResetColorModifiers()
end


---@return string
function Reid:Coin()
    return "{{Coin}}"
end


---@return string
function Reid:Bomb()
    return "{{Bomb}}"
end


---@return string
function Reid:GoldenBomb()
    return "{{GoldenBomb}}"
end


---@return string
function Reid:Key()
    return "{{Key}}"
end


---@return string
function Reid:GoldenKey()
    return "{{GoldenKey}}"
end


---@return string
function Reid:Damage()
    return "{{Damage}}"
end


---@return string
function Reid:DamageSmall()
    return "{{DamageSmall}}"
end


---@return string
function Reid:Speed()
    return "{{Speed}}"
end


---@return string
function Reid:SpeedSmall()
    return "{{SpeedSmall}}"
end


---@return string
function Reid:Tears()
    return "{{Tears}}"
end


---@return string
function Reid:TearsSmall()
    return "{{TearsSmall}}"
end


---@return string
function Reid:Range()
    return "{{Range}}"
end


---@return string
function Reid:RangeSmall()
    return "{{RangeSmall}}"
end


---@return string
function Reid:Shotspeed()
    return "{{Shotspeed}}"
end


---@return string
function Reid:ShotspeedSmall()
    return "{{ShotspeedSmall}}"
end


---@return string
function Reid:Luck()
    return "{{Luck}}"
end


---@return string
function Reid:LuckSmall()
    return "{{LuckSmall}}"
end


Reid:RegisterFadeColor("FadeBlue", KColor(0.25, 0.5, 1, 1), 50)
---@param String string
---@return string
function Reid:FadeBlue(String)
    return Reid:GetColorByShortcut("FadeBlue")..String..Reid:ResetColorModifiers()
end

Reid:RegisterFadeColor("FadeOrange", KColor(1, 0.5, 0.25, 1), 50)
---@param String string
---@return string
function Reid:FadeOrange(String)
    return Reid:GetColorByShortcut("FadeOrange")..String..Reid:ResetColorModifiers()
end

return Reid