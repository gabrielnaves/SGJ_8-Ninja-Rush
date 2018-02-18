require("scripts.game_scene.player")
require("scripts.game_scene.map_generator")
require("scripts.game_scene.kamaitachi")
require("scripts.game_scene.hp_bar")

local GameScene = {}

GameScene.name = "game"
GameScene.mt = { __index=GameScene }
GameScene.states = { clear="clear", transitioning="transitioning", fighting="fighting",
                     gameover="gameover" }

function GameScene.new()
    local t = {
        player=Player.new(),
        map=MapGenerator.new(),
        entities={
            Kamaitachi.new(),
            Kamaitachi.new(),
        },

        timeSinceLevelLoad=0,
        state=GameScene.states.fighting,
        updateFunction=GameScene.updateFighting,
        drawFunction=GameScene.drawFighting,
    }
    t.entities[2].rect.x = Screen.width/4
    t.entities[2].rect.y = 350
    table.insert(t.entities, t.player)
    return setmetatable(t, GameScene.mt)
end

function GameScene:update(dt)
    self.timeSinceLevelLoad = self.timeSinceLevelLoad + dt
    self:updateFunction(dt)
end

function GameScene:updateClear(dt)
    self.player:update(dt)
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

function GameScene:updateFighting(dt)
    -- self.player:update(dt)
    for i, entity in ipairs(self.entities) do
        entity:update(dt, self.player)
    end
    self:runCollisions()
    self:sortEntityArray()
end

function GameScene:runCollisions()
    for i,entity in ipairs(self.entities) do
        if entity ~= self.player then
            if self.player.rect:overlapping(entity.rect) then
                self.player:receiveDamage(entity)
            end
        end
    end
end

function GameScene:draw()
    self:drawFunction()
    HpBar.draw(self.player.hp)
end

function GameScene:drawClear()
    self.map:draw()
    self.player:draw()
end

function GameScene:drawTransitioning()
    self.map:draw()
end

function GameScene:drawFighting()
    self.map:draw()
    for i, entity in ipairs(self.entities) do
        entity:draw()
    end
end

function GameScene:shouldTransition()
    return self.state == GameScene.states.clear and self.player.rect:topLeft().y == Screen.upper_bound
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
    self.player.rect.y = Screen.lower_bound - self.player.rect.height*(1-self.player.rect.pivotY)
    self.player.velocity = Vector.new(0, 0)

    self.state = GameScene.states.fighting
    self.updateFunction = self.updateFighting
    self.drawFunction = self.drawFighting
end

function GameScene:sortEntityArray()
    table.sort(self.entities, function(a, b) return a.rect.y < b.rect.y end)
end

return GameScene
