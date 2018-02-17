Mouse = {}
Mouse.mouse_x = 0
Mouse.mouse_y = 0
Mouse.mouse_button = false
Mouse.mouse_button_down = false

function Mouse.update()
    local mouseDown = love.mouse.isDown(1)
    Mouse.mouse_button_down = (mouseDown and not Mouse.mouse_button)
    Mouse.mouse_button = mouseDown
    Mouse.mouse_x = love.mouse.getX()
    Mouse.mouse_y = love.mouse.getY()
end

Input = {}
Input.attack_button = false
Input.attack_button_down = false
Input.dash_button = false
Input.dash_button_down = false

function Input.update()
    local attack_down = love.keyboard.isDown("space")
    Input.attack_button_down = (attack_down and not Input.attack_button)
    Input.attack_button = attack_down

    local dash_down = love.keyboard.isDown("lshift")
    Input.dash_button_down = (dash_down and not Input.dash_button)
    Input.dash_button = dash_down
end

function Input.vertical()
    local result = 0
    if love.keyboard.isDown("w") then
        result = result - 1
    elseif love.keyboard.isDown("s") then
        result = result + 1
    end
    return result
end

function Input.horizontal()
    local result = 0
    if love.keyboard.isDown("a") then
        result = result - 1
    elseif love.keyboard.isDown("d") then
        result = result + 1
    end
    return result
end
