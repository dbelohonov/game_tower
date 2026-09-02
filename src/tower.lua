-- The stack of placed blocks. Logical positions only; a light cosmetic
-- sway is applied at render time.

local Config = require("src.config")
local Blocks = require("src.blocks")

local W = Config.screen.width

local Tower = {}
Tower.__index = Tower

function Tower.new()
    local self = setmetatable({}, Tower)
    self.blocks = {} -- bottom-up: { x = left edge, w = width }
    self.baseW = Config.base.width
    self.baseX = (W - self.baseW) / 2
    return self
end

function Tower:height()
    return #self.blocks
end

-- Landing surface for the next block: left, width, world y of the surface.
function Tower:topSurface()
    local n = #self.blocks
    if n == 0 then
        return self.baseX, self.baseW, 0
    end
    local top = self.blocks[n]
    return top.x, top.w, -n * Config.block.height
end

function Tower:addBlock(x, w)
    table.insert(self.blocks, { x = x, w = w })
end

function Tower:draw(time)
    -- concrete pad
    love.graphics.setColor(0.58, 0.60, 0.64)
    love.graphics.rectangle("fill", self.baseX, 0, self.baseW, Config.base.height, 5, 5)
    love.graphics.setColor(0.35, 0.37, 0.42)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", self.baseX, 0, self.baseW, Config.base.height, 5, 5)

    local n = #self.blocks
    local amp = math.min(10, n * 0.35)
    for i, b in ipairs(self.blocks) do
        -- Higher floors sway more; purely cosmetic.
        local sway = 0
        if n > 2 then
            local f = i / n
            sway = math.sin(time * 1.3 + i * 0.3) * amp * f * f
        end
        Blocks.draw(b.x + sway, -i * Config.block.height, b.w, i - 1)
    end
end

return Tower
