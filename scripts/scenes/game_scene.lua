require("scripts.game_scene.player")
require("scripts.game_scene.map_generator")

local GameScene = {}

GameScene.name = "game"
GameScene.mt = { __index=GameScene }

function GameScene.new()
    local t = {
        player=Player.new(),
        map=MapGenerator.new(),
    }
    t.map:startTransition()
    return setmetatable(t, GameScene.mt)
end

function GameScene:update(dt)
    self.map:update(dt)
    self.player:update(dt)
end

function GameScene:draw()
    self.map:draw()
    self.player:draw(dt)
end

return GameScene
