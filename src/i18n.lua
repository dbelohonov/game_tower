-- Localization (i18n) for Tower Bloxx.
-- Supported languages: English, Russian, German, French, Slovak.
--
-- Usage:
--   local I18n = require("src.i18n")
--   I18n.init()                    -- call once in love.load
--   I18n.t("menu.pressStart")      -- translated string
--   I18n.tf("hud.floors", 12)      -- translated + string.format
--   I18n.floorsText(12)            -- "12 floors" with correct plural form
--   I18n.font(18)                  -- Unicode font of the given px size (cached)
--   I18n.setLanguage("ru")         -- switch + persist
--
-- Language selection priority: saved choice > OS preferred locales > English.

local I18n = {}

local LANG_FILE = "language.txt"
local FONT_PATH = "assets/fonts/DejaVuSans-Bold.ttf" -- bold for readability; covers Latin + Cyrillic
local FONT_PATH_REGULAR = "assets/fonts/DejaVuSans.ttf"

-- Order matters: this is the order of the buttons in the menu selector.
I18n.languages = { "en", "ru", "de", "fr", "sk" }

-- Native names shown on the language buttons.
I18n.names = {
    en = "English",
    ru = "Русский",
    de = "Deutsch",
    fr = "Français",
    sk = "Slovenčina",
}

I18n.current = "en"

---------------------------------------------------------------------------
-- translations
---------------------------------------------------------------------------

local STRINGS = {

    en = {
        ["menu.subtitle"]   = "a LOVE tribute to the Nokia classic",
        ["menu.pressStart"] = "PRESS SPACE OR CLICK TO START",
        ["menu.hintDrop"]   = "SPACE / CLICK - drop the block",
        ["menu.hintStack"]  = "stack as many floors as you can",
        ["menu.hintKeys"]   = "M - sound on/off    P - pause    ESC - quit",
        ["menu.language"]   = "Language",
        ["hud.floors"]      = "FLOORS  %d",
        ["hud.score"]       = "SCORE  %d",
        ["hud.best"]        = "BEST: %s",
        ["hud.combo"]       = "PERFECT COMBO x%d",
        ["hud.dropHint"]    = "SPACE / CLICK - drop the block!",
        ["hud.muted"]       = "MUTED (M)",
        ["game.perfect"]    = "PERFECT",
        ["game.miss"]       = "MISS",
        ["game.paused"]     = "PAUSED",
        ["game.pausedHint"] = "P - resume      ESC - menu",
        ["over.title"]      = "GAME OVER",
        ["over.height"]     = "TOWER HEIGHT: %s",
        ["over.score"]      = "SCORE: %d",
        ["over.newBest"]    = "NEW BEST!",
        ["over.best"]       = "BEST: %s",
        ["over.prompt"]     = "SPACE - PLAY AGAIN      ESC - MENU",
    },

    ru = {
        ["menu.subtitle"]   = "посвящение классике Nokia на LOVE",
        ["menu.pressStart"] = "НАЖМИТЕ ПРОБЕЛ ИЛИ КЛИКНИТЕ ДЛЯ СТАРТА",
        ["menu.hintDrop"]   = "ПРОБЕЛ / КЛИК - бросить блок",
        ["menu.hintStack"]  = "постройте как можно больше этажей",
        ["menu.hintKeys"]   = "M - звук вкл/выкл    P - пауза    ESC - выход",
        ["menu.language"]   = "Язык",
        ["hud.floors"]      = "ЭТАЖИ  %d",
        ["hud.score"]       = "СЧЁТ  %d",
        ["hud.best"]        = "РЕКОРД: %s",
        ["hud.combo"]       = "ИДЕАЛЬНАЯ СЕРИЯ x%d",
        ["hud.dropHint"]    = "ПРОБЕЛ / КЛИК - бросить блок!",
        ["hud.muted"]       = "ЗВУК ВЫКЛЮЧЕН (M)",
        ["game.perfect"]    = "ИДЕАЛЬНО",
        ["game.miss"]       = "ПРОМАХ",
        ["game.paused"]     = "ПАУЗА",
        ["game.pausedHint"] = "P - продолжить      ESC - меню",
        ["over.title"]      = "ИГРА ОКОНЧЕНА",
        ["over.height"]     = "ВЫСОТА БАШНИ: %s",
        ["over.score"]      = "СЧЁТ: %d",
        ["over.newBest"]    = "НОВЫЙ РЕКОРД!",
        ["over.best"]       = "РЕКОРД: %s",
        ["over.prompt"]     = "ПРОБЕЛ - ЕЩЁ РАЗ      ESC - МЕНЮ",
    },

    de = {
        ["menu.subtitle"]   = "eine LOVE-Hommage an den Nokia-Klassiker",
        ["menu.pressStart"] = "LEERTASTE ODER KLICK ZUM STARTEN",
        ["menu.hintDrop"]   = "LEERTASTE / KLICK - Block fallen lassen",
        ["menu.hintStack"]  = "baue so viele Stockwerke wie möglich",
        ["menu.hintKeys"]   = "M - Ton an/aus    P - Pause    ESC - Beenden",
        ["menu.language"]   = "Sprache",
        ["hud.floors"]      = "STOCKWERKE  %d",
        ["hud.score"]       = "PUNKTE  %d",
        ["hud.best"]        = "REKORD: %s",
        ["hud.combo"]       = "PERFEKT-SERIE x%d",
        ["hud.dropHint"]    = "LEERTASTE / KLICK - Block fallen lassen!",
        ["hud.muted"]       = "STUMM (M)",
        ["game.perfect"]    = "PERFEKT",
        ["game.miss"]       = "VERFEHLT",
        ["game.paused"]     = "PAUSE",
        ["game.pausedHint"] = "P - weiter      ESC - Menü",
        ["over.title"]      = "SPIEL VORBEI",
        ["over.height"]     = "TURMHÖHE: %s",
        ["over.score"]      = "PUNKTE: %d",
        ["over.newBest"]    = "NEUER REKORD!",
        ["over.best"]       = "REKORD: %s",
        ["over.prompt"]     = "LEERTASTE - NOCHMAL      ESC - MENÜ",
    },

    fr = {
        ["menu.subtitle"]   = "un hommage LOVE au classique de Nokia",
        ["menu.pressStart"] = "ESPACE OU CLIC POUR COMMENCER",
        ["menu.hintDrop"]   = "ESPACE / CLIC - lâcher le bloc",
        ["menu.hintStack"]  = "empilez un maximum d'étages",
        ["menu.hintKeys"]   = "M - son on/off    P - pause    ESC - quitter",
        ["menu.language"]   = "Langue",
        ["hud.floors"]      = "ÉTAGES  %d",
        ["hud.score"]       = "SCORE  %d",
        ["hud.best"]        = "RECORD : %s",
        ["hud.combo"]       = "COMBO PARFAIT x%d",
        ["hud.dropHint"]    = "ESPACE / CLIC - lâcher le bloc !",
        ["hud.muted"]       = "MUET (M)",
        ["game.perfect"]    = "PARFAIT",
        ["game.miss"]       = "RATÉ",
        ["game.paused"]     = "PAUSE",
        ["game.pausedHint"] = "P - reprendre      ESC - menu",
        ["over.title"]      = "PARTIE TERMINÉE",
        ["over.height"]     = "HAUTEUR DE LA TOUR : %s",
        ["over.score"]      = "SCORE : %d",
        ["over.newBest"]    = "NOUVEAU RECORD !",
        ["over.best"]       = "RECORD : %s",
        ["over.prompt"]     = "ESPACE - REJOUER      ESC - MENU",
    },

    sk = {
        ["menu.subtitle"]   = "pocta klasike z Nokie v LOVE",
        ["menu.pressStart"] = "STLAČTE MEDZERNÍK ALEBO KLIKNITE PRE ŠTART",
        ["menu.hintDrop"]   = "MEDZERNÍK / KLIK - pusťte blok",
        ["menu.hintStack"]  = "postavte čo najviac poschodí",
        ["menu.hintKeys"]   = "M - zvuk zap/vyp    P - pauza    ESC - koniec",
        ["menu.language"]   = "Jazyk",
        ["hud.floors"]      = "POSCHODIA  %d",
        ["hud.score"]       = "SKÓRE  %d",
        ["hud.best"]        = "REKORD: %s",
        ["hud.combo"]       = "PERFEKTNÉ KOMBO x%d",
        ["hud.dropHint"]    = "MEDZERNÍK / KLIK - pusťte blok!",
        ["hud.muted"]       = "ZVUK VYPNUTÝ (M)",
        ["game.perfect"]    = "PERFEKTNÉ",
        ["game.miss"]       = "VEDĽA",
        ["game.paused"]     = "PAUZA",
        ["game.pausedHint"] = "P - pokračovať      ESC - menu",
        ["over.title"]      = "KONIEC HRY",
        ["over.height"]     = "VÝŠKA VEŽE: %s",
        ["over.score"]      = "SKÓRE: %d",
        ["over.newBest"]    = "NOVÝ REKORD!",
        ["over.best"]       = "REKORD: %s",
        ["over.prompt"]     = "MEDZERNÍK - HRAŤ ZNOVU      ESC - MENU",
    },

}

---------------------------------------------------------------------------
-- plural rules for "floor" (used in BEST / TOWER HEIGHT texts)
---------------------------------------------------------------------------

local PLURALS = {
    en = function(n) return n == 1 and "floor" or "floors" end,
    de = function(n) return n == 1 and "Stockwerk" or "Stockwerke" end,
    fr = function(n) return n == 1 and "étage" or "étages" end,
    ru = function(n)
        local m10, m100 = n % 10, n % 100
        if m10 == 1 and m100 ~= 11 then
            return "этаж"
        elseif m10 >= 2 and m10 <= 4 and (m100 < 12 or m100 > 14) then
            return "этажа"
        end
        return "этажей"
    end,
    sk = function(n)
        if n == 1 then
            return "poschodie"
        elseif n >= 2 and n <= 4 then
            return "poschodia"
        end
        return "poschodí"
    end,
}

function I18n.floorsText(n)
    local rule = PLURALS[I18n.current] or PLURALS.en
    return string.format("%d %s", n, rule(n))
end

---------------------------------------------------------------------------
-- language selection
---------------------------------------------------------------------------

local function isSupported(code)
    return STRINGS[code] ~= nil
end

function I18n.setLanguage(code)
    if not isSupported(code) then
        return
    end
    I18n.current = code
    pcall(love.filesystem.write, LANG_FILE, code)
end

-- Move along the language list (dir = +1 / -1), wrapping around.
function I18n.cycle(dir)
    local list = I18n.languages
    for i, code in ipairs(list) do
        if code == I18n.current then
            local nextIndex = ((i - 1 + dir) % #list) + 1
            I18n.setLanguage(list[nextIndex])
            return
        end
    end
    I18n.setLanguage(list[1])
end

function I18n.init()
    -- 1) previously saved choice wins.
    -- getInfo() guard: reading a missing file returns corrupted values in
    -- some builds (love.js/WebAssembly), so never call read() unless the
    -- file actually exists.
    local saved
    if love.filesystem.getInfo(LANG_FILE) then
        local okRead, data = pcall(love.filesystem.read, LANG_FILE)
        if okRead and type(data) == "string" then
            saved = data
        end
    end
    if saved then
        saved = saved:lower():match("^%a+")
        if saved and isSupported(saved) then
            I18n.current = saved
            return
        end
    end

    -- 2) otherwise try the OS preferred locales
    if love.system and love.system.getPreferredLocales then
        local okLocales, locales = pcall(love.system.getPreferredLocales)
        if okLocales and locales then
            for _, locale in ipairs(locales) do
                local code = locale:sub(1, 2):lower()
                if isSupported(code) then
                    I18n.current = code
                    return
                end
            end
        end
    end

    -- 3) default
    I18n.current = "en"
end

---------------------------------------------------------------------------
-- translation lookups
---------------------------------------------------------------------------

function I18n.t(key)
    local lang = STRINGS[I18n.current] or STRINGS.en
    local value = lang[key] or STRINGS.en[key]
    return value or key
end

function I18n.tf(key, ...)
    return string.format(I18n.t(key), ...)
end

---------------------------------------------------------------------------
-- Unicode font helper (DejaVu Sans covers Latin + Cyrillic + diacritics).
-- I18n.font(size) returns the BOLD face (all UI text is bold for
-- readability); I18n.font(size, "regular") returns the normal weight.
---------------------------------------------------------------------------

local fontCache = {}
local fontAvailable = {}

local function unicodeFontAvailable(path)
    if fontAvailable[path] == nil then
        fontAvailable[path] = love.filesystem.getInfo(path) ~= nil
        if not fontAvailable[path] then
            print("i18n: " .. path .. " not found, falling back to the default font")
        end
    end
    return fontAvailable[path]
end

function I18n.font(size, weight)
    weight = (weight == "regular") and "regular" or "bold"
    local key = size .. "/" .. weight
    local cached = fontCache[key]
    if cached then
        return cached
    end
    local path = (weight == "regular") and FONT_PATH_REGULAR or FONT_PATH
    local font
    if unicodeFontAvailable(path) then
        font = love.graphics.newFont(path, size)
    else
        font = love.graphics.newFont(size)
    end
    fontCache[key] = font
    return font
end

return I18n
