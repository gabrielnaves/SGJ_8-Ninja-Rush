require("scripts.game_scene.player")
require("scripts.game_scene.map_generator")
require("scripts.game_scene.kamaitachi")

local GameScene = {}

GameScene.name = "game"
GameScene.mt = { __index=GameScene }
GameScene.states = { clear="clear", transitioning="transitioning", fighting="fighting",
                     gameover="gameover" }

function GameScene.new()
    local t = {
        player=Player.new(),
        map=MapGenerator.new(),
        enemy=Kamaitachi.new(),

        timeSinceLevelLoad=0,
        state=GameScene.states.clear,
        updateFunction=GameScene.updateClear,
        drawFunction=GameScene.drawClear,
    }
    return setmetatable(t, GameScene.mt)
end

function GameScene:update(dt)
    self.timeSinceLevelLoad = self.timeSinceLevelLoad + dt
    self:updateFunction(dt)
end

function GameScene:updateClear(dt)
    self.player:update(dt)
    self.enemy:update(dt, self.player)
    if self:shouldTransition() then
        self:startTransition()
    end
end

function GameScene:updateTransitioning(dt)
    self.map:update(dt)
    if not self.map.transitioning then
        self:endTransition()
    end
end

function GameScene:draw()
    self:drawFunction()
end

function GameScene:drawClear()
    self.map:draw()
    if self.player.rect.y < self.enemy.rect.y then
        self.player:draw()
        self.enemy:draw()
    else
        self.enemy:draw()
        self.player:draw()
    end
end

function GameScene:drawTransitioning()
    self.map:draw()
end

function GameScene:shouldTransition()
    return self.state == GameScene.states.clear and self.player.rect:topLeft().y == self.player.upper_limit
           and self.player.rect.x > Screen.width/2-40 and self.player.rect.x < Screen.width/2+40
           and self.map:canTransition()
end

function GameScene:startTransition()
    self.map:startTransition()
    self.state = GameScene.states.transitioning
    self.updateFunction = self.updateTransitioning
    self.drawFunction = self.drawTransitioning
end

function GameScene:endTransition()
    self.player.rect.x = Screen.width/2
    self.player.rect.y = self.player.lower_limit - self.player.rect.height*(1-self.player.rect.pivotY)
    self.player.velocity = Vector.new(0, 0)

    self.state = GameScene.states.clear
    self.updateFunction = self.updateClear
    self.drawFunction = self.drawClear
end

return GameScene
