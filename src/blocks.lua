-- Shared block rendering: pastel floors with windows, used by the
-- tower, the crane and falling debris.

local Config = require("src.config")

local PALETTE = {
    { 0.95, 0.65, 0.30 }, -- amber
    { 0.88, 0.42, 0.44 }, -- coral
    { 0.42, 0.70, 0.88 }, -- sky
    { 0.55, 0.78, 0.48 }, -- green
    { 0.70, 0.55, 0.86 }, -- violet
    { 0.92, 0.55, 0.75 }, -- pink
}

local Blocks = {}

function Blocks.colorFor(index)
    return PALETTE[(index % #PALETTE) + 1]
end

-- Draws one block with its top-left at (x, yTop).
function Blocks.draw(x, yTop, w, index, alpha)
    alpha = alpha or 1
    local h = Config.block.height
    local c = Blocks.colorFor(index)

    -- body
    love.graphics.setColor(c[1], c[2], c[3], alpha)
    love.graphics.rectangle("fill", x, yTop, w, h, 3, 3)

    -- bottom shading strip
    love.graphics.setColor(c[1] * 0.78, c[2] * 0.78, c[3] * 0.78, alpha)
    love.graphics.rectangle("fill", x + 1, yTop + h - 7, w - 2, 6)

    -- windows
    if w >= 34 then
        love.graphics.setColor(0.99, 0.96, 0.82, 0.92 * alpha)
        local winW, winH, gap = 9, 12, 9
        local n = math.min(4, math.floor((w - 10) / (winW + gap)))
        local totalW = n * winW + (n - 1) * gap
        local startX = x + (w - totalW) / 2
        for i = 0, n - 1 do
            love.graphics.rectangle(
                "fill",
                startX + i * (winW + gap),
                yTop + (h - winH) / 2 - 2,
                winW, winH, 2, 2
            )
        end
    end

    -- outline
    love.graphics.setColor(0.12, 0.12, 0.18, 0.5 * alpha)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", x + 0.5, yTop + 0.5, w - 1, h - 1, 3, 3)
end

return Blocks
