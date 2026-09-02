-- Best-score persistence via love.filesystem
-- (stored under the "tower-bloxx" identity directory).

local Save = {}

local FILE = "best.txt"

function Save.loadBest()
    local ok, content = pcall(love.filesystem.read, FILE)
    if ok and content then
        return tonumber(content) or 0
    end
    return 0
end

function Save.storeBest(value)
    pcall(love.filesystem.write, FILE, tostring(value))
end

return Save
