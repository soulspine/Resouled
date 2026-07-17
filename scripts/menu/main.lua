local MENU_TYPE = 444
local MENU_COLOR = KColor(192/255, 161/255, 161/255, 1)
local TEXT_COLOR = KColor(47/255, 27/255, 33/255, 1)

local transitioning = false
local transition_time = 0
local transition_speed = 1
local TRANSITION_TIME = 150

local function transition()
    local c = KColor(12/255, 3/255, 0, 0)
    local x = TRANSITION_TIME/3
    if transition_time < x then
        c.Alpha = transition_time/x
    elseif transition_time >= x * 2 then
        c.Alpha = 1 - ((transition_time - x*2)/x)
    else
        c.Alpha = 1
    end
    Resouled:OverlayScreen(c)
end

local BG_SPRITE = Sprite()
BG_SPRITE.Scale = Vector.One * 0.5
BG_SPRITE:Load("gfx_resouled/menu/background/planetarium.anm2", true)
BG_SPRITE:Play("Idle", true)
BG_SPRITE.Color = Color(1, 1, 1, 1, -0.025, -0.04, -0.015)
local PLANETARIUM_LAYERS = {
    {Spritesheet = "gfx_resouled/menu/background/planetarium_blue_base.png", Speed = 1},
    {Spritesheet = "gfx_resouled/menu/background/planetarium_starfield_1.png", Speed = 3.5},
    {Spritesheet = "gfx_resouled/menu/background/planetarium_starfield_2.png", Speed = 6},
    {Spritesheet = "gfx_resouled/menu/background/planetarium_starfield_3.png", Speed = 8.5},
    {Spritesheet = "gfx_resouled/menu/background/planetarium_starfield_4.png", Speed = 11},
    {Spritesheet = "gfx_resouled/menu/background/planetarium_starfield_5.png", Speed = 13.5}
}

---@param pos Vector
---@return Vector
local function toMenuPos(pos)
    local x = MenuManager.GetViewPosition()
    x.Y = -x.Y
    return pos - x
end

local function renderPlanetarium()
    local pos = MenuManager.GetViewPosition()
    local frame = Isaac.GetFrameCount()/25
    local screen = Resouled.Screen()
    pos.X = pos.X - (pos.X % (600 * BG_SPRITE.Scale.X))
    pos.Y = pos.Y - (pos.Y % (400 * BG_SPRITE.Scale.Y))
    
    local X = math.ceil(screen.X/(300 * BG_SPRITE.Scale.X)) + 1
    local Y = math.ceil(screen.Y/(200 * BG_SPRITE.Scale.Y))

    local layerPos = Vector.Zero
    for _, layerConf in ipairs(PLANETARIUM_LAYERS) do
        BG_SPRITE:ReplaceSpritesheet(0, layerConf.Spritesheet, true)
        layerPos.X = pos.X - (frame * 1.5 * layerConf.Speed)%(600 * BG_SPRITE.Scale.X)
        layerPos.Y = pos.Y - (frame * layerConf.Speed)%(400 * BG_SPRITE.Scale.Y)
        
        for x = -1, X do
            for y = -2, Y do
                
                BG_SPRITE:Render(toMenuPos(Vector(layerPos.X + 600 * x * BG_SPRITE.Scale.X, -layerPos.Y + 400 * y * BG_SPRITE.Scale.Y)))
            end
        end
    end
end

local VIEW_POSITIONS = {
    ["Splash Screen"] = Vector.Zero,
    ["Stats"] = Vector(500, -1000)
}
local selected_menu = "Splash Screen"
local menu_switch_precent = 0
local menu_switch_timer = 0
local start_menu_pos = Vector.Zero
local target_menu_pos = Vector.Zero
local menu_switch_time = 0

---@return Vector
local function calculate_menu_view_pos()
    local current_menu_pos = VIEW_POSITIONS[selected_menu]
    if not Resouled.CompareVectors(target_menu_pos, current_menu_pos) and (menu_switch_precent == 1 or menu_switch_precent == 0) then
        
        target_menu_pos = current_menu_pos * 1
        menu_switch_timer = 0
        menu_switch_time = math.ceil(math.sqrt(target_menu_pos:Distance(start_menu_pos))/2)
    end
    
    menu_switch_precent = math.min(1, math.max(0,
        menu_switch_timer <= menu_switch_time/2 and (1 - math.log(menu_switch_time/2 - menu_switch_timer + 1, 3)/math.log(menu_switch_time/2 + 1, 3))/2
        or (1 + math.log(menu_switch_timer - menu_switch_time/2 + 1, 3)/math.log(menu_switch_time/2 + 1, 3))/2
    ))

    menu_switch_timer = math.min(menu_switch_timer + 0.125, menu_switch_time + 1)

    if menu_switch_timer == menu_switch_time + 1 then
        start_menu_pos = target_menu_pos * 1
    end

    return start_menu_pos + (target_menu_pos - start_menu_pos) * menu_switch_precent
end

local function menuRender()

    local menu = MenuManager.GetActiveMenu()

    if not transitioning then
        if menu == MainMenuType.GAME and Resouled:HasAnyoneTriggeredAction(ButtonAction.ACTION_BOMB) then
            Resouled.SfxM:Play(SoundEffect.SOUND_BOOK_PAGE_TURN_12)
            
            transition_time = 0
            transitioning = true
            transition_speed = 1
        elseif menu == MENU_TYPE and Resouled:HasAnyoneTriggeredAction(ButtonAction.ACTION_MENUBACK) then
            
            Resouled.SfxM:Play(SoundEffect.SOUND_BOOK_PAGE_TURN_12)
            Resouled.Save:ForceSave()
            
            transition_time = TRANSITION_TIME + 0
            transitioning = true
            transition_speed = -1
        end
    end

    if menu == MENU_TYPE then

        if Resouled:HasAnyoneTriggeredAction(ButtonAction.ACTION_PILLCARD) then
            selected_menu = selected_menu == "Splash Screen" and "Stats" or "Splash Screen"

            Resouled.SfxM:Play(SoundEffect.SOUND_CHARACTER_SELECT_LEFT)
        elseif Resouled:HasAnyoneTriggeredAction(ButtonAction.ACTION_BOMB) then
            selected_menu = selected_menu == "Splash Screen" and "Stats" or "Splash Screen"

            Resouled.SfxM:Play(SoundEffect.SOUND_CHARACTER_SELECT_RIGHT)
        end


        if not transitioning or (transition_speed == 1 and transition_time or transition_time) > TRANSITION_TIME/2 then
            
            Resouled:OverlayScreen(KColor.Black)
            renderPlanetarium()
            MenuManager.SetViewPosition(calculate_menu_view_pos())

            Isaac.RunCallback(Resouled.Callbacks.PostResouledMenuBackgroundRender)
        end
    end

    if transitioning then

        transition()
        transition_time = transition_time + transition_speed

        if transition_time == math.floor(transition_speed == 1 and TRANSITION_TIME/3 or TRANSITION_TIME/3 * 2) then
            ---@diagnostic disable-next-line
            MenuManager.SetActiveMenu(menu == MENU_TYPE and MainMenuType.GAME or MENU_TYPE)
        end
        
        if transition_time == (transition_speed == 1 and TRANSITION_TIME or 0) then
            transitioning = false
        end
    end
end
Resouled:AddPriorityCallback(ModCallbacks.MC_MAIN_MENU_RENDER, CallbackPriority.LATE, menuRender)

local FLOAT_SPEED = 35
local FLOAT_STRENGTH = 10
local LOGO_SPRITE = Sprite()
LOGO_SPRITE:Load("gfx_resouled/menu/resouled_logo.anm2", true)
LOGO_SPRITE:Play("Idle", true)
LOGO_SPRITE.Scale = Vector(0.65, 0.65)

local STATS_SPRITE = Sprite()
STATS_SPRITE:Load("gfx_resouled/menu/stats.anm2", true)
STATS_SPRITE:Play("Idle", true)

local FONT = Font()
FONT:Load("font/upheaval.fnt")

local function postBackgroundRender()

    MenuManager.GetShadowSprite().Color.A = transitioning and 1 - (transition_time/TRANSITION_TIME) or 0

    local pos = Resouled.Screen()/2
    local frame = Isaac.GetFrameCount()/FLOAT_SPEED

    pos.X = pos.X
    pos.Y = pos.Y - 75

    LOGO_SPRITE.Color = Color(0, 0, 0, 0.10)
    LOGO_SPRITE:Render(toMenuPos(pos + Vector(0, math.sin(frame - 50/FLOAT_SPEED) * FLOAT_STRENGTH)))

    LOGO_SPRITE.Color = Color(0.25, 0.25, 0.25, 0.35)
    LOGO_SPRITE:Render(toMenuPos(pos + Vector(0, math.sin(frame - 25/FLOAT_SPEED) * FLOAT_STRENGTH)))

    LOGO_SPRITE.Color = Color()
    LOGO_SPRITE:Render(toMenuPos(pos + Vector(0, math.sin(frame) * FLOAT_STRENGTH)))
    
    local statsPos = VIEW_POSITIONS["Stats"] * 1
    statsPos.Y = -statsPos.Y
    STATS_SPRITE:Render(toMenuPos(statsPos + Resouled.Screen()/2))

    --local cursorPos = Isaac.WorldToScreen(Input.GetMousePosition(true))
    --FONT:DrawString("o", cursorPos.X - FONT:GetStringWidth('o')/2, cursorPos.Y - FONT:GetBaselineHeight()/2 - 3, KColor.White)
end
Resouled:AddCallback(Resouled.Callbacks.PostResouledMenuBackgroundRender, postBackgroundRender)