local font = Font()
font:Load("font/terminus.fnt")

local color = KColor(1, 0, 0, 1)

local text = {
    "Hi! If you're seeing this",
    "you're probably thinking:",
    "''How can I get rid of this annoying text?'',",
    "so here's your answer:",
    "Since it's your first time playing Resouled,",
    "we wanted to inform you,",
    "That we have our own menu in the main menu!",
    "To get to it, go into stats",
    "and press bomb place button,",
    "there find the options page, and disable the",
    "''Start Notification'' option.",
    "Have fun playing our mod!"
}

local function postRender()
    local save = Resouled:GetOptionsSave()
    if save and save[tostring(1)] == "True" then
        local pos = Vector(Isaac.GetScreenWidth()/2, 25)
        local separation = font:GetBaselineHeight() + 5
        for _, string in ipairs(text) do
            font:DrawStringScaled(string, pos.X, pos.Y, 1, 1, color, font:GetStringWidth(string)/2)
            pos.Y = pos.Y + separation
        end
    else
        Resouled:RemoveCallback(ModCallbacks.MC_POST_RENDER, postRender)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_RENDER, postRender)