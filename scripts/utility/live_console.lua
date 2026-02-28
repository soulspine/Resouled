-- REQUIRES REPENTOGON

-- PUT MOD HERE
local MOD = Resouled

---@class LiveConsoleModule
local liveConsoleModule = {}
local consoleVisible = false
local linesToShow = 10

local font = Font()
font:Load("font/luaminioutlined.fnt")
local baseLineHeight = font:GetBaselineHeight()/1.35
local textColor = KColor(1, 1, 1, 0.5)

local pos = Vector.Zero

local boxWidth = 150
local boxHeight = baseLineHeight * linesToShow
local topRightVector = Vector(boxWidth, 0)
local bottomLeftVector = Vector(0, boxHeight)
local backgroundColor = KColor(0, 0, 0, 0.35)
local backgroundVectorStart = Vector(0, boxHeight/2)
local backgroundVectorEnd = Vector(boxWidth, boxHeight/2)

---@param width number
---@param lines integer
function liveConsoleModule:SetDimensions(width, lines)
    linesToShow = lines
    boxWidth = width
    boxHeight = baseLineHeight * linesToShow
    topRightVector = Vector(boxWidth, 0)
    bottomLeftVector = Vector(0, boxHeight)
    backgroundVectorStart = Vector(0, boxHeight/2)
    backgroundVectorEnd = Vector(boxWidth, boxHeight/2)
end

---@param s string
---@return table
local function alignText(s)
    local aligned = {}

    local len = 0
    local lastSpace = 1

    
    ::Start::

    for i = 1, s:len() do
        local c = s:sub(i, i)
        if c == ' ' then lastSpace = i end
        len = len + font:GetStringWidth(c)
    
        if len + 1 > boxWidth then
            if lastSpace < 3 then
                aligned[#aligned+1] = s:sub(1, i - 1)
                s = s:sub(i, s:len())
            else
                aligned[#aligned+1] = s:sub(1, lastSpace)
                s = s:sub(lastSpace + 1, s:len())
            end
            len = 0
            goto Start
        end
    end
    if s ~= '' then
        aligned[#aligned+1] = s
        len = 0
    end


    return aligned
end

function liveConsoleModule:Toggle() consoleVisible = not consoleVisible end
function liveConsoleModule:SetVisible(visible) consoleVisible = visible end

local isMoving = false
local lastMousePos = Isaac.WorldToScreen(Input.GetMousePosition(true))

MOD:AddCallback(ModCallbacks.MC_POST_HUD_RENDER, function()
    if not consoleVisible then return end

    Isaac.DrawLine(pos + backgroundVectorStart, pos + backgroundVectorEnd, backgroundColor, backgroundColor, boxHeight)

    local history = Console.GetHistory()
    local historySorted = {}

    local i = linesToShow + 1
    while i > 0 do

        local x = history[i]
        if x then
            for _, s in ipairs(alignText(x)) do
                table.insert(historySorted, s)
            end
        end

        i = i - 1
    end

    i = linesToShow
    local size = #historySorted
    while i > 0 do
        font:DrawString(historySorted[size - i + 1], pos.X + 1, pos.Y + baseLineHeight * (linesToShow - i) - baseLineHeight/2 - 1.5, textColor)
        i = i - 1
    end


    --MOVEMENT
    local currentMousePos = Isaac.WorldToScreen(Input.GetMousePosition(true))

    if isMoving then
        pos = pos - (lastMousePos - currentMousePos)
    end

    if Input.IsMouseBtnPressed(MouseButton.LEFT) and (
        currentMousePos.X > pos.X and
        currentMousePos.X < pos.X + topRightVector.X and
        currentMousePos.Y > pos.Y and
        currentMousePos.Y < pos.Y + bottomLeftVector.Y
    ) then
        isMoving = true
    else
        isMoving = false
    end
    if Input.IsMouseBtnPressed(MouseButton.RIGHT) then
        liveConsoleModule:SetDimensions(math.abs(currentMousePos.X - pos.X), math.abs(math.ceil((currentMousePos.Y - pos.Y))//baseLineHeight))
    end
    lastMousePos = currentMousePos

end)

return liveConsoleModule