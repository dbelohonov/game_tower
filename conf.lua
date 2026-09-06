-- LOVE configuration file.
-- Loaded by LOVE before main.lua; controls window and module settings.

function love.conf(t)
    t.identity = "tower-bloxx"       -- save directory name (best scores)
    t.version = "11.4"               -- target LOVE version
    t.title = "Tower Bloxx"
    t.window.width = 540
    t.window.height = 900
    t.window.minwidth = 360
    t.window.minheight = 600
    t.window.resizable = true
    t.window.vsync = 1
    t.window.usedpi = true
    t.console = false

    -- Unused modules, disabled for a faster startup.
    t.modules.joystick = false
    t.modules.physics = false
    t.modules.video = false
end
