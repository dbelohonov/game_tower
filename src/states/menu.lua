-- Title screen with a little animated diorama.

local Config = require("src.config")
local Scene = require("src.scene_manager")
local Save = require("src.save")
local Sfx = require("src.sfx")
local Blocks = require("src.blocks")

local W, H = Config.screen.width, Config.screen.height

local Menu = { time = 0, best = 0 }

function Menu.enter()
    Menu.time = 0
    Menu.best = Save.loadBest()
end

function Menu.update(dt)
    Menu.time = Menu.time + dt
end

function Menu.draw()
    -- gradient sky
    local bands = 14
    for i = 0, bands - 1 do
        local t = i / bands
        love.graphics.setColor(0.33 + 0.45 * t, 0.62 + 0.29 * t, 0.93 + 0.07 * t)
        love.graphics.rectangle("fill", 0, t * H, W, H / bands + 1)
    end

    -- ground
    love.graphics.setColor(0.42, 0.66, 0.36)
    love.graphics.rectangle("fill", 0, H - 90, W, 90)
    love.graphics.setColor(0.45, 0.33, 0.24)
    love.graphics.rectangle("fill", 0, H - 82, W, 82)

    -- demo tower
    for i = 1, 4 do
        Blocks.draw(W / 2 - 75 + math.sin(Menu.time * 1.2 + i) * 3, H - 90 - i * 40, 150, i - 1)
    end

    -- swinging crane diorama
    local swing = math.sin(Menu.time * 1.6) * 120
    love.graphics.setColor(0.28, 0.30, 0.36)
    love.graphics.rectangle("fill", -50, 40, W + 100, 14)
    love.graphics.setColor(0.6, 0.6, 0.66)
    love.graphics.setLineWidth(2)
    love.graphics.line(W / 2 + swing, 54, W / 2 + swing, 150)
    Blocks.draw(W / 2 + swing - 55, 150, 110, 4)

    Menu.fontTitle = Menu.fontTitle or love.graphics.newFont(52)
    Menu.fontMedium = Menu.fontMedium or love.graphics.newFont(18)
    Menu.fontSmall = Menu.fontSmall or love.graphics.newFont(14)

    -- title
    love.graphics.setFont(Menu.fontTitle)
    love.graphics.setColor(0.15, 0.18, 0.30, 0.5)
    love.graphics.printf("TOWER BLOXX", 3, 223, W, "center")
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("TOWER BLOXX", 0, 220, W, "center")
    love.graphics.setFont(Menu.fontSmall)
    love.graphics.setColor(1, 1, 1, 0.85)
    love.graphics.printf("a LOVE tribute to the Nokia classic", 0, 288, W, "center")

    -- blinking prompt
    if math.sin(Menu.time * 4) > -0.4 then
        love.graphics.setFont(Menu.fontMedium)
        love.graphics.setColor(1, 1, 0.75)
        love.graphics.printf("PRESS SPACE OR CLICK TO START", 0, 420, W, "center")
    end

    love.graphics.setFont(Menu.fontSmall)
    love.graphics.setColor(1, 1, 1, 0.85)
    love.graphics.printf(
        "SPACE / CLICK - drop the block\nstack as many floors as you can\nM - sound on/off    P - pause    ESC - quit",
        0, 490, W, "center")

    if Menu.best > 0 then
        love.graphics.setFont(Menu.fontMedium)
        love.graphics.setColor(1, 0.9, 0.4)
        love.graphics.printf(string.format("BEST: %d FLOORS", Menu.best), 0, 580, W, "center")
    end
end

function Menu.start()
    Sfx.play("ui")
    Scene.switch("game")
end

function Menu.keypressed(key)
    if key == "space" or key == "return" then
        Menu.start()
    elseif key == "escape" then
        love.event.quit()
    end
end

function Menu.mousepressed(_x, _y, button)
    if button == 1 then
        Menu.start()
    end
end

return Menu
