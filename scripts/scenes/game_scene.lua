require("scripts.game_scene.player")
require("scripts.game_scene.map_generator")
require("scripts.game_scene.hp_bar")
require("scripts.game_scene.boss_hp")
require("scripts.game_scene.enemy_spawner")
require("scripts.game_scene.music_manager")

local GameScene = {}

GameScene.name = "game"
GameScene.mt = { __index=GameScene }
GameScene.states = { clear="clear", transitioning="transitioning", fighting="fighting",
                     gameover="gameover", win="win" }

function GameScene.new()
    local t = {
        player=Player.new(),
        map=MapGenerator.new(),
        entities={},
        black_box=StillImage.new("black_box.png", Screen.width/2, Screen.height/2, 0.5, 0.5),

        music_manager = MusicManager.new(),

        time_since_level_load=0,
        state=GameScene.states.clear,
        updateFunction=GameScene.updateClear,
        drawFunction=GameScene.drawClear,
        paused=false,
    }
    table.insert(t.entities, t.player)
    return setmetatable(t, GameScene.mt)
end

function GameScene:update(dt)
    self.music_manager:update(dt)
    if not self.paused then
        self.time_since_level_load = self.time_since_level_load + dt
        self:updateFunction(dt)
        if Input.pause_button_down then
            self.paused = true
        end
    else
        if Input.pause_button_down then
            self.paused = false
        end
    end
    if love.keyboard.isDown("escape") then
        self.music_manager:stopAll()
        SceneManager:loadScene("menu")
    end
end

function GameScene:updateClear(dt)
    self.player:update(dt)
    self.map.rooms[self.map.current_room]:update(dt)
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
    self:runCollisionsBetweenEntities()
    self:removeDeadEnemies()
    self:sortEntityArray()
    self:checkGameOver()
end

function GameScene:updateGameOver(dt)
    for i, entity in ipairs(self.entities) do
        if entity.state == "idle" and entity.name ~= "isonade" then
            entity.current_anim[entity.direction]:update(dt)
        elseif entity.state == "idle" and entity.name == "isonade" then
            entity.idle_anim:update(dt)
        else
            entity:update(dt, self.player)
        end
    end
    if Mouse.mouse_button_down then
        SceneManager:loadScene("game")
    end
end

function GameScene:updateWin(dt)
    self.player:update(dt)
    if Mouse.mouse_button_down then
        SceneManager:loadScene("game")
    end
end

function GameScene:draw()
    self:drawFunction()
    HpBar.draw(self.player.hp)
    BossHp.draw(self.entities)
    if self.paused then
        self.black_box:draw()
        Text.printCentered("paused: press p to resume", {255, 255, 255}, Screen.width/2, Screen.height/2, 1)
    end
    Text.print("press esc to return to menu", {255, 255, 255}, 10, Screen.height-10, 1, 0, 1)
    Text.print("press p to pause", {255, 255, 255}, Screen.width-10, Screen.height-10, 1, 1, 1)
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

function GameScene:drawWin()
    self.map:draw()
    self.player:draw()
    self.black_box:draw()
    Text.printCentered("You win!", {255, 255, 255}, Screen.width/2, Screen.height/2-50, 3)
    if GODMODE then
        Text.printCentered("God mode is on, time not recorded",
                           {255, 255, 255}, Screen.width/2, Screen.height/2, 1)
    else
        Text.printCentered("Your time was: " .. math.floor(self.victory_time) .. " seconds!",
                           {255, 255, 255}, Screen.width/2, Screen.height/2, 1)
    end
    Text.printCentered("click anywhere to play again", {255, 255, 255}, Screen.width/2, Screen.height/2+50, 1)
end

function GameScene:shouldTransition()
    return self.state == GameScene.states.clear and self.player.rect:topLeft().y == Screen.upper_bound
           and self.player.rect.x > Screen.width/2-40 and self.player.rect.x < Screen.width/2+40
           and self.map:canTransition()
end

function GameScene:startTransition()
    self.map:startTransition(self.music_manager)
    self.state = GameScene.states.transitioning
    self.updateFunction = self.updateTransitioning
    self.drawFunction = self.drawTransitioning
    self.music_manager:nextRoom()
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
    if #self.entities == 1 and self.entities[1] == self.player
       and not self.map.rooms[self.map.current_room].boss then
        self.state = GameScene.states.clear
        self.updateFunction = self.updateClear
        self.drawFunction = self.drawClear
    elseif #self.entities == 1 and self.entities[1] == self.player then
        self.state = GameScene.states.win
        self.updateFunction = self.updateWin
        self.drawFunction = self.drawWin
        self.victory_time = self.time_since_level_load
    end
end

function GameScene:sortEntityArray()
    table.sort(self.entities, function(a, b) return a.rect.y < b.rect.y end)
end

function GameScene:runCollisionsBetweenEntities()
    for i,entity in ipairs(self.entities) do
        if entity ~= self.player then
            if self.player.rect:overlapping(entity.rect) and entity.name ~= "yami ninja" then
                if entity.name == "isonade" then
                    if entity.state ~= entity.states.following then
                        self.player:receiveDamage(entity)
                    end
                else
                    self.player:receiveDamage(entity)
                end
            end
            if self.player.state == Player.states.attacking then
                if self.player.direction == Player.directions.up then
                    local attackBox = Rectangle.new(self.player.rect.x, self.player.rect.y, 50, 70, 0.5, 1)
                    if attackBox:overlapping(entity.rect) then
                        entity:receiveDamage(self.player)
                    end
                elseif self.player.direction == Player.directions.down then
                    local attackBox = Rectangle.new(self.player.rect.x, self.player.rect.y, 50, 40, 0.5, 0)
                    if attackBox:overlapping(entity.rect) then
                        entity:receiveDamage(self.player)
                    end
                elseif self.player.direction == Player.directions.left then
                    local attackBox = Rectangle.new(self.player.rect.x, self.player.rect.y, 70, 20, 1, 0.9)
                    if attackBox:overlapping(entity.rect) then
                        entity:receiveDamage(self.player)
                    end
                elseif self.player.direction == Player.directions.right then
                    local attackBox = Rectangle.new(self.player.rect.x, self.player.rect.y, 70, 20, 0, 0.9)
                    if attackBox:overlapping(entity.rect) then
                        entity:receiveDamage(self.player)
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
        self.music_manager:stopAll()

        for i, entity in ipairs(self.entities) do
            if entity == self.player then
                table.remove(self.entities, i)
                break
            end
        end
    end
end

return GameScene
