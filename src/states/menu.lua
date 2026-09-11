-- Title screen with a little animated diorama and a language selector.

local Config = require("src.config")
local Scene = require("src.scene_manager")
local Screen = require("src.screen")
local Sfx = require("src.sfx")
local Blocks = require("src.blocks")
local I18n = require("src.i18n")

local W, H = Config.screen.width, Config.screen.height

local Menu = { time = 0 }

---------------------------------------------------------------------------
-- language selector layout
---------------------------------------------------------------------------

-- Rows reflow to the visible width: one row when it fits, otherwise rows of
-- three (narrow portrait windows only show a slice of the logical canvas).
local function languageButtons()
    local codes = I18n.languages
    local bh, gap = 44, 8
    local avail = Screen.visibleRight() - Screen.visibleLeft() - 12
    local bw = 108
    local perRow = #codes
    if perRow * bw + (perRow - 1) * gap > avail then
        perRow = 3
        bw = math.min(bw, (avail - (perRow - 1) * gap) / perRow)
    end
    local rows = math.ceil(#codes / perRow)
    local totalH = rows * bh + (rows - 1) * gap
    local y0 = H - 76 - totalH -- block bottom sits above the "Language" label
    local buttons = {}
    for i, code in ipairs(codes) do
        local row = math.ceil(i / perRow)
        local inRow = math.min(perRow, #codes - (row - 1) * perRow)
        local slot = i - (row - 1) * perRow
        local rowW = inRow * bw + (inRow - 1) * gap
        buttons[i] = {
            code = code,
            x = (W - rowW) / 2 + (slot - 1) * (bw + gap),
            y = y0 + (row - 1) * (bh + gap),
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
end

function Menu.update(dt)
    Menu.time = Menu.time + dt
end

---------------------------------------------------------------------------
-- draw
---------------------------------------------------------------------------

function Menu.draw()
    -- gradient sky (kept dark so the white UI text stays readable)
    local bands = 14
    for i = 0, bands - 1 do
        local t = i / bands
        love.graphics.setColor(0.14 + 0.26 * t, 0.32 + 0.24 * t, 0.55 + 0.16 * t)
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

    -- swinging crane diorama; the beam sits flush against the top border
    local swing = math.sin(Menu.time * 1.6) * 120
    love.graphics.setColor(0.28, 0.30, 0.36)
    love.graphics.rectangle("fill", -50, 0, W + 100, 14)
    love.graphics.setColor(0.6, 0.6, 0.66)
    love.graphics.setLineWidth(2)
    love.graphics.line(W / 2 + swing, 14, W / 2 + swing, 110)
    Blocks.draw(W / 2 + swing - 55, 110, 110, 4)

    -- Narrow portrait slices show less than the design width: shrink the
    -- wide single-line texts so they stay inside the visible slice.
    local viewW = Screen.visibleRight() - Screen.visibleLeft()
    local shrink = math.min(1, viewW / 480)
    Menu.fontTitle = I18n.font(math.floor(52 * shrink))
    Menu.fontMedium = I18n.font(math.floor(18 * math.min(1, viewW / 360)))
    Menu.fontSmall = I18n.font(math.floor(14 * math.min(1, viewW / 360)))

    -- title
    love.graphics.setFont(Menu.fontTitle)
    love.graphics.setColor(0.15, 0.18, 0.30, 0.5)
    love.graphics.printf("TOWER BLOXX", 3, 223, W, "center")
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("TOWER BLOXX", 0, 220, W, "center")
    love.graphics.setFont(Menu.fontSmall)
    love.graphics.setColor(1, 1, 1, 0.85)
    love.graphics.printf(I18n.t("menu.subtitle"), 0, 288, W, "center")

    -- The prompt + hints group is centred between the title block and the
    -- demo tower, so the empty space above and below it stays equal.
    local subtitleY = 288
    local nameBottom = subtitleY + Menu.fontSmall:getHeight()
    local demoTop = H - 90 - 4 * 40 -- top of the highest demo block
    local pressH = Menu.fontMedium:getHeight()
    local hintsH = Menu.fontSmall:getHeight() * 3
    local innerGap = 48
    local margin = ((demoTop - nameBottom) - (pressH + innerGap + hintsH)) / 2
    local pressY = nameBottom + margin
    local hintsY = pressY + pressH + innerGap

    -- blinking prompt
    if math.sin(Menu.time * 4) > -0.4 then
        love.graphics.setFont(Menu.fontMedium)
        love.graphics.setColor(1, 1, 0.75)
        love.graphics.printf(I18n.t("menu.pressStart"), 0, pressY, W, "center")
    end

    love.graphics.setFont(Menu.fontSmall)
    love.graphics.setColor(1, 1, 1, 0.85)
    love.graphics.printf(
        I18n.t("menu.hintDrop") .. "\n" .. I18n.t("menu.hintStack") .. "\n" .. I18n.t("menu.hintKeys"),
        0, hintsY, W, "center")

    Menu.drawLanguageSelector()
end

function Menu.drawLanguageSelector()
    local btns = languageButtons()
    local labelY = btns[#btns].y + btns[#btns].h + 10

    local label = I18n.t("menu.language") .. "   (LEFT / RIGHT)"
    love.graphics.setFont(Menu.fontSmall)
    love.graphics.setColor(0.1, 0.12, 0.2, 0.6)
    love.graphics.printf(label, 1, labelY + 1, W, "center")
    love.graphics.setColor(1, 1, 1, 0.85)
    love.graphics.printf(label, 0, labelY, W, "center")

    Menu.fontButton = Menu.fontButton or I18n.font(16)

    for _, b in ipairs(btns) do
        local active = b.code == I18n.current
        if active then
            love.graphics.setColor(1, 0.85, 0.35, 0.45)
        else
            love.graphics.setColor(0.10, 0.14, 0.28, 0.70)
        end
        love.graphics.rectangle("fill", b.x, b.y, b.w, b.h, 8, 8)

        if active then
            love.graphics.setColor(1, 0.85, 0.35)
        else
            love.graphics.setColor(1, 1, 1, 0.85)
        end
        love.graphics.setLineWidth(active and 3 or 2)
        love.graphics.rectangle("line", b.x, b.y, b.w, b.h, 8, 8)

        love.graphics.setFont(Menu.fontButton)
        if active then
            love.graphics.setColor(1, 1, 1)
        else
            love.graphics.setColor(1, 1, 1, 0.95)
        end
        love.graphics.printf(I18n.names[b.code], b.x, b.y + (b.h - Menu.fontButton:getHeight()) / 2,
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
