require("scripts.utility.debug")
require("scripts.utility.screen")
require("scripts.utility.gamemath")
require("scripts.utility.geometry")
require("scripts.utility.still_image")
require("scripts.utility.still_animation")
require("scripts.utility.input")

local background = nil

function love.load(arg)
    -- background = still_image.new('background.png')

    -- current_scene = require("scripts.scenes.menu_scene")
end

function love.update(dt)
    if current_scene ~= nil then
        current_scene:update(dt)
        if current_scene.lateUpdate ~= nil then
            current_scene:lateUpdate(dt)
        end
    end
end

function love.draw()
    -- background:draw()
    if current_scene ~= nil then
        current_scene:draw()
    end
end
