-- Central gameplay constants. Tuning knobs for the whole game.

local Config = {}

-- Logical resolution; the real window is letterboxed onto this canvas.
-- Wide enough that every language button label fits on a single line.
Config.screen = { width = 600, height = 800 }

Config.block = {
    startWidth = 150,   -- width of the first block
    height = 40,        -- every floor is this tall
    minWidth = 20,      -- a slimmer overlap counts as a miss
}

Config.base = { width = 220, height = 26 } -- concrete pad the tower stands on

Config.crane = {
    ropeLength = 90,      -- cable length under the beam
    amplitudeRatio = 0.36, -- swing amplitude as a fraction of screen width
    baseSpeed = 2.1,      -- swing speed (rad/s) on floor 0
    speedPerFloor = 0.06, -- difficulty ramp per placed floor
    maxSpeedBonus = 2.4,  -- cap for the ramp
}

Config.physics = { gravity = 2400 } -- px/s^2 for falling blocks

Config.gameplay = {
    lives = 3,
    perfectThreshold = 7,  -- px: drop within this offset = perfect
    perfectRestore = 10,   -- px of width given back on a perfect drop
    cameraAnchor = 0.60,   -- screen fraction where the tower top tries to sit
    cameraLerp = 3.5,      -- camera smoothing speed
}

return Config
