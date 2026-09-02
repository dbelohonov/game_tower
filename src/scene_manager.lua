-- Minimal scene (game state) manager: menu / game / gameover.
-- A scene is a table that may implement:
--   enter(params), leave(), update(dt), draw(),
--   keypressed(key), mousepressed(x, y, button)

local Manager = {
    scenes = {},
    current = nil,
}

function Manager.register(name, scene)
    Manager.scenes[name] = scene
end

function Manager.switch(name, params)
    local scene = Manager.scenes[name]
    assert(scene, "unknown scene: " .. tostring(name))
    if Manager.current and Manager.current.leave then
        Manager.current.leave()
    end
    Manager.current = scene
    if scene.enter then
        scene.enter(params or {})
    end
end

function Manager.update(dt)
    if Manager.current and Manager.current.update then
        Manager.current.update(dt)
    end
end

function Manager.draw()
    if Manager.current and Manager.current.draw then
        Manager.current.draw()
    end
end

function Manager.keypressed(key)
    if Manager.current and Manager.current.keypressed then
        Manager.current.keypressed(key)
    end
end

function Manager.mousepressed(x, y, button)
    if Manager.current and Manager.current.mousepressed then
        Manager.current.mousepressed(x, y, button)
    end
end

return Manager
