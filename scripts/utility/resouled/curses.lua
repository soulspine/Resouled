---@param curse ResouledCurses
---@return boolean
function Resouled:CustomCursePresent(curse)

    if curse == -1 then
        return false
    end

    local curseShifted = 1 << (curse - 1)
    return Game():GetLevel():GetCurses() & curseShifted == curseShifted
end

---@param curses? LevelCurse
function Resouled:GetCursesNum(curses)
    curses = curses or Game():GetLevel():GetCurses()
    local curseCount = 0
    for i = 0, 31 do
        if (curses & (1 << i)) ~= 0 then
            curseCount = curseCount + 1
        end
    end
    return curseCount
end