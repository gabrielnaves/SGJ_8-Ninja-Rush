-- Mouse input
mouse = {}
mouse.mouseX = 0
mouse.mouseY = 0
mouse.mouseButton = false
mouse.mouseButtonDown = false

function mouse:update()
    local mouseDown = love.mouse.isDown(1)
    if mouseDown and not self.mouseButton then
        self.mouseButtonDown = true
    else
        self.mouseButtonDown = false
    end
    self.mouseButton = mouseDown
    self.mouseX = love.mouse.getX()
    self.mouseY = love.mouse.getY()
end
