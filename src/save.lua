-- Best-score persistence via love.filesystem
-- (stored under the "tower-bloxx" identity directory).

local Save = {}

local FILE = "best.txt"

function Save.loadBest()
    -- getInfo() guard: reading a missing file returns corrupted values in
    -- some builds (love.js/WebAssembly), so only read existing files.
    if not love.filesystem.getInfo(FILE) then
        return 0
    end
    local ok, content = pcall(love.filesystem.read, FILE)
    if ok and type(content) == "string" then
        return tonumber(content) or 0
    end
    return 0
end

function Save.storeBest(value)
    pcall(love.filesystem.write, FILE, tostring(value))
end

return Save
