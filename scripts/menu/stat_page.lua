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

fonts.Size10:Load("font/teammeatfont10.fnt")
fonts.Size12:Load("font/teammeatfont12.fnt")
fonts.Size16:Load("font/teammeatfont16.fnt")
fonts.Size20:Load("font/teammeatfont20bold.fnt")

local SPRITE = Sprite()
SPRITE:Load("gfx/menu/stats_menu_resouled.anm2", true)
SPRITE:Play("Idle", true)

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

    local font = fonts.Size16
    local string = "Resouled Stats:"
    local width = font:GetStringWidth(string)
    font:DrawStringScaled(
        string,
        renderPos.X - width/2, renderPos.Y - 100, 1, 1, KColor(1,1,1,1), width, true
    )
end
Resouled:AddCallback(ModCallbacks.MC_MAIN_MENU_RENDER, menuRender)