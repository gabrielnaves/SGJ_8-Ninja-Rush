Player = {}
Player.mt = { __index=Player }

Player.name = "player"
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
    t.atk_anims = {
        StillAnimation.new("ninja/ninja_attack_up.png", 7, 0.04, Screen.width/2, Screen.height/2, 0.5, 0.75),
        StillAnimation.new("ninja/ninja_attack_down.png", 7, 0.04, Screen.width/2, Screen.height/2, 0.5, 0.75),
        StillAnimation.new("ninja/ninja_attack_left.png", 7, 0.04, Screen.width/2, Screen.height/2, 0.5, 0.75),
        StillAnimation.new("ninja/ninja_attack_right.png", 7, 0.04, Screen.width/2, Screen.height/2, 0.5, 0.75),
    }
    t.direction = Player.directions.down
    t.current_anim = t.idle_anims

    -- State data
    t.state = Player.states.idle
    t.updateFunction = Player.updateIdle

    -- Movement data
    t.rect = Rectangle.new(Screen.width/2, Screen.height/2, 30, 20, 0.5, 1)
    t.velocity = Vector.new(0, 0)
    t.acceleration = Vector.new(0, 0)
    t.max_velocity = 400
    t.max_accel = 2000
    t.vel_decay = 0.6
    t.dash_input = nil
    t.max_dash_velocity = 4000

    -- Health
    t.hp = 5

    -- Timers
    t.attack_cooldown = 0.2
    t.attack_timer = 0

    t.dash_cooldown = 1
    t.dash_time = 0.05
    t.dash_timer = 0

    t.hit_time = 0.8
    t.hit_timer = t.hit_time
    t.blink_time = 0.2
    t.blink_timer = 0

    return setmetatable(t, Player.mt)
end

function Player:changeState(state, updateFunction, anim)
    self:resetAnimations(self.current_anim)
    self.state = state
    self.updateFunction = updateFunction
    self.current_anim = anim
end

function Player:receiveDamage(enemy)
    if self.hit_timer > self.hit_time and not GODMODE then
        self.hit_timer = 0
        self.hp = self.hp - 1
        local current_pos = Vector.new(self.rect.x, self.rect.y)
        local enemy_pos = Vector.new(enemy.rect.x, enemy.rect.y)
        self.velocity = (current_pos - enemy_pos):normalized() * self.max_velocity
    end
end

function Player:update(dt)
    self:updateFixedTimers(dt)
    self:updateDirection(dt)
    self:updateFunction(dt)
    self:updateMotion(dt)
end

function Player:updateFixedTimers(dt)
    self.attack_timer = self.attack_timer + dt
    self.dash_timer = self.dash_timer + dt
    self.hit_timer = self.hit_timer + dt
    self.blink_timer = self.blink_timer + dt
    if self.blink_timer > self.blink_time then self.blink_timer = 0 end
end

function Player:updateDirection()
    if self.state ~= Player.states.attacking then
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
end

function Player:updateIdle(dt)
    self.current_anim[self.direction]:update(dt)
    local input = Input.inputVector()
    self.acceleration = input * self.max_accel

    if input:magnitude() > 0.0001 then
        self:changeState(Player.states.moving, self.updateMoving, self.mov_anims)
    end
    if Input.attack_button and self.attack_timer > self.attack_cooldown then
        self:changeState(Player.states.attacking, self.updateAttacking, self.atk_anims)
        self.attack_timer = 0
    end
end

function Player:updateMoving(dt)
    self.current_anim[self.direction]:update(dt)
    local input = Input.inputVector()
    self.acceleration = input * self.max_accel

    if input:magnitude() < 0.0001 then
        self:changeState(Player.states.idle, self.updateIdle, self.idle_anims)
    end
    if Input.attack_button and self.attack_timer > self.attack_cooldown then
        self:changeState(Player.states.attacking, self.updateAttacking, self.atk_anims)
        self.attack_timer = 0
    elseif Input.dash_button and self.dash_timer > self.dash_cooldown and input:magnitude() > 0.0001 then
        self.dash_input = input
        self:changeState(Player.states.dashing, self.updateDashing, self.mov_anims)
        self.dash_timer = 0
    end
end

function Player:updateAttacking(dt)
    self.acceleration = Vector.new(0, 0)
    self.current_anim[self.direction]:update(dt)
    if self.current_anim[self.direction].current_frame == self.current_anim[self.direction].frame_count then
        self.attack_timer = 0
        self:changeState(Player.states.idle, self.updateIdle, self.idle_anims)
    end
end

function Player:updateDashing(dt)
    self.current_anim[self.direction]:update(dt)
    self.velocity = self.dash_input * self.max_dash_velocity
    if self.dash_timer > self.dash_time then
        self.dash_timer = 0
        self:changeState(Player.states.idle, self.updateIdle, self.idle_anims)
    end
end

function Player:updateMotion(dt)
    self:updateVelocity(dt)
    self:updatePosition(dt)
end

function Player:updateVelocity(dt)
    if self.state ~= Player.states.dashing then
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
end

function Player:updatePosition(dt)
    self.rect.x = self.rect.x + self.velocity.x * dt
    self.rect.y = self.rect.y + self.velocity.y * dt

    -- Check X limits
    if self.rect:topLeft().x < Screen.left_bound then
        self.rect.x = Screen.left_bound + self.rect.width*self.rect.pivotX
        self.velocity.x = 0
    elseif self.rect:bottomRight().x > Screen.right_bound then
        self.rect.x = Screen.right_bound - self.rect.width*(1-self.rect.pivotX)
        self.velocity.x = 0
    end

    -- Check Y limits
    if self.rect:topRight().y < Screen.upper_bound then
        self.rect.y = Screen.upper_bound + self.rect.height*self.rect.pivotY
        self.velocity.y = 0
    elseif self.rect:bottomLeft().y > Screen.lower_bound then
        self.rect.y = Screen.lower_bound - self.rect.height*(1-self.rect.pivotY)
        self.velocity.y = 0
    end
end

function Player:resetAnimations(anims)
    for i, anim in ipairs(anims) do
        anim:reset()
    end
end

function Player:draw()
    self:updateAnimationPositions()
    if self.hit_timer > self.hit_time then
        self.current_anim[self.direction]:draw()
    elseif self.blink_timer > self.blink_time / 2 then
        self.current_anim[self.direction]:draw()
    end
end

function Player:updateAnimationPositions()
    for i, anim in ipairs(self.current_anim) do
        anim.x = self.rect.x
        anim.y = self.rect.y
    end
end
