local MenuScene = {}

MenuScene.name = "menu"
MenuScene.mt = { __index=MenuScene }

function MenuScene.new()
    local t = {
        bg = StillImage.new('black_background.png', Screen.width/2, Screen.height/2, 0.5, 0.5),
    }
    return setmetatable(t, MenuScene.mt)
end

function MenuScene:update(dt)
    if Mouse.mouse_button_down then
        SceneManager:loadScene("game")
    end
end

function MenuScene:draw()
    self.bg:draw()

    -- Title
    Text.printCentered("Ninja Rush", {255, 255, 255}, Screen.width/2, 40, 3)
    Text.printCentered("a game by Gabriel Naves", {255, 255, 255}, Screen.width/2, 80, 1)

    -- Instructions
    Text.printCentered("Beat the boss as quickly as you can!", {255, 255, 255}, Screen.width/2, Screen.height/2-90, 2)
    Text.printCentered("move with WASD or arrow keys", {255, 255, 255}, Screen.width/2, Screen.height/2-40, 1)
    Text.printCentered("attack with space", {255, 255, 255}, Screen.width/2, Screen.height/2-10, 1)
    Text.printCentered("dash with left shift", {255, 255, 255}, Screen.width/2, Screen.height/2+20, 1)
    Text.printCentered("kill all enemies to proceed", {255, 255, 255}, Screen.width/2, Screen.height/2+50, 1)
    Text.printCentered("click anywhere to start", {255, 255, 255}, Screen.width/2, Screen.height-100, 1)
    Text.printCentered("NOTE: doors do not have an opening animation, but they will be open when the room is clear!",
                       {255, 255, 255}, Screen.width/2, Screen.height-16, 1)
end

return MenuScene
