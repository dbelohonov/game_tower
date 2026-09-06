-- Core gameplay scene: swing, drop, land, repeat.
-- A dropped block keeps only the part overlapping the block below;
-- an overlap thinner than minWidth (or none at all) is a miss.

local Config = require("src.config")
local Scene = require("src.scene_manager")
local Tower = require("src.tower")
local Crane = require("src.crane")
local Camera = require("src.camera")
local Background = require("src.background")
local Hud = require("src.hud")
local Blocks = require("src.blocks")
local Sfx = require("src.sfx")
local Save = require("src.save")
local I18n = require("src.i18n")

local W, H = Config.screen.width, Config.screen.height
local GRAVITY = Config.physics.gravity

local Game = {}

---------------------------------------------------------------------------
-- lifecycle
---------------------------------------------------------------------------

function Game.enter(_params)
    Game.tower = Tower.new()
    Game.camera = Camera.new()
    Game.background = Background.new()
    Game.hud = Hud.new()
    Game.score = 0
    Game.combo = 0
    Game.lives = Config.gameplay.lives
    Game.time = 0
    Game.paused = false
    Game.over = false
    Game.drops = 0
    Game.debris = {}  -- missed blocks tumbling away
    Game.popups = {}  -- floating texts ("PERFECT +5", "MISS")
    Game.currentWidth = Config.block.startWidth
    Game.spawnCrane()
end

function Game.spawnCrane()
    Game.crane = Crane.new(Game.currentWidth, Game.tower:height())
end

function Game.towerTopY()
    return -Game.tower:height() * Config.block.height
end

---------------------------------------------------------------------------
-- input
---------------------------------------------------------------------------

function Game.tryDrop()
    if Game.paused or Game.over then
        return
    end
    if Game.crane and Game.crane.phase == "swing" then
        Game.crane:drop()
        Game.drops = Game.drops + 1
    end
end

function Game.keypressed(key)
    if key == "escape" then
        Scene.switch("menu")
    elseif key == "m" then
        Sfx.toggle()
    elseif key == "p" then
        Game.paused = not Game.paused
    elseif key == "space" or key == "return" then
        Game.tryDrop()
    end
end

function Game.mousepressed(_x, _y, button)
    if button == 1 then
        Game.tryDrop()
    end
end

---------------------------------------------------------------------------
-- helpers
---------------------------------------------------------------------------

function Game.addPopup(text, x, y, color)
    table.insert(Game.popups, {
        text = text, x = x, y = y,
        ttl = 1.1, maxTtl = 1.1, color = color,
    })
end

---------------------------------------------------------------------------
-- landing resolution
---------------------------------------------------------------------------

function Game.resolveLanding()
    local crane = Game.crane
    local topX, topW, surfaceY = Game.tower:topSurface()
    local left = crane:blockLeft()
    local w = crane.blockW
    local oLeft = math.max(left, topX)
    local overlap = math.min(left + w, topX + topW) - oLeft

    if overlap < Config.block.minWidth then
        Game.registerMiss(left, w, surfaceY, crane)
        return
    end

    local perfect = math.abs(left - topX) <= Config.gameplay.perfectThreshold
    if perfect then
        -- snap into place and win a bit of width back
        left = topX
        w = math.min(w + Config.gameplay.perfectRestore, Config.block.startWidth)
        Game.combo = Game.combo + 1
        local bonus = 5 * Game.combo
        Game.score = Game.score + 10 + bonus
        Sfx.play("perfect")
        local text = Game.combo > 1
            and string.format("%s x%d  +%d", I18n.t("game.perfect"), Game.combo, bonus)
            or string.format("%s  +%d", I18n.t("game.perfect"), bonus)
        Game.addPopup(text, crane.blockX, surfaceY - 70, { 1, 0.88, 0.35 })
    else
        -- keep only the overlapping part
        left = oLeft
        w = overlap
        Game.combo = 0
        Game.score = Game.score + 10
        Sfx.play("land")
    end

    Game.tower:addBlock(left, w)
    Game.currentWidth = w
    Game.camera:shake(2.5, 0.12)
    Game.spawnCrane()
end

function Game.registerMiss(left, w, surfaceY, crane)
    local centerX = left + w / 2
    local fallsLeft = centerX < W / 2
    table.insert(Game.debris, {
        cx = centerX,
        y = surfaceY - Config.block.height,
        w = w,
        vx = fallsLeft and -70 or 70,
        vy = crane.vy * 0.5,
        rot = 0,
        vrot = fallsLeft and -1.6 or 1.6,
        age = 0,
        colorIndex = Game.tower:height(),
    })

    Game.lives = Game.lives - 1
    Game.combo = 0
    Game.camera:shake(9, 0.35)
    Sfx.play("miss")
    Game.addPopup(I18n.t("game.miss"), crane.blockX, surfaceY - 60, { 1, 0.4, 0.4 })

    if Game.lives <= 0 then
        Game.finish()
    else
        Game.spawnCrane()
    end
end

function Game.finish()
    Game.over = true
    Sfx.play("gameover")
    local floors = Game.tower:height()
    local best = Save.loadBest()
    local newBest = floors > best
    if newBest then
        Save.storeBest(floors)
        best = floors
    end
    Scene.switch("gameover", {
        floors = floors,
        score = Game.score,
        best = best,
        newBest = newBest,
    })
end

---------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------

function Game.update(dt)
    Game.time = Game.time + dt
    if Game.paused then
        return
    end

    Game.background:update(dt)
    local topY = Game.towerTopY()
    Game.camera:update(dt, topY)

    if not Game.over then
        Game.crane:update(dt, topY)
        if Game.crane.phase == "fall" then
            local _tx, _tw, surfaceY = Game.tower:topSurface()
            if Game.crane:blockBottomY() >= surfaceY then
                Game.resolveLanding()
            end
        end
    end

    -- debris
    for i = #Game.debris, 1, -1 do
        local d = Game.debris[i]
        d.vy = d.vy + GRAVITY * dt
        d.y = d.y + d.vy * dt
        d.cx = d.cx + d.vx * dt
        d.rot = d.rot + d.vrot * dt
        d.age = d.age + dt
        if d.age > 2.4 or (d.y + Game.camera.y) > H + 150 then
            table.remove(Game.debris, i)
        end
    end

    -- popups
    for i = #Game.popups, 1, -1 do
        local p = Game.popups[i]
        p.ttl = p.ttl - dt
        p.y = p.y - 45 * dt
        if p.ttl <= 0 then
            table.remove(Game.popups, i)
        end
    end
end

---------------------------------------------------------------------------
-- draw
---------------------------------------------------------------------------

function Game.draw()
    Game.background:draw(Game.camera, Game.tower:height(), Game.time)

    love.graphics.push()
    Game.camera:apply()

    -- ground
    love.graphics.setColor(0.45, 0.33, 0.24)
    love.graphics.rectangle("fill", -W, 0, W * 3, 700)
    love.graphics.setColor(0.42, 0.66, 0.36)
    love.graphics.rectangle("fill", -W, 0, W * 3, 8)

    Game.tower:draw(Game.time)

    -- debris
    for _, d in ipairs(Game.debris) do
        local alpha = 1
        if d.age > 1.6 then
            alpha = math.max(0, (2.4 - d.age) / 0.8)
        end
        love.graphics.push()
        love.graphics.translate(d.cx, d.y + Config.block.height / 2)
        love.graphics.rotate(d.rot)
        Blocks.draw(-d.w / 2, -Config.block.height / 2, d.w, d.colorIndex, alpha)
        love.graphics.pop()
    end

    if not Game.over then
        Game.crane:draw(Game.tower:height())
    end

    -- popups
    love.graphics.setFont(Game.hud.fontMedium)
    for _, p in ipairs(Game.popups) do
        local a = math.min(1, p.ttl / (p.maxTtl * 0.5))
        love.graphics.setColor(0, 0, 0, 0.4 * a)
        love.graphics.printf(p.text, p.x - 120 + 2, p.y + 2, 240, "center")
        love.graphics.setColor(p.color[1], p.color[2], p.color[3], a)
        love.graphics.printf(p.text, p.x - 120, p.y, 240, "center")
    end

    love.graphics.pop()

    Game.hud:draw(Game)

    if Game.paused then
        love.graphics.setColor(0, 0, 0, 0.55)
        love.graphics.rectangle("fill", 0, 0, W, H)
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(Game.hud.fontBig)
        love.graphics.printf(I18n.t("game.paused"), 0, H * 0.42, W, "center")
        love.graphics.setFont(Game.hud.fontSmall)
        love.graphics.setColor(1, 1, 1, 0.85)
        love.graphics.printf(I18n.t("game.pausedHint"), 0, H * 0.42 + 60, W, "center")
    end
end

return Game
