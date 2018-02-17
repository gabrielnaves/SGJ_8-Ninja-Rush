require("scripts.utility.debug")
require("scripts.utility.screen")
require("scripts.utility.gamemath")
require("scripts.utility.geometry")
require("scripts.utility.still_image")
require("scripts.utility.still_animation")
require("scripts.utility.input")
require("scripts.utility.scene_management")

local background = nil

function love.load(arg)
    background = StillImage.new('background.png')
    SceneManager:loadScene("game")
end

function love.update(dt)
    SceneManager:update(dt)
end

function love.draw()
    background:draw()
    SceneManager:draw()
end
