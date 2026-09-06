-- Title screen with a little animated diorama and a language selector.

local Config = require("src.config")
local Scene = require("src.scene_manager")
local Save = require("src.save")
local Sfx = require("src.sfx")
local Blocks = require("src.blocks")
local I18n = require("src.i18n")

local W, H = Config.screen.width, Config.screen.height

local Menu = { time = 0, best = 0 }

---------------------------------------------------------------------------
-- language selector layout
---------------------------------------------------------------------------

local function languageButtons()
    local codes = I18n.languages
    local bw, bh, gap = 82, 34, 6
    local total = #codes * bw + (#codes - 1) * gap
    local x0 = (W - total) / 2
    local y = H - 110
    local buttons = {}
    for i, code in ipairs(codes) do
        buttons[i] = {
            code = code,
            x = x0 + (i - 1) * (bw + gap),
            y = y,
            w = bw,
            h = bh,
        }
    end
    return buttons
end

local function buttonAt(x, y)
    for _, b in ipairs(languageButtons()) do
        if x >= b.x and x <= b.x + b.w and y >= b.y and y <= b.y + b.h then
            return b
        end
    end
    return nil
end

---------------------------------------------------------------------------
-- lifecycle
---------------------------------------------------------------------------

function Menu.enter()
    Menu.time = 0
    Menu.best = Save.loadBest()
end

function Menu.update(dt)
    Menu.time = Menu.time + dt
end

---------------------------------------------------------------------------
-- draw
---------------------------------------------------------------------------

function Menu.draw()
    -- gradient sky
    local bands = 14
    for i = 0, bands - 1 do
        local t = i / bands
        love.graphics.setColor(0.33 + 0.45 * t, 0.62 + 0.29 * t, 0.93 + 0.07 * t)
        love.graphics.rectangle("fill", 0, t * H, W, H / bands + 1)
    end

    -- ground
    love.graphics.setColor(0.42, 0.66, 0.36)
    love.graphics.rectangle("fill", 0, H - 90, W, 90)
    love.graphics.setColor(0.45, 0.33, 0.24)
    love.graphics.rectangle("fill", 0, H - 82, W, 82)

    -- demo tower
    for i = 1, 4 do
        Blocks.draw(W / 2 - 75 + math.sin(Menu.time * 1.2 + i) * 3, H - 90 - i * 40, 150, i - 1)
    end

    -- swinging crane diorama
    local swing = math.sin(Menu.time * 1.6) * 120
    love.graphics.setColor(0.28, 0.30, 0.36)
    love.graphics.rectangle("fill", -50, 40, W + 100, 14)
    love.graphics.setColor(0.6, 0.6, 0.66)
    love.graphics.setLineWidth(2)
    love.graphics.line(W / 2 + swing, 54, W / 2 + swing, 150)
    Blocks.draw(W / 2 + swing - 55, 150, 110, 4)

    Menu.fontTitle = Menu.fontTitle or I18n.font(52)
    Menu.fontMedium = Menu.fontMedium or I18n.font(18)
    Menu.fontSmall = Menu.fontSmall or I18n.font(14)

    -- title
    love.graphics.setFont(Menu.fontTitle)
    love.graphics.setColor(0.15, 0.18, 0.30, 0.5)
    love.graphics.printf("TOWER BLOXX", 3, 223, W, "center")
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("TOWER BLOXX", 0, 220, W, "center")
    love.graphics.setFont(Menu.fontSmall)
    love.graphics.setColor(1, 1, 1, 0.85)
    love.graphics.printf(I18n.t("menu.subtitle"), 0, 288, W, "center")

    -- blinking prompt
    if math.sin(Menu.time * 4) > -0.4 then
        love.graphics.setFont(Menu.fontMedium)
        love.graphics.setColor(1, 1, 0.75)
        love.graphics.printf(I18n.t("menu.pressStart"), 0, 420, W, "center")
    end

    love.graphics.setFont(Menu.fontSmall)
    love.graphics.setColor(1, 1, 1, 0.85)
    love.graphics.printf(
        I18n.t("menu.hintDrop") .. "\n" .. I18n.t("menu.hintStack") .. "\n" .. I18n.t("menu.hintKeys"),
        0, 490, W, "center")

    if Menu.best > 0 then
        love.graphics.setFont(Menu.fontMedium)
        love.graphics.setColor(1, 0.9, 0.4)
        love.graphics.printf(I18n.tf("menu.best", I18n.floorsText(Menu.best)), 0, 580, W, "center")
    end

    Menu.drawLanguageSelector()
end

function Menu.drawLanguageSelector()
    local btns = languageButtons()
    local labelY = btns[1].y - 30

    local label = I18n.t("menu.language") .. "   (LEFT / RIGHT)"
    love.graphics.setFont(Menu.fontSmall)
    love.graphics.setColor(0.1, 0.12, 0.2, 0.6)
    love.graphics.printf(label, 1, labelY + 1, W, "center")
    love.graphics.setColor(1, 1, 1, 0.85)
    love.graphics.printf(label, 0, labelY, W, "center")

    for _, b in ipairs(btns) do
        local active = b.code == I18n.current
        if active then
            love.graphics.setColor(1, 0.85, 0.35, 0.30)
        else
            love.graphics.setColor(0.10, 0.14, 0.28, 0.45)
        end
        love.graphics.rectangle("fill", b.x, b.y, b.w, b.h, 6, 6)

        if active then
            love.graphics.setColor(1, 0.85, 0.35)
        else
            love.graphics.setColor(1, 1, 1, 0.55)
        end
        love.graphics.setLineWidth(active and 2 or 1)
        love.graphics.rectangle("line", b.x, b.y, b.w, b.h, 6, 6)

        love.graphics.setFont(Menu.fontSmall)
        if active then
            love.graphics.setColor(1, 1, 1)
        else
            love.graphics.setColor(1, 1, 1, 0.8)
        end
        love.graphics.printf(I18n.names[b.code], b.x, b.y + (b.h - Menu.fontSmall:getHeight()) / 2,
            b.w, "center")
    end
end

---------------------------------------------------------------------------
-- input
---------------------------------------------------------------------------

function Menu.start()
    Sfx.play("ui")
    Scene.switch("game")
end

function Menu.keypressed(key)
    if key == "space" or key == "return" then
        Menu.start()
    elseif key == "escape" then
        love.event.quit()
    elseif key == "left" then
        I18n.cycle(-1)
        Sfx.play("ui")
    elseif key == "right" then
        I18n.cycle(1)
        Sfx.play("ui")
    end
end

function Menu.mousepressed(x, y, button)
    if button == 1 then
        local b = buttonAt(x, y)
        if b then
            I18n.setLanguage(b.code)
            Sfx.play("ui")
            return
        end
        Menu.start()
    end
end

return Menu
