require("scripts.game_scene.player")
require("scripts.game_scene.map_generator")
require("scripts.game_scene.hp_bar")
require("scripts.game_scene.enemy_spawner")

local GameScene = {}

GameScene.name = "game"
GameScene.mt = { __index=GameScene }
GameScene.states = { clear="clear", transitioning="transitioning", fighting="fighting",
                     gameover="gameover" }

function GameScene.new()
    local t = {
        player=Player.new(),
        map=MapGenerator.new(),
        entities={},
        black_box=StillImage.new("black_box.png", Screen.width/2, Screen.height/2, 0.5, 0.5),

        timeSinceLevelLoad=0,
        state=GameScene.states.clear,
        updateFunction=GameScene.updateClear,
        drawFunction=GameScene.drawClear,
    }
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
    for i, entity in ipairs(self.entities) do
        entity:update(dt, self.player)
    end
    self:runCollisions()
    self:removeDeadEnemies()
    self:sortEntityArray()
    self:checkGameOver()
end

function GameScene:updateGameOver(dt)
    for i, entity in ipairs(self.entities) do
        if entity.state == "idle" then
            entity.current_anim[entity.direction]:update(dt)
        else
            entity:update(dt, self.player)
        end
    end
    if Mouse.mouse_button_down then
        SceneManager:loadScene("game")
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

function GameScene:drawGameOver()
    self.map:draw()
    for i, entity in ipairs(self.entities) do
        entity:draw()
    end
    self.black_box:draw()
    Text.printCentered("Game Over!", {255, 255, 255}, Screen.width/2, Screen.height/2-50, 3)
    Text.printCentered("click anywhere to play again", {255, 255, 255}, Screen.width/2, Screen.height/2+50, 1)
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

    EnemySpawner.spawnEnemies(self.entities, self.map.rooms[self.map.current_room])
end

function GameScene:removeDeadEnemies()
    local dead_enemies = {}
    for i,entity in ipairs(self.entities) do
        if entity ~= self.player and entity.hp <= 0 then
            table.insert(dead_enemies, i)
        end
    end
    for i,enemy_to_remove in ipairs(dead_enemies) do
        table.remove(self.entities, enemy_to_remove)
    end
    if #self.entities == 1 and self.entities[1] == self.player then
        self.state = GameScene.states.clear
        self.updateFunction = self.updateClear
        self.drawFunction = self.drawClear
    end
end

function GameScene:sortEntityArray()
    table.sort(self.entities, function(a, b) return a.rect.y < b.rect.y end)
end

function GameScene:runCollisions()
    for i,entity in ipairs(self.entities) do
        if entity ~= self.player then
            if self.player.rect:overlapping(entity.rect) then
                self.player:receiveDamage(entity)
            end
            if self.player.state == Player.states.attacking then
                if self.player.direction == Player.directions.up then
                    if entity.rect.y < self.player.rect.y and entity.rect.y > self.player.rect.y - 100
                       and entity.rect.x > self.player.rect.x-40
                       and entity.rect.x < self.player.rect.x+40 then
                        entity:receiveDamage()
                    end
                elseif self.player.direction == Player.directions.down then
                    if entity.rect.y > self.player.rect.y and entity.rect.y < self.player.rect.y + 70
                       and entity.rect.x > self.player.rect.x-40
                       and entity.rect.x < self.player.rect.x+40 then
                        entity:receiveDamage()
                    end
                elseif self.player.direction == Player.directions.left then
                    if entity.rect.y < self.player.rect.y+10
                       and entity.rect.y > self.player.rect.y-40
                       and entity.rect.x < self.player.rect.x
                       and entity.rect.x > self.player.rect.x - 100 then
                        entity:receiveDamage()
                    end
                elseif self.player.direction == Player.directions.right then
                    if entity.rect.y < self.player.rect.y+10
                       and entity.rect.y > self.player.rect.y-40
                       and entity.rect.x > self.player.rect.x
                       and entity.rect.x < self.player.rect.x + 100 then
                        entity:receiveDamage()
                    end
                end
            end
        end
    end
end

function GameScene:checkGameOver()
    if self.player.hp <= 0 then
        self.state = GameScene.states.gameover
        self.updateFunction = self.updateGameOver
        self.drawFunction = self.drawGameOver

        for i, entity in ipairs(self.entities) do
            if entity == self.player then
                table.remove(self.entities, i)
                break
            end
        end
    end
end

return GameScene
