require("scripts.utility.debug")
require("scripts.utility.screen")
require("scripts.utility.gamemath")
require("scripts.utility.geometry")
require("scripts.utility.still_image")
require("scripts.utility.still_animation")
require("scripts.utility.input")
require("scripts.utility.scene_management")
require("scripts.utility.text")

local background = nil

function love.load(arg)
    background = StillImage.new('background.png', Screen.width/2, Screen.height/2, 0.5, 0.5)
    SceneManager:loadScene("menu")
end

function love.update(dt)
    Mouse.update()
    Input.update()
    SceneManager:update(dt)
end

function love.draw()
    background:draw()
    SceneManager:draw()
end
