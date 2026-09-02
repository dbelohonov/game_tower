-- Vertical camera. World coordinates: the ground surface is y = 0,
-- the tower grows upwards into negative y. Screen y = world y + camera.y.

local Config = require("src.config")
local H = Config.screen.height

local Camera = {}
Camera.__index = Camera

local GROUND_CAM_Y = H - 140 -- camera y while the tower is still short

function Camera.new()
    local self = setmetatable({}, Camera)
    self.y = GROUND_CAM_Y
    self.shakeTime = 0
    self.shakeMag = 0
    return self
end

-- towerTopY: world y of the current top surface of the stack.
function Camera:update(dt, towerTopY)
    local anchor = H * Config.gameplay.cameraAnchor
    local target = math.max(GROUND_CAM_Y, anchor - towerTopY)
    local k = math.min(1, Config.gameplay.cameraLerp * dt)
    self.y = self.y + (target - self.y) * k
    self.shakeTime = math.max(0, self.shakeTime - dt)
end

-- Call inside a push/pop; translates world -> screen.
function Camera:apply()
    local ox, oy = 0, 0
    if self.shakeTime > 0 then
        local m = self.shakeMag * (self.shakeTime / 0.35)
        ox = (love.math.random() * 2 - 1) * m
        oy = (love.math.random() * 2 - 1) * m
    end
    love.graphics.translate(ox, math.floor(self.y) + oy)
end

function Camera:shake(mag, duration)
    self.shakeMag = mag
    self.shakeTime = duration
end

return Camera
