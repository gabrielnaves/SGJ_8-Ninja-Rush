still_animation = {}

function still_animation.new(img_name, frame_count, frame_time, x, y, pivotX, pivotY)
    -- Default value settings
    frame_count = frame_count or 1
    frame_time = frame_time or 1
    x = x or 0.0
    y = y or 0.0
    pivotX = pivotX or 0.0
    pivotY = pivotY or 0.0

    -- Image setup
    local image = love.graphics.newImage('assets/' .. img_name)
    local frame_width = image:getWidth() / frame_count
    local frame_height = image:getHeight()
    local frames = {}
    for i=1,frame_count do
        frames[i] = love.graphics.newQuad(frame_width*(i-1), 0, frame_width, frame_height, image:getWidth(), image:getHeight())
    end

    -- Return animation table
    return {
        img = image,
        frames = frames,
        frame_count = frame_count,
        frame_time = frame_time,
        frame_timer = 0,
        current_frame = 1,

        x = x,
        y = y,
        pivotX = pivotX,
        pivotY = pivotY,
        width = frame_width,
        height = frame_height,

        update = function(self, dt)
            self.frame_timer = self.frame_timer + dt
            if self.frame_timer > self.frame_time then
                self.frame_timer = 0
                self.current_frame = self.current_frame + 1
                if self.current_frame > self.frame_count then self.current_frame = 1 end
            end
        end,

        draw = function(self)
            love.graphics.draw(self.img, self.frames[self.current_frame],
                               math.floor(self.x - self.width*self.pivotX),
                               math.floor(self.y - self.height*self.pivotY))
        end,

        restartAnimation = function(self)
            self.current_frame = 1
            self.frame_timer = 0
        end
    }
end
