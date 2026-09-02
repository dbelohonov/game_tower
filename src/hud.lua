-- Heads-up display: floors, score, lives, combo, hints.
-- Drawn in screen space (after the camera transform is popped).

local Config = require("src.config")
local Sfx = require("src.sfx")

local W, H = Config.screen.width, Config.screen.height

local Hud = {}
Hud.__index = Hud

function Hud.new()
    local self = setmetatable({}, Hud)
    self.fontBig = love.graphics.newFont(26)
    self.fontMedium = love.graphics.newFont(18)
    self.fontSmall = love.graphics.newFont(13)
    return self
end

local function shadowPrint(text, x, y, font, ox)
    love.graphics.setFont(font)
    love.graphics.setColor(0, 0, 0, 0.45)
    love.graphics.print(text, x + 2, y + 2, 0, 1, 1, ox or 0, 0)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(text, x, y, 0, 1, 1, ox or 0, 0)
end

local function drawHeart(x, y, r, filled)
    if filled then
        love.graphics.setColor(0.93, 0.30, 0.38)
    else
        love.graphics.setColor(0.35, 0.35, 0.40)
    end
    love.graphics.circle("fill", x - r * 0.5, y, r * 0.55)
    love.graphics.circle("fill", x + r * 0.5, y, r * 0.55)
    love.graphics.polygon("fill",
        x - r * 1.0, y + r * 0.1,
        x + r * 1.0, y + r * 0.1,
        x, y + r * 1.35)
end

function Hud:draw(game)
    shadowPrint(string.format("FLOORS  %d", game.tower:height()), 14, 12, self.fontBig)
    shadowPrint(string.format("SCORE  %d", game.score), 14, 44, self.fontMedium)

    if game.combo > 1 then
        love.graphics.setColor(1, 0.85, 0.3)
        love.graphics.setFont(self.fontSmall)
        love.graphics.print(string.format("PERFECT COMBO x%d", game.combo), 14, 68)
    end

    for i = 1, Config.gameplay.lives do
        drawHeart(W - 24 - (Config.gameplay.lives - i) * 30, 26, 11, i <= game.lives)
    end

    if game.drops == 0 then
        local a = 0.55 + 0.45 * math.sin(game.time * 5)
        love.graphics.setColor(1, 1, 1, a)
        love.graphics.setFont(self.fontMedium)
        love.graphics.printf("SPACE / CLICK - drop the block!", 0, H - 60, W, "center")
    end

    if not Sfx.enabled then
        love.graphics.setColor(1, 1, 1, 0.6)
        love.graphics.setFont(self.fontSmall)
        love.graphics.print("MUTED (M)", 14, H - 26)
    end
end

return Hud
