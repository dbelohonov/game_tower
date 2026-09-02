-- Letterboxing helper: maps the real window onto the fixed logical canvas.

local Config = require("src.config")

local Screen = {
    scale = 1,
    offsetX = 0,
    offsetY = 0,
}

function Screen.init()
    Screen.resize(love.graphics.getWidth(), love.graphics.getHeight())
end

function Screen.resize(w, h)
    local cw, ch = Config.screen.width, Config.screen.height
    Screen.scale = math.min(w / cw, h / ch)
    Screen.offsetX = (w - cw * Screen.scale) / 2
    Screen.offsetY = (h - ch * Screen.scale) / 2
end

-- Clears the window, sets the scissor to the game area and applies the transform.
function Screen.apply()
    local w, h = love.graphics.getDimensions()
    love.graphics.origin()
    love.graphics.setScissor(0, 0, w, h)
    love.graphics.setColor(0.05, 0.05, 0.08)
    love.graphics.rectangle("fill", 0, 0, w, h)

    love.graphics.setScissor(
        Screen.offsetX, Screen.offsetY,
        Config.screen.width * Screen.scale,
        Config.screen.height * Screen.scale
    )
    love.graphics.translate(Screen.offsetX, Screen.offsetY)
    love.graphics.scale(Screen.scale)
end

-- Real window pixel -> logical game coordinates.
function Screen.toGame(x, y)
    return (x - Screen.offsetX) / Screen.scale, (y - Screen.offsetY) / Screen.scale
end

return Screen
