-- Tower Bloxx - a tribute to the classic Nokia stacking game.
-- LOVE entry point: wires LOVE callbacks into the scene manager.

local Scene = require("src.scene_manager")
local Screen = require("src.screen")
local Sfx = require("src.sfx")

Scene.register("menu", require("src.states.menu"))
Scene.register("game", require("src.states.game"))
Scene.register("gameover", require("src.states.gameover"))

function love.load()
    math.randomseed(os.time())
    love.math.setRandomSeed(os.time())
    Screen.init()
    Sfx.init()
    Scene.switch("menu")
end

function love.resize(w, h)
    Screen.resize(w, h)
end

function love.update(dt)
    -- Clamp dt so physics stay sane after window drags / hitches.
    dt = math.min(dt, 1 / 30)
    Scene.update(dt)
end

function love.draw()
    Screen.apply()
    Scene.draw()
end

function love.keypressed(key)
    Scene.keypressed(key)
end

function love.mousepressed(x, y, button)
    local gx, gy = Screen.toGame(x, y)
    Scene.mousepressed(gx, gy, button)
end

function love.touchpressed(_id, x, y)
    local gx, gy = Screen.toGame(x, y)
    Scene.mousepressed(gx, gy, 1)
end
