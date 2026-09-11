-- LOVE configuration file.
-- Loaded by LOVE before main.lua; controls window and module settings.

function love.conf(t)
    t.identity = "tower-bloxx"       -- save directory name (best scores)
    t.version = "11.4"               -- target LOVE version
    t.title = "Tower Bloxx"
    t.window.width = 675
    t.window.height = 900
    -- Kept small on purpose: the layout adapts to any aspect ratio, and on
    -- the web build SDL clamps the reported window size to these minima,
    -- which would clip narrow (phone) viewports.
    t.window.minwidth = 240
    t.window.minheight = 320
    t.window.resizable = true
    t.window.vsync = 1
    t.window.usedpi = true
    t.console = false

    -- Unused modules, disabled for a faster startup.
    t.modules.joystick = false
    t.modules.physics = false
    t.modules.video = false
end
