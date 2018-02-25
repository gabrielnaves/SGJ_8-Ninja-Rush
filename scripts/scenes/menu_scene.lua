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
        GODMODE = false
        SceneManager:loadScene("game")
    elseif love.keyboard.isDown("g") then
        GODMODE = true
        SceneManager:loadScene("game")
    end
end

function MenuScene:draw()
    self.bg:draw()

    -- Title
    Text.printCentered("Ninja Rush", {255, 255, 255}, Screen.width/2, 40, 3)
    Text.printCentered("a game by Gabriel Naves,", {255, 255, 255}, Screen.width/2, 80, 1)
    Text.printCentered("with music by Eber Filipe", {255, 255, 255}, Screen.width/2, 105, 1)

    -- Instructions
    Text.printCentered("Beat the bosses as quickly as you can!", {255, 255, 255}, Screen.width/2, Screen.height/2-70, 2)
    Text.printCentered("move with WASD or arrow keys", {255, 255, 255}, Screen.width/2, Screen.height/2-20, 1)
    Text.printCentered("attack with space", {255, 255, 255}, Screen.width/2, Screen.height/2+10, 1)
    Text.printCentered("dash with left shift", {255, 255, 255}, Screen.width/2, Screen.height/2+40, 1)
    Text.printCentered("kill all enemies to proceed", {255, 255, 255}, Screen.width/2, Screen.height/2+70, 1)
    Text.printCentered("click anywhere to start", {255, 255, 255}, Screen.width/2, Screen.height-150, 1)
    Text.printCentered("press G to start on godmode", {255, 255, 255}, Screen.width/2, Screen.height-50, 1)
    Text.printCentered("time is not recorded when you play in godmode",
        {255, 255, 255}, Screen.width/2, Screen.height-20, 1)
end

return MenuScene
