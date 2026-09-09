-- Sky, sun, clouds and stars. The sky darkens towards "space" as the
-- tower grows; clouds drift down with parallax as the camera climbs.

local Config = require("src.config")

local W, H = Config.screen.width, Config.screen.height

-- Day sky is kept fairly dark/desaturated so the HUD text stays readable.
local SKY_TOP_DAY = { 0.16, 0.38, 0.64 }
local SKY_BOTTOM_DAY = { 0.48, 0.62, 0.78 }
local SKY_TOP_SPACE = { 0.04, 0.05, 0.15 }
local SKY_BOTTOM_SPACE = { 0.20, 0.24, 0.45 }

local Background = {}
Background.__index = Background

local function lerp(a, b, t)
    return a + (b - a) * t
end

local function lerpColor(c1, c2, t)
    return { lerp(c1[1], c2[1], t), lerp(c1[2], c2[2], t), lerp(c1[3], c2[3], t) }
end

function Background.new()
    local self = setmetatable({}, Background)
    self.baseCamY = H - 140 -- camera y at ground level (see camera.lua)
    self.clouds = {}
    for _ = 1, 9 do
        table.insert(self.clouds, {
            x = love.math.random() * W,
            y = love.math.random() * H,
            w = 70 + love.math.random() * 90,
            speed = 3 + love.math.random() * 8,
            depth = 0.15 + love.math.random() * 0.35,
        })
    end
    self.stars = {}
    for _ = 1, 50 do
        table.insert(self.stars, {
            x = love.math.random() * W,
            y = love.math.random() * H,
            r = 0.6 + love.math.random() * 1.4,
            tw = love.math.random() * math.pi * 2,
        })
    end
    return self
end

function Background:update(dt)
    for _, c in ipairs(self.clouds) do
        c.x = c.x + c.speed * dt
        if c.x - c.w > W then
            c.x = -c.w
        end
    end
end

function Background:drawCloud(x, y, w, alpha)
    love.graphics.setColor(1, 1, 1, alpha)
    love.graphics.ellipse("fill", x, y, w * 0.5, w * 0.18)
    love.graphics.ellipse("fill", x - w * 0.25, y + 4, w * 0.28, w * 0.12)
    love.graphics.ellipse("fill", x + w * 0.22, y + 3, w * 0.3, w * 0.13)
end

function Background:draw(camera, floors, time)
    local alt = math.min(1, floors / 70)
    local top = lerpColor(SKY_TOP_DAY, SKY_TOP_SPACE, alt)
    local bottom = lerpColor(SKY_BOTTOM_DAY, SKY_BOTTOM_SPACE, alt)

    -- gradient sky in bands
    local bands = 14
    for i = 0, bands - 1 do
        local c = lerpColor(top, bottom, i / bands)
        love.graphics.setColor(c[1], c[2], c[3])
        love.graphics.rectangle("fill", 0, (i / bands) * H, W, H / bands + 1)
    end

    -- stars fade in near "space"
    if alt > 0.45 then
        local starAlpha = (alt - 0.45) / 0.55
        for _, s in ipairs(self.stars) do
            local a = starAlpha * (0.5 + 0.5 * math.sin(time * 2 + s.tw))
            love.graphics.setColor(1, 1, 1, a)
            love.graphics.circle("fill", s.x, s.y, s.r)
        end
    end

    -- sun (dimmed so it does not compete with the HUD text)
    local sunY = 110 + alt * 60
    love.graphics.setColor(1, 0.92, 0.55, 0.12)
    love.graphics.circle("fill", W * 0.78, sunY, 46)
    love.graphics.setColor(1, 0.92, 0.55, 0.55)
    love.graphics.circle("fill", W * 0.78, sunY, 34)

    -- clouds with parallax; they fade away as we reach space
    local cloudAlpha = 1 - alt
    if cloudAlpha > 0.02 then
        local rise = camera.y - self.baseCamY
        local span = H + 120
        for _, c in ipairs(self.clouds) do
            local sy = (c.y + rise * c.depth) % span - 60
            self:drawCloud(c.x, sy, c.w, 0.45 * cloudAlpha)
        end
    end
end

return Background
