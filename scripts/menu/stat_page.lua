---@diagnostic disable: param-type-mismatch
local CONFIG = {
    TopString = "Resouled Stats:",
    TextColor = KColor(1, 1, 1, 1),
    HighlightColor = KColor(1, 0, 0, 1),
    ButtonActions = {
        Keyboard = {
            Enter = ButtonAction.ACTION_BOMB,
            Leave = ButtonAction.ACTION_BOMB,
            Up = ButtonAction.ACTION_MENUUP,
            Down = ButtonAction.ACTION_MENUDOWN,
        },
        Gamepad = {
            Enter = ButtonAction.ACTION_BOMB,
            Leave = ButtonAction.ACTION_SHOOTRIGHT,
            Up = ButtonAction.ACTION_MENUUP,
            Down = ButtonAction.ACTION_MENUDOWN,
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

local PAGES = {
    {
        Name = "Stats",
        Renderer = function(renderPos, save)
            local i = 0
            local statSeparation = FONTS.Size10:GetBaselineHeight()

            ---@param name string
            for _, name in pairs(Resouled.StatTracker.Fields) do
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
            FONTS.Size12:DrawStringScaled(
                "Buffs",
                renderPos.X,
                renderPos.Y,
                1, 1, CONFIG.TextColor
            )
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
local saveObj = Resouled.StatTracker:GetSave()

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
    local menu = MenuManager.GetActiveMenu()

    -- TODO CHECK FOR INPUT DEVICE
    -- FOR NOW ASSUME KEYBOARD
    local inputLookup = CONFIG.ButtonActions.Keyboard

    -- handling menu page changing
    if menu == MainMenuType.STATS and Resouled:HasAnyoneTriggeredAction(inputLookup.Enter) then
        MenuManager.SetActiveMenu(CONFIG.CustomMenuType)
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
    PAGES[currentPageIdx].Renderer(renderPos, saveObj)
end
Resouled:AddCallback(ModCallbacks.MC_MAIN_MENU_RENDER, menuRender)
