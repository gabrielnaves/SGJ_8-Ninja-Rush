Mouse = {}
Mouse.mouseX = 0
Mouse.mouseY = 0
Mouse.mouseButton = false
Mouse.mouseButtonDown = false

function Mouse.update()
    local mouseDown = love.mouse.isDown(1)
    if mouseDown and not Mouse.mouseButton then
        Mouse.mouseButtonDown = true
    else
        Mouse.mouseButtonDown = false
    end
    Mouse.mouseButton = mouseDown
    Mouse.mouseX = love.mouse.getX()
    Mouse.mouseY = love.mouse.getY()
end
