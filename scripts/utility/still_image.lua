StillImage = {}
StillImage.mt = {__index=StillImage}

function StillImage.new(img_name, x, y, pivotX, pivotY)
    -- Default parameters
    x = x or 0.0
    y = y or 0.0
    pivotX = pivotX or 0.0
    pivotY = pivotY or 0.0

    -- Load image
    local image = love.graphics.newImage('assets/' .. img_name)

    -- Make instance
    local instance = {
        img = image,
        x = x,
        y = y,
        pivotX = pivotX,
        pivotY = pivotY,
        width = image:getWidth(),
        height = image:getHeight(),
    }
    return setmetatable(instance, StillImage.mt)
end

function StillImage:draw()
    love.graphics.draw(self.img,
                       math.floor(self.x - self.width*self.pivotX),
                       math.floor(self.y - self.height*self.pivotY))
end
