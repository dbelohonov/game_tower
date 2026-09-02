-- The crane: a block swings on a cable under a beam; on drop it falls
-- straight down. Two phases: "swing" and "fall".

local Config = require("src.config")
local Blocks = require("src.blocks")

local W = Config.screen.width

local Crane = {}
Crane.__index = Crane

function Crane.new(blockWidth, floors)
    local self = setmetatable({}, Crane)
    self.blockW = blockWidth
    self.phase = "swing"
    self.speed = Config.crane.baseSpeed
        + math.min(Config.crane.maxSpeedBonus, (floors or 0) * Config.crane.speedPerFloor)
    self.amplitude = math.min(W * Config.crane.amplitudeRatio, (W - blockWidth) / 2 - 6)
    self.centerX = W / 2
    self.t = love.math.random() * math.pi * 2 / self.speed -- random swing phase
    self.hookY = 0       -- beam height (world y), recomputed each update
    self.blockX = self.centerX
    self.blockTopY = 0
    self.vy = 0
    return self
end

function Crane:update(dt, towerTopY)
    -- Beam hangs a rope + block + a visible gap above the tower top.
    self.hookY = towerTopY - (Config.crane.ropeLength + Config.block.height + 36)

    if self.phase == "swing" then
        self.t = self.t + dt
        self.blockX = self.centerX + math.sin(self.t * self.speed) * self.amplitude
        self.blockTopY = self.hookY + Config.crane.ropeLength
    else
        self.vy = self.vy + Config.physics.gravity * dt
        self.blockTopY = self.blockTopY + self.vy * dt
    end
end

function Crane:drop()
    if self.phase ~= "swing" then
        return false
    end
    self.phase = "fall"
    self.vy = 0
    return true
end

function Crane:blockLeft()
    return self.blockX - self.blockW / 2
end

function Crane:blockBottomY()
    return self.blockTopY + Config.block.height
end

function Crane:draw(paletteIndex)
    -- beam with lattice and a hazard stripe
    love.graphics.setColor(0.28, 0.30, 0.36)
    love.graphics.rectangle("fill", -300, self.hookY - 16, W + 600, 16)
    love.graphics.setColor(0.95, 0.78, 0.25)
    love.graphics.rectangle("fill", -300, self.hookY - 3, W + 600, 3)
    love.graphics.setColor(0.45, 0.48, 0.55)
    love.graphics.setLineWidth(1)
    for x = 0, W, 24 do
        love.graphics.line(x, self.hookY - 16, x + 12, self.hookY)
    end

    if self.phase == "swing" then
        love.graphics.setColor(0.6, 0.6, 0.66)
        love.graphics.setLineWidth(2)
        love.graphics.line(self.blockX, self.hookY, self.blockX, self.blockTopY)
        love.graphics.setColor(0.85, 0.85, 0.9)
        love.graphics.circle("fill", self.blockX, self.blockTopY - 2, 4)
    end

    Blocks.draw(self:blockLeft(), self.blockTopY, self.blockW, paletteIndex)
end

return Crane
