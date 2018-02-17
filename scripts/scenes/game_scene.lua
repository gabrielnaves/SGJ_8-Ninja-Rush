require("scripts.game_scene.player")

local GameScene = {}

GameScene.name = "game"
GameScene.mt = { __index=GameScene }

function GameScene.new()
    local t = {
        player=Player.new()
    }
    return setmetatable(t, GameScene.mt)
end

function GameScene:update(dt)
    self.player:update(dt)
end

function GameScene:draw()
    self.player:draw(dt)
end

return GameScene
