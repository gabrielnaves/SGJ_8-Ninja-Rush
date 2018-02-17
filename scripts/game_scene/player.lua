Player = {}
Player.mt = { __index=Player }

Player.states = { idle='idle', moving='moving', dashing='dashing', attacking='attacking', dead='dead' }
Player.directions = { up=1, down=2, left=3, right=4 }

function Player.new()
    local t = {}
    -- Animation data
    t.idle_anims = {
        StillAnimation.new("ninja/ninja_idle_up.png", 4, 0.1, Screen.width/2, Screen.height/2, 0.5, 1),
        StillAnimation.new("ninja/ninja_idle_down.png", 4, 0.1, Screen.width/2, Screen.height/2, 0.5, 1),
        StillAnimation.new("ninja/ninja_idle_left.png", 4, 0.1, Screen.width/2, Screen.height/2, 0.5, 1),
        StillAnimation.new("ninja/ninja_idle_right.png", 4, 0.1, Screen.width/2, Screen.height/2, 0.5, 1),
    }
    t.mov_anims = {
        StillAnimation.new("ninja/ninja_moving_up.png", 6, 0.1, Screen.width/2, Screen.height/2, 0.5, 1),
        StillAnimation.new("ninja/ninja_moving_down.png", 6, 0.1, Screen.width/2, Screen.height/2, 0.5, 1),
        StillAnimation.new("ninja/ninja_moving_left.png", 6, 0.1, Screen.width/2, Screen.height/2, 0.5, 1),
        StillAnimation.new("ninja/ninja_moving_right.png", 6, 0.1, Screen.width/2, Screen.height/2, 0.5, 1),
    }
    t.direction = Player.directions.down
    t.current_anim = t.idle_anims

    -- State data
    t.state = Player.states.idle
    t.updateFunction = Player.updateIdle

    -- Movement data
    t.rect = Rectangle.new(Screen.width/2, Screen.height/2, 48, 64, 0.5, 1)
    t.velocity = Vector.new(0, 0)
    t.acceleration = Vector.new(0, 0)
    t.max_velocity = 300
    t.max_accel = 1000
    t.vel_decay = 0.85

    -- Health
    t.hp = 3

    return setmetatable(t, Player.mt)
end

function Player:update(dt)
    self:updateDirection(dt)
    self:updateFunction(dt)
    self:updateMotion(dt)
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

function Player:updateIdle(dt)
    self.current_anim[self.direction]:update(dt)
    local input = Input.inputVector()
    self.acceleration.x = input.x * self.max_accel
    self.acceleration.y = input.y * self.max_accel

    if input:magnitude() > 0.0001 then
        self.state = Player.states.moving
        self.updateFunction = self.updateMoving
        self.current_anim = self.mov_anims
    end
end

function Player:updateMoving(dt)
    self.current_anim[self.direction]:update(dt)
    local input = Input.inputVector()
    self.acceleration.x = input.x * self.max_accel
    self.acceleration.y = input.y * self.max_accel

    if input:magnitude() < 0.0001 then
        self.state = Player.states.idle
        self.updateFunction = self.updateIdle
        self.current_anim = self.idle_anims
    end
end

function Player:updateAttacking(dt)

end

function Player:updateMotion(dt)
    self:updateVelocity(dt)
    self:updatePosition(dt)
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

    if self.velocity:magnitude() > self.max_velocity then
        self.velocity = self.velocity:normalized() * self.max_velocity
    end
end

function Player:updatePosition(dt)
    self.rect.x = self.rect.x + self.velocity.x * dt
    self.rect.y = self.rect.y + self.velocity.y * dt
end

function Player:updateAnimationPositions()
    for i, anim in ipairs(self.current_anim) do
        anim.x = self.rect.x
        anim.y = self.rect.y
    end
end

function Player:draw()
    self.current_anim[self.direction]:draw()
end
