-- Letterboxing helper: maps the real window onto the fixed logical canvas.
--
-- The view always fills the window height, so there are never empty bars
-- above or below the game; horizontally the logical canvas stays centred,
-- leaving equally wide margins left and right on wider windows.  Narrower
-- (portrait) windows show a centred slice of the logical canvas instead of
-- growing top/bottom bars.  Screen.viewX0/viewX1 are the logical x edges
-- actually visible, for UI that anchors to the screen sides.

local Config = require("src.config")

local Screen = {
    scale = 1,
    offsetX = 0,
    offsetY = 0,
    viewX0 = 0, -- leftmost visible logical x
    viewX1 = Config.screen.width, -- rightmost visible logical x
    winW = 0,
    winH = 0,
}

function Screen.init()
    Screen.resize(love.graphics.getWidth(), love.graphics.getHeight())
end

function Screen.resize(w, h)
    local cw, ch = Config.screen.width, Config.screen.height
    Screen.scale = h / ch
    Screen.offsetX = (w - cw * Screen.scale) / 2
    Screen.offsetY = 0
    Screen.viewX0 = -Screen.offsetX / Screen.scale
    Screen.viewX1 = Screen.viewX0 + w / Screen.scale
    Screen.winW, Screen.winH = w, h
end

-- Visible logical x range, clamped to the logical canvas (UI anchors).
function Screen.visibleLeft()
    return math.max(Screen.viewX0, 0)
end

function Screen.visibleRight()
    return math.min(Screen.viewX1, Config.screen.width)
end

-- Clears the window, sets the scissor to the game area and applies the transform.
function Screen.apply()
    local w, h = love.graphics.getDimensions()
    -- Self-heal: some resizes (love.window.setMode, browser canvas changes)
    -- do not deliver a love.resize event before the next draw.
    if w ~= Screen.winW or h ~= Screen.winH then
        Screen.resize(w, h)
    end
    love.graphics.origin()
    love.graphics.setScissor(0, 0, w, h)
    love.graphics.setColor(0.05, 0.05, 0.08)
    love.graphics.rectangle("fill", 0, 0, w, h)

    -- Clip to the part of the logical canvas that is on screen (the whole
    -- window for portrait slices, the centred column otherwise).
    local x0 = math.max(Screen.offsetX, 0)
    local x1 = math.min(Screen.offsetX + Config.screen.width * Screen.scale, w)
    love.graphics.setScissor(x0, 0, x1 - x0, h)
    love.graphics.translate(Screen.offsetX, Screen.offsetY)
    love.graphics.scale(Screen.scale)
end

-- Real window pixel -> logical game coordinates.
function Screen.toGame(x, y)
    return (x - Screen.offsetX) / Screen.scale, (y - Screen.offsetY) / Screen.scale
end

return Screen
