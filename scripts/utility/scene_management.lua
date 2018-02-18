SceneManager = {}

SceneManager.current_scene = nil
SceneManager.scenes = {
    require("scripts.scenes.menu_scene"),
    require("scripts.scenes.game_scene"),
}

function SceneManager:loadScene(name)
    for i,scene in ipairs(self.scenes) do
        if scene.name == name then
            self.current_scene = scene.new()
            return
        end
    end
end

function SceneManager:update(dt)
    if self.current_scene ~= nil then
        self.current_scene:update(dt)
    end
end

function SceneManager:draw()
    if self.current_scene ~= nil then
        self.current_scene:draw()
    end
end
