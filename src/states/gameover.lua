-- Game over screen: final stats, best score, restart options.

local Config = require("src.config")
local Scene = require("src.scene_manager")
local Sfx = require("src.sfx")
local I18n = require("src.i18n")

local W, H = Config.screen.width, Config.screen.height

local GameOver = {
    floors = 0,
    score = 0,
    best = 0,
    newBest = false,
    time = 0,
}

function GameOver.enter(params)
    GameOver.floors = params.floors or 0
    GameOver.score = params.score or 0
    GameOver.best = params.best or 0
    GameOver.newBest = params.newBest or false
    GameOver.time = 0
end

function GameOver.update(dt)
    GameOver.time = GameOver.time + dt
end

function GameOver.draw()
    love.graphics.setColor(0.07, 0.08, 0.16)
    love.graphics.rectangle("fill", 0, 0, W, H)

    GameOver.fontBig = GameOver.fontBig or I18n.font(44)
    GameOver.fontMedium = GameOver.fontMedium or I18n.font(20)
    GameOver.fontSmall = GameOver.fontSmall or I18n.font(14)

    love.graphics.setFont(GameOver.fontBig)
    love.graphics.setColor(0.95, 0.35, 0.35)
    love.graphics.printf(I18n.t("over.title"), 0, 170, W, "center")

    love.graphics.setFont(GameOver.fontMedium)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(I18n.tf("over.height", I18n.floorsText(GameOver.floors)), 0, 280, W, "center")
    love.graphics.printf(I18n.tf("over.score", GameOver.score), 0, 315, W, "center")

    if GameOver.newBest then
        local pulse = 0.7 + 0.3 * math.sin(GameOver.time * 6)
        love.graphics.setColor(1, 0.85, 0.3, pulse)
        love.graphics.printf(I18n.t("over.newBest"), 0, 365, W, "center")
    else
        love.graphics.setColor(1, 1, 1, 0.75)
        love.graphics.printf(I18n.tf("over.best", I18n.floorsText(GameOver.best)), 0, 365, W, "center")
    end

    if math.sin(GameOver.time * 4) > -0.4 then
        love.graphics.setFont(GameOver.fontSmall)
        love.graphics.setColor(1, 1, 0.75)
        love.graphics.printf(I18n.t("over.prompt"), 0, 470, W, "center")
    end
end

function GameOver.restart()
    Sfx.play("ui")
    Scene.switch("game")
end

function GameOver.keypressed(key)
    if key == "space" or key == "return" then
        GameOver.restart()
    elseif key == "escape" then
        Scene.switch("menu")
    end
end

function GameOver.mousepressed(_x, _y, button)
    if button == 1 then
        GameOver.restart()
    end
end

return GameOver
