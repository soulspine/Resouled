---@diagnostic disable: param-type-mismatch
local CONFIG = {
    TopString = "Resouled Stats:",
    TextColor = KColor(1, 1, 1, 1),
    HighlightColor = KColor(1, 0, 0, 1),
    ButtonActions = {
        Keyboard = {
            Enter = ButtonAction.ACTION_BOMB,
            Leave = ButtonAction.ACTION_BOMB,
            Up = ButtonAction.ACTION_MENULEFT,
            Down = ButtonAction.ACTION_MENURIGHT,
        },
        Gamepad = {
            Enter = ButtonAction.ACTION_BOMB,
            Leave = ButtonAction.ACTION_SHOOTRIGHT,
            Up = ButtonAction.ACTION_MENULEFT,
            Down = ButtonAction.ACTION_MENURIGHT,
        },
    },
    BackgroundSpriteSize = Vector(350, 200),
    CustomMenuType = 444,
    MaxStatWidth = 250,
    StatOffset = Vector(-167.5, -70),
    PageOffset = Vector(510, 215),
    ViewportOffset = Vector(-39.5, -169.5),
    StatVerticalSpacing = 3

}

local FONTS = {
    Size10 = Font(),
    Size12 = Font(),
    Size16 = Font(),
    Size20 = Font()
}

FONTS.Size10:Load("font/teammeatfont10.fnt")
FONTS.Size12:Load("font/teammeatfont12.fnt")
FONTS.Size16:Load("font/teammeatfont16.fnt")
FONTS.Size20:Load("font/teammeatfont20bold.fnt")

local buffs
Resouled:RunAfterImports(function()
    buffs = Resouled:GetBuffs()
end)

local BUFF_SPRITE = Sprite()
BUFF_SPRITE:Load("gfx/buffs/buffEID.anm2", true)
local BUFF_SPRITE_SIZE = 3
BUFF_SPRITE.Scale = Vector(BUFF_SPRITE_SIZE, BUFF_SPRITE_SIZE)
local BASE_BUFF_OFFSET = Vector(-145, -50)
local BUFF_OFFSET = Vector(-145, -50)
local SPACE_BETWEEN_BUFFS = 56

local NEW_LINE = ">> "
local ENDL = "//endl//"
local MAX_WIDTH = 0

---@param description string
---@param maxWidth? number
---@return table
local function alignDesc(description, maxWidth)
    local alignedDesc = {}
    
    description = NEW_LINE..description
    
    local lastSpace = 1

    ::Start::

    local length = 0

    for i = 1, description:len() do
        local char = description:sub(i, i)

        if char == " " then
            lastSpace = i
        end
        length = length + FONTS.Size10:GetStringWidth(char)
        
        local endline = description:find(ENDL)
        if endline then
            if i == endline then
                alignedDesc[#alignedDesc+1] = description:sub(1, i - 1)
                description = NEW_LINE..description:sub(i + 1 + ENDL:len(), description:len())
                goto Start
            end
        end

        if length > (maxWidth or MAX_WIDTH) then
            alignedDesc[#alignedDesc+1] = description:sub(1, lastSpace)
            description = description:sub(lastSpace + 1, description:len())
            goto Start
        end
    end

    if description ~= "" then
        alignedDesc[#alignedDesc+1] = description
    end

    return alignedDesc
end

local BUFF_DESCRIPTION_OFFSET = Vector(30, -20)
local BUFF_DESCS = {}
local BUFF_PAGE_SCROLL_SPEED = 0
local MAX_BUFF_PAGE_SCROLL_SPEED = 15
local BUFF_PAGE_SCROLL_SPEED_GAIN = 1.5
local BUFF_PAGE_SCROLL_SPEED_LOSS = 0.75
local BUFF_FIX_LINE_THICKNESS = 16
local BUFF_FIX_LINE_COLOR = KColor(0, 0, 0, 1)

local PAGES = {
    {
        Name = "Stats",
        Renderer = function(renderPos, save)
            local i = 0
            local statSeparation = FONTS.Size10:GetBaselineHeight()

            ---@param name string
            for _, name in ipairs(Resouled.StatTracker.FiledsSorted) do
                local posY = renderPos.Y + CONFIG.StatOffset.Y + (statSeparation + CONFIG.StatVerticalSpacing) * i
                local value = save[name]
                if not value then
                    local newName = ""
                    for j = 1, name:len() do
                        if name:sub(j, j) == " " then
                            newName = newName .. " "
                        else
                            newName = newName .. "?"
                        end
                    end
                    name = newName
                    value = "?"
                end
                FONTS.Size10:DrawStringScaled(
                    name, renderPos.X + CONFIG.StatOffset.X, posY, 1, 1, CONFIG.TextColor
                )
                local stringValue = tostring(value)
                FONTS.Size10:DrawStringScaled(
                    stringValue, renderPos.X + CONFIG.StatOffset.X + CONFIG.MaxStatWidth, posY, 1, 1, CONFIG.TextColor, 1
                )
                i = i + 1
            end
        end
    },
    {
        Name = "Buffs",
        Renderer = function(renderPos, save)
            local nameSeparation = FONTS.Size12:GetBaselineHeight()
            local descSeparation = FONTS.Size10:GetBaselineHeight()
            local lineX = renderPos.X + CONFIG.StatOffset.X + CONFIG.MaxStatWidth + 8
            local offset = 0
            local i = 0
            local topLineHeight = renderPos.Y - 75 -- -75 is from line 314 in this file
            local bottomLinePos = renderPos.Y + CONFIG.BackgroundSpriteSize.Y/2

            ---@param buffDesc ResouledBuffDesc
            for _, buffDesc in pairs(buffs) do
                local rarityDesc = Resouled:GetBuffRarityById(buffDesc.Rarity)
                local familyDesc = Resouled:GetBuffFamilyById(buffDesc.Family)

                local pos = renderPos + Vector(0, SPACE_BETWEEN_BUFFS * i + offset) + BUFF_OFFSET

                if familyDesc and rarityDesc then
                    BUFF_SPRITE:ReplaceSpritesheet(0, familyDesc.Spritesheet, true)
                    BUFF_SPRITE:Play(rarityDesc.Name)
                    
                    local topClamp = math.max((topLineHeight - pos.Y)/BUFF_SPRITE_SIZE + 8, 0)
                    local bottomClamp =  math.max(-(bottomLinePos - pos.Y)/BUFF_SPRITE_SIZE + 8.3, 0)

                    if topClamp <= 16 and bottomClamp <= 16 then
                        BUFF_SPRITE:Render(pos, Vector(0, topClamp), Vector(0, bottomClamp))
                    end
                end


                local descPos = Vector(pos.X + BUFF_DESCRIPTION_OFFSET.X, pos.Y + BUFF_DESCRIPTION_OFFSET.Y)

                if not BUFF_DESCS[buffDesc.Id] then
                    BUFF_DESCS[buffDesc.Id] = alignDesc(Resouled.Stats.BuffDescriptions[buffDesc.Id] or "No Desc", lineX - descPos.X) --has to be here because of the lineX
                end
                
                local j = 0
                
                local namePos = descPos.Y + descSeparation * j
                if namePos + nameSeparation > topLineHeight and namePos < bottomLinePos then
                    FONTS.Size12:DrawString(buffDesc.Name, descPos.X, descPos.Y + descSeparation * j, CONFIG.TextColor)
                end

                for _, string in ipairs(BUFF_DESCS[buffDesc.Id]) do
                    local linePos = descPos.Y + descSeparation * j + nameSeparation
                    if linePos + descSeparation > topLineHeight and linePos < bottomLinePos then
                        FONTS.Size10:DrawString(string, descPos.X, descPos.Y + descSeparation * j + nameSeparation, CONFIG.TextColor)
                    end
                    
                    j = j + 1
                end
                offset = offset + math.max(descSeparation * (j - 1) + BUFF_DESCRIPTION_OFFSET.Y + nameSeparation, SPACE_BETWEEN_BUFFS/4)

                i = i + 1
            end

            local lose = true
            if Resouled:IsAnyonePressingAction(ButtonAction.ACTION_MENUDOWN) then
                BUFF_PAGE_SCROLL_SPEED = math.min(BUFF_PAGE_SCROLL_SPEED + BUFF_PAGE_SCROLL_SPEED_GAIN, MAX_BUFF_PAGE_SCROLL_SPEED)
                lose = false
            end
            if Resouled:IsAnyonePressingAction(ButtonAction.ACTION_MENUUP) then
                BUFF_PAGE_SCROLL_SPEED = math.max(BUFF_PAGE_SCROLL_SPEED - BUFF_PAGE_SCROLL_SPEED_GAIN, -MAX_BUFF_PAGE_SCROLL_SPEED)
                lose = false
            end

            local maxY = BASE_BUFF_OFFSET.Y
            local minY = renderPos.Y - offset - SPACE_BETWEEN_BUFFS * i - descSeparation

            BUFF_OFFSET.Y = math.min(math.max(BUFF_OFFSET.Y - BUFF_PAGE_SCROLL_SPEED, minY), maxY)

            if BUFF_OFFSET.Y == minY or BUFF_OFFSET.Y == maxY then
                BUFF_PAGE_SCROLL_SPEED = 0
            end

            if lose then
                if BUFF_PAGE_SCROLL_SPEED > 0 then
                    BUFF_PAGE_SCROLL_SPEED = math.max(BUFF_PAGE_SCROLL_SPEED * BUFF_PAGE_SCROLL_SPEED_LOSS - BUFF_PAGE_SCROLL_SPEED_LOSS, 0)
                elseif BUFF_PAGE_SCROLL_SPEED < 0 then
                    BUFF_PAGE_SCROLL_SPEED = math.min(BUFF_PAGE_SCROLL_SPEED * BUFF_PAGE_SCROLL_SPEED_LOSS + BUFF_PAGE_SCROLL_SPEED_LOSS, 0)
                end
            end
            
            local fixLineX = renderPos.X - CONFIG.BackgroundSpriteSize.X/2


            Isaac.DrawLine(Vector(fixLineX, topLineHeight - BUFF_FIX_LINE_THICKNESS/2), Vector(lineX, topLineHeight - BUFF_FIX_LINE_THICKNESS/2), BUFF_FIX_LINE_COLOR, BUFF_FIX_LINE_COLOR, BUFF_FIX_LINE_THICKNESS)
            Isaac.DrawLine(Vector(fixLineX, bottomLinePos + BUFF_FIX_LINE_THICKNESS/2), Vector(lineX, bottomLinePos + BUFF_FIX_LINE_THICKNESS/2), BUFF_FIX_LINE_COLOR, BUFF_FIX_LINE_COLOR, BUFF_FIX_LINE_THICKNESS)
        end
    },
    {
        Name = "Room Events",
        Renderer = function(renderPos, save)
            FONTS.Size12:DrawStringScaled(
                "Room Events",
                renderPos.X,
                renderPos.Y,
                1, 1, CONFIG.TextColor
            )
        end
    },
}

local BACKGROUND_SPRITE = Sprite()
BACKGROUND_SPRITE:Load("gfx/menu/stats_menu_resouled.anm2", true)
BACKGROUND_SPRITE:Play("Idle", true)

local currentPageIdx = 1 -- 1-indexed because lua

---@param renderPos Vector
local function renderPagesSidebar(renderPos)
    local separatorY = FONTS.Size12:GetLineHeight()

    -- sidebar render
    for i, pageData in ipairs(PAGES) do
        local x = renderPos.X + CONFIG.StatOffset.X + CONFIG.MaxStatWidth + 14
        local y = renderPos.Y + CONFIG.StatOffset.Y + separatorY * (i - 1)
        local size = math.min(
            1 +
            (1 - FONTS.Size12:GetStringWidth(pageData.Name) / ((renderPos.X + CONFIG.BackgroundSpriteSize.X / 2 - 3) - x)),
            1)

        local color = i == currentPageIdx and CONFIG.HighlightColor or CONFIG.TextColor

        FONTS.Size12:DrawStringScaled(
            pageData.Name,
            x,
            y,
            size,
            size,
            color)
    end
end

local function menuRender()
    local saveObj = Resouled.StatTracker:GetSave()
    local menu = MenuManager.GetActiveMenu()

    -- TODO CHECK FOR INPUT DEVICE
    -- FOR NOW ASSUME KEYBOARD
    local inputLookup = CONFIG.ButtonActions.Keyboard

    -- handling menu page changing
    if menu == MainMenuType.STATS and Resouled:HasAnyoneTriggeredAction(inputLookup.Enter) then
        MenuManager.SetActiveMenu(CONFIG.CustomMenuType)
        currentPageIdx = 1
        BUFF_OFFSET = Vector(BASE_BUFF_OFFSET.X, BASE_BUFF_OFFSET.Y)
    elseif menu == CONFIG.CustomMenuType and Resouled:HasAnyoneTriggeredAction(inputLookup.Leave) then
        MenuManager.SetActiveMenu(MainMenuType.STATS)
    end

    -- handling up / down
    if menu == CONFIG.CustomMenuType then
        if Resouled:HasAnyoneTriggeredAction(inputLookup.Up) then
            currentPageIdx = ((currentPageIdx - 2) % #PAGES) + 1
        elseif Resouled:HasAnyoneTriggeredAction(inputLookup.Down) then
            currentPageIdx = (currentPageIdx % #PAGES) + 1
        end
    end

    local pos = Isaac.WorldToMenuPosition(MainMenuType.TITLE, CONFIG.ViewportOffset)

    if menu == CONFIG.CustomMenuType then
        MenuManager.SetViewPosition(pos)
    end

    local renderPos = Isaac.WorldToMenuPosition(MainMenuType.STATS, Vector(0, 0)) + CONFIG.BackgroundSpriteSize / 2 +
        CONFIG.PageOffset
    BACKGROUND_SPRITE:Render(renderPos)

    local width = FONTS.Size16:GetStringWidth(CONFIG.TopString)

    PAGES[currentPageIdx].Renderer(renderPos, saveObj)

    FONTS.Size16:DrawStringScaled(
        CONFIG.TopString,
        renderPos.X - width / 2, renderPos.Y - 100, 1, 1, CONFIG.TextColor, width, true
    )

    Isaac.DrawQuad(
        renderPos - CONFIG.BackgroundSpriteSize / 2,
        renderPos - Vector(-CONFIG.BackgroundSpriteSize.X, CONFIG.BackgroundSpriteSize.Y) / 2,
        renderPos + Vector(-CONFIG.BackgroundSpriteSize.X, CONFIG.BackgroundSpriteSize.Y) / 2,
        renderPos + CONFIG.BackgroundSpriteSize / 2,
        CONFIG.TextColor,
        1.5
    )

    local lineX = renderPos.X + CONFIG.StatOffset.X + CONFIG.MaxStatWidth + 8

    Isaac.DrawLine(Vector(renderPos.X - CONFIG.BackgroundSpriteSize.X / 2, renderPos.Y - 75),
        Vector(renderPos.X + CONFIG.BackgroundSpriteSize.X / 2, renderPos.Y - 75), CONFIG.TextColor, CONFIG.TextColor, 1)
    Isaac.DrawLine(Vector(lineX, renderPos.Y - 75), Vector(lineX, renderPos.Y + CONFIG.BackgroundSpriteSize.Y / 2 + 0.3),
        CONFIG.TextColor,
        CONFIG.TextColor, 1)

    renderPagesSidebar(renderPos)
end
Resouled:AddCallback(ModCallbacks.MC_MAIN_MENU_RENDER, menuRender)
