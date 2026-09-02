-- Sound effects synthesized at load time - no audio asset files needed.
-- Each effect is a short envelope-shaped tone sequence baked into a Source.

local Sfx = { enabled = true, ready = false, sounds = {} }

local RATE = 44100

-- segments: array of { freq = Hz, dur = seconds }, played back to back.
local function build(segments, vol)
    local total = 0
    for _, s in ipairs(segments) do
        total = total + s.dur
    end
    local n = math.max(1, math.floor(RATE * total))
    local data = love.sound.newSoundData(n, RATE, 16, 1)
    local idx = 0
    for _, s in ipairs(segments) do
        local segN = math.max(1, math.floor(RATE * s.dur))
        for k = 0, segN - 1 do
            if idx >= n then
                break
            end
            local t = k / RATE
            local v = math.sin(2 * math.pi * s.freq * t)
            local env = 1 - k / segN -- decay envelope
            data:setSample(idx, v * vol * env * env)
            idx = idx + 1
        end
    end
    return love.audio.newSource(data, "static")
end

function Sfx.init()
    local ok = pcall(function()
        Sfx.sounds.ui = build({ { freq = 660, dur = 0.06 } }, 0.35)
        Sfx.sounds.land = build({
            { freq = 170, dur = 0.045 },
            { freq = 95, dur = 0.09 },
        }, 0.55)
        Sfx.sounds.perfect = build({
            { freq = 880, dur = 0.07 },
            { freq = 1174.7, dur = 0.12 },
        }, 0.4)
        Sfx.sounds.miss = build({
            { freq = 480, dur = 0.08 },
            { freq = 300, dur = 0.10 },
            { freq = 160, dur = 0.18 },
        }, 0.45)
        Sfx.sounds.gameover = build({
            { freq = 392, dur = 0.16 },
            { freq = 311, dur = 0.16 },
            { freq = 220, dur = 0.30 },
        }, 0.5)
    end)
    Sfx.ready = ok
end

function Sfx.play(name)
    if not Sfx.enabled or not Sfx.ready then
        return
    end
    local src = Sfx.sounds[name]
    if src then
        src:clone():play()
    end
end

function Sfx.toggle()
    Sfx.enabled = not Sfx.enabled
    return Sfx.enabled
end

return Sfx
