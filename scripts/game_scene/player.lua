Player = {}
Player.mt = { __index=Player }

Player.states = { idle='idle', moving='moving', dashing='dashing', attacking='attacking', dead='dead' }
Player.directions = { up=1, down=2, left=3, right=4 }

function Player.new()
    local t = {}
    -- Animation data
    t.anims = {
        StillAnimation.new("ninja/ninja_idle_up.png", 4, 0.1, Screen.width/2, Screen.height/2, 0.5, 1),
        StillAnimation.new("ninja/ninja_idle_down.png", 4, 0.1, Screen.width/2, Screen.height/2, 0.5, 1),
        StillAnimation.new("ninja/ninja_idle_left.png", 4, 0.1, Screen.width/2, Screen.height/2, 0.5, 1),
        StillAnimation.new("ninja/ninja_idle_right.png", 4, 0.1, Screen.width/2, Screen.height/2, 0.5, 1),
    }
    t.direction = Player.directions.down

    -- State data
    t.state = Player.states.idle
    t.updateFunction = Player.updateIdle

    -- Movement data
    t.rect = Rectangle.new(Screen.width/2, Screen.height/2, 48, 64, 0.5, 1)
    t.velocity = Vector.new(0, 0)
    t.acceleration = Vector.new(0, 0)
    t.max_velocity = 400
    t.max_accel = 1000
    t.vel_decay = 0.9

    return setmetatable(t, Player.mt)
end

function Player:update(dt)
    self:updateFunction(dt)
    self:updateMotion(dt)
end

function Player:updateIdle(dt)
    self.anims[self.direction]:update(dt)
    local input = Input.inputVector()
    self.acceleration.x = input.x * self.max_accel
    self.acceleration.y = input.y * self.max_accel
end

function Player:updateMotion(dt)
    self:updateVelocity(dt)
    self:updatePosition(dt)
    self:updateDirection(dt)
    self:updateAnimationPositions(dt)
end

function Player:updateVelocity(dt)
    if self.acceleration.x ~= 0 then
        self.velocity.x = self.velocity.x + self.acceleration.x * dt
    else
        self.velocity.x = self.velocity.x * self.vel_decay
    end
    if self.acceleration.y ~= 0 then
        self.velocity.y = self.velocity.y + self.acceleration.y * dt
    else
        self.velocity.y = self.velocity.y * self.vel_decay
    end

    self.velocity.x = Mathf.clamp(self.velocity.x, self.max_velocity, -self.max_velocity)
    self.velocity.y = Mathf.clamp(self.velocity.y, self.max_velocity, -self.max_velocity)
end

function Player:updatePosition(dt)
    self.rect.x = self.rect.x + self.velocity.x * dt
    self.rect.y = self.rect.y + self.velocity.y * dt
end

function Player:updateDirection()
    if Input.horizontal() > 0 then
        self.direction = Player.directions.right
    end
    if Input.horizontal() < 0 then
        self.direction = Player.directions.left
    end
    if Input.vertical() > 0 then
        self.direction = Player.directions.down
    end
    if Input.vertical() < 0 then
        self.direction = Player.directions.up
    end
end

function Player:updateAnimationPositions()
    for i, anim in ipairs(self.anims) do
        anim.x = self.rect.x
        anim.y = self.rect.y
    end
end

function Player:draw()
    self.anims[self.direction]:draw()
end
