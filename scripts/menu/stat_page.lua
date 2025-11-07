local SPRITE_SIZE = Vector(350, 200)
local MENU_TYPE = (math.floor((672 * 852)/3486) * 3) - 48
local PAGE_OFFSET = Vector(510, 215)
local VIEWPORT_OFFSET = Vector(-39.5, -169.5)
local BUTTON_ACTION_ENTER = ButtonAction.ACTION_BOMB
local BUTTON_ACTION_LEAVE = ButtonAction.ACTION_BOMB

local fonts = {
    Size10 = Font(),
    Size12 = Font(),
    Size16 = Font(),
    Size20 = Font()
}

local TEXT_COLOR = KColor(1,1,1,1)
local MAX_STAT_WIDTH = 250
local STAT_OFFSET = Vector(-167.5, -70)
local SPACE_BETWEEN_STATS = 3

local TOP_MESSAGE_STRING = "Resouled Stats:"

fonts.Size10:Load("font/teammeatfont10.fnt")
fonts.Size12:Load("font/teammeatfont12.fnt")
fonts.Size16:Load("font/teammeatfont16.fnt")
fonts.Size20:Load("font/teammeatfont20bold.fnt")

local SPRITE = Sprite()
SPRITE:Load("gfx/menu/stats_menu_resouled.anm2", true)
SPRITE:Play("Idle", true)

---@param renderPos Vector
local function renderStatPage(renderPos)
    local save = Resouled.StatTracker:GetSave()
    
    local i = 0
    local statSeperation = fonts.Size10:GetBaselineHeight()
    
    ---@param name string
    for _, name in pairs(Resouled.StatTracker.Fields) do
        local posY = renderPos.Y + STAT_OFFSET.Y + (statSeperation + SPACE_BETWEEN_STATS) * i
        local value = save[name]
        if not value then
            local newName = ""
            for j = 1, name:len() do
                if name:sub(j, j) == " " then
                    newName = newName.." "
                else
                    newName = newName.."?"
                end
            end
            name = newName
            value = "?"
        end
        fonts.Size10:DrawStringScaled(
            name, renderPos.X + STAT_OFFSET.X, posY, 1, 1, TEXT_COLOR
        )
        local stringValue = tostring(value)
        fonts.Size10:DrawStringScaled(
            stringValue, renderPos.X + STAT_OFFSET.X + MAX_STAT_WIDTH, posY, 1, 1, TEXT_COLOR, 1
        )
        i = i + 1
    end
end

local pages = {
    [1] = "Stats",
    [2] = "Buffs",
    [3] = "Room Events"
}

local config = {
    CurrentPage = pages[1],
}

local pagesRender = {
    [pages[1]] = renderStatPage,
}

---@param renderPos Vector
local function renderPages(renderPos)
    local i = 0
    local seperatorY = fonts.Size12:GetLineHeight()

    for _, _ in pairs(pages) do
        local page = pages[i + 1]
        local x = renderPos.X + STAT_OFFSET.X + MAX_STAT_WIDTH + 14
        local y = renderPos.Y + STAT_OFFSET.Y + seperatorY * i
        local size = math.min(1 + (1 - fonts.Size12:GetStringWidth(page)/((renderPos.X + SPRITE_SIZE.X/2 - 3) - x)), 1)

        fonts.Size12:DrawStringScaled(
            page,
            x,
            y,
            size,
            size,
            TEXT_COLOR)
        i = i + 1
    end
end

local function menuRender()
    local menu = MenuManager.GetActiveMenu()
    
    if menu == MainMenuType.STATS and Resouled:HasAnyoneTriggeredAction(BUTTON_ACTION_ENTER) then
        MenuManager.SetActiveMenu(MENU_TYPE)
    elseif menu == MENU_TYPE and Resouled:HasAnyoneTriggeredAction(BUTTON_ACTION_LEAVE) then
        MenuManager.SetActiveMenu(MainMenuType.STATS)
    end
    
    
    local pos = Isaac.WorldToMenuPosition(MainMenuType.TITLE, VIEWPORT_OFFSET)

    if menu == MENU_TYPE then
        MenuManager.SetViewPosition(pos)
    end

    local renderPos = Isaac.WorldToMenuPosition(MainMenuType.STATS, Vector(0, 0)) + SPRITE_SIZE/2 + PAGE_OFFSET
    SPRITE:Render(renderPos)
    
    local width = fonts.Size16:GetStringWidth(TOP_MESSAGE_STRING)

    fonts.Size16:DrawStringScaled(
        TOP_MESSAGE_STRING,
        renderPos.X - width/2, renderPos.Y - 100, 1, 1, TEXT_COLOR, width, true
    )

    Isaac.DrawQuad(
        renderPos - SPRITE_SIZE/2,
        renderPos - Vector(-SPRITE_SIZE.X, SPRITE_SIZE.Y)/2,
        renderPos + Vector(-SPRITE_SIZE.X, SPRITE_SIZE.Y)/2,
        renderPos + SPRITE_SIZE/2,
        TEXT_COLOR,
        1.5
    )

    local lineX = renderPos.X + STAT_OFFSET.X + MAX_STAT_WIDTH + 8
    
    Isaac.DrawLine(Vector(renderPos.X - SPRITE_SIZE.X/2, renderPos.Y - 75), Vector(renderPos.X + SPRITE_SIZE.X/2, renderPos.Y - 75), TEXT_COLOR, TEXT_COLOR, 1)
    Isaac.DrawLine(Vector(lineX, renderPos.Y - 75), Vector(lineX, renderPos.Y + SPRITE_SIZE.Y/2 + 0.3), TEXT_COLOR, TEXT_COLOR, 1)

    renderPages(renderPos)
    
    pagesRender[config.CurrentPage](renderPos)
end
Resouled:AddCallback(ModCallbacks.MC_MAIN_MENU_RENDER, menuRender)