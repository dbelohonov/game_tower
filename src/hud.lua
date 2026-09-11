-- Heads-up display: floors, score, lives, combo, hints.
-- Drawn in screen space (after the camera transform is popped).

local Config = require("src.config")
local Screen = require("src.screen")
local Sfx = require("src.sfx")
local Save = require("src.save")
local I18n = require("src.i18n")

local W, H = Config.screen.width, Config.screen.height

local Hud = {}
Hud.__index = Hud

function Hud.new()
    local self = setmetatable({}, Hud)
    self.fontBig = I18n.font(26)
    self.fontMedium = I18n.font(18)
    self.fontSmall = I18n.font(13)
    self.best = Save.loadBest()
    return self
end

local function shadowPrint(text, x, y, font, ox)
    love.graphics.setFont(font)
    love.graphics.setColor(0, 0, 0, 0.6)
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
    -- Anchor to the visible edges so portrait slices keep the HUD on screen.
    local left = Screen.visibleLeft() + 14
    local right = Screen.visibleRight() - 14

    shadowPrint(I18n.tf("hud.floors", game.tower:height()), left, 12, self.fontBig)
    shadowPrint(I18n.tf("hud.score", game.score), left, 44, self.fontMedium)

    if self.best > 0 then
        shadowPrint(I18n.tf("hud.best", I18n.floorsText(self.best)), left, 68, self.fontSmall)
    end

    if game.combo > 1 then
        love.graphics.setColor(1, 0.85, 0.3)
        love.graphics.setFont(self.fontSmall)
        love.graphics.print(I18n.tf("hud.combo", game.combo), left, 90)
    end

    for i = 1, Config.gameplay.lives do
        drawHeart(right - 10 - (Config.gameplay.lives - i) * 30, 26, 11, i <= game.lives)
    end

    if game.drops == 0 then
        local a = 0.55 + 0.45 * math.sin(game.time * 5)
        love.graphics.setColor(1, 1, 1, a)
        love.graphics.setFont(self.fontMedium)
        love.graphics.printf(I18n.t("hud.dropHint"),
            Screen.visibleLeft(), H - 60, Screen.visibleRight() - Screen.visibleLeft(), "center")
    end

    if not Sfx.enabled then
        love.graphics.setColor(1, 1, 1, 0.6)
        love.graphics.setFont(self.fontSmall)
        love.graphics.print(I18n.t("hud.muted"), left, H - 26)
    end
end

return Hud
