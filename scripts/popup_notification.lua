local font = Font()
font:Load("font/terminus.fnt")

local START_OFFSET = Vector(0, 50)
local color = KColor(1, 1, 1, 1)
local APPEAR_TIME = 600

local text = {
    "[Resouled]: Hi! If you're seeing this",
    "we want to inform you that we made our own",
    "page in the main menu, where you can customize",
    "your experience, and check your progress and",
    "stats of the mod.",
    "Have fun playing Resouled!"
}

local save
local function loadSave()
    local newSave = Resouled.SaveManager:GetEntireSave()["Popup Notification"]
    if not newSave then newSave = 0 end
    save = newSave

    Resouled.Save:AddToAutoSave(Resouled.SaveTypes.EntireSave, "Popup Notification", function() return save end)
end
Resouled:AddCallback(Resouled.Callbacks.OptionsLoaded, loadSave)

local function postRender()
    if not save then return end
    if save < APPEAR_TIME then
        local pos = Vector(Isaac.GetScreenWidth()/2, 25) + START_OFFSET
        local separation = font:GetBaselineHeight() + 5
        for _, string in ipairs(text) do
            font:DrawStringScaled(string, pos.X, pos.Y, 1, 1, color, font:GetStringWidth(string)/2)
            pos.Y = pos.Y + separation
        end
        save = save + 1

        local time = "This message will disappear in: "..tostring(((APPEAR_TIME - save)//60)+1).."s"

        font:DrawString(time, pos.X, pos.Y + separation, color, font:GetStringWidth(time)/2)
    else
        Resouled:RemoveCallback(ModCallbacks.MC_POST_RENDER, postRender)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_RENDER, postRender)