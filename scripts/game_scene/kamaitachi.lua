Kamaitachi = {}
Kamaitachi.mt = { __index=Kamaitachi }

Kamaitachi.states = { idle="idle", attacking="attacking" }
Kamaitachi.directions = { up=1, down=2, left=3, right=4 }

function Kamaitachi.new()
    local t = {}

    -- Animation data
    t.idle_anims = {
        StillAnimation.new("kamaitachi/kama_idle_up.png", 4, 0.1, 0, 0, 0.5, 1),
        StillAnimation.new("kamaitachi/kama_idle_down.png", 4, 0.1, 0, 0, 0.5, 1),
        StillAnimation.new("kamaitachi/kama_idle_left.png", 4, 0.1, 0, 0, 0.5, 1),
        StillAnimation.new("kamaitachi/kama_idle_right.png", 4, 0.1, 0, 0, 0.5, 1),
    }
    t.atk_anims = {
        StillAnimation.new("kamaitachi/kama_atk_up.png", 10, 0.1, 0, 0, 0.5, 0.75),
        StillAnimation.new("kamaitachi/kama_atk_down.png", 10, 0.1, 0, 0, 0.5, 0.75),
        StillAnimation.new("kamaitachi/kama_atk_left.png", 10, 0.1, 0, 0, 0.5, 0.75),
        StillAnimation.new("kamaitachi/kama_atk_right.png", 10, 0.1, 0, 0, 0.5, 0.75),
    }
    t.direction = Kamaitachi.directions.down
    t.current_anim = t.idle_anims

    -- State data
    t.state = Kamaitachi.states.idle
    t.updateFunction = Kamaitachi.updateIdle

    -- Motion data
    t.rect = Rectangle.new(Screen.width/4, Screen.height/2, 30, 20, 0.5, 1)
    t.attack_speed = 1000
    t.attack_vector = Vector.new(0, 0)
    t.velocity = Vector.new(0, 0)

    -- Timers
    t.min_attack_cooldown = 1
    t.max_attack_cooldown = 3
    t.attack_cooldown = Mathf.randomFloat(t.min_attack_cooldown, t.max_attack_cooldown)
    t.attack_time = 0.4
    t.attack_timer = 0

    t.hit_time = 0.4
    t.hit_timer = t.hit_time
    t.blink_time = 0.2
    t.blink_timer = 0

    -- Health
    t.hp = 6

    return setmetatable(t, Kamaitachi.mt)
end

function Kamaitachi:receiveDamage()
    if self.hit_timer > self.hit_time then
        self.hit_timer = 0
        self.hp = self.hp - 1
    end
end

function Kamaitachi:changeState(state, updateFunction, anim)
    self:resetAnimations(self.current_anim)
    self.state = state
    self.updateFunction = updateFunction
    self.current_anim = anim
    self.attack_timer = 0
end

function Kamaitachi:resetAnimations(anims)
    for i, anim in ipairs(anims) do
        anim:reset()
    end
end

function Kamaitachi:update(dt, player)
    self.hit_timer = self.hit_timer + dt
    self.blink_timer = self.blink_timer + dt
    if self.blink_timer > self.blink_time then self.blink_timer = 0 end
    self:updateFunction(dt, player)
end

function Kamaitachi:updateIdle(dt, player)
    self:lookAtPlayer(player)
    self.current_anim[self.direction]:update(dt)
    self.attack_timer = self.attack_timer + dt
    if self.attack_timer > self.attack_cooldown then
        self.attack_angle = angle
        self:changeState(Kamaitachi.states.attacking, self.updateAttacking, self.atk_anims)
    end
end

function Kamaitachi:lookAtPlayer(player)
    local player_pos = player.rect:position()
    local current_pos = self.rect:position()
    local angle = math.deg((player_pos - current_pos):angle())
    if math.abs(angle) <= 45 then
        self.direction = Kamaitachi.directions.right
    elseif angle < -45 and angle >= -135 then
        self.direction = Kamaitachi.directions.up
    elseif angle > 45 and angle <= 135 then
        self.direction = Kamaitachi.directions.down
    else
        self.direction = Kamaitachi.directions.left
    end
    self.attack_vector = player_pos - current_pos
end

function Kamaitachi:updateAttacking(dt, player)
    self:synchronizeAnimation()
    if self.current_anim[self.direction].current_frame < self.current_anim[self.direction].frame_count then
        self:lookAtPlayer(player)
        self.current_anim[self.direction]:update(dt)
    else
        self.velocity = self.attack_vector:normalized() * self.attack_speed
        self:updatePosition(dt)
        self.attack_timer = self.attack_timer + dt
        if self.attack_timer > self.attack_time then
            self.attack_cooldown = love.math.random()*(self.max_attack_cooldown-self.min_attack_cooldown) + self.min_attack_cooldown
            self:changeState(Kamaitachi.states.idle, self.updateIdle, self.idle_anims)
        end
    end
end

function Kamaitachi:synchronizeAnimation()
    for i, anim in ipairs(self.current_anim) do
        anim.frame_timer = self.current_anim[self.direction].frame_timer
        anim.current_frame = self.current_anim[self.direction].current_frame
    end
end

function Kamaitachi:updatePosition(dt)
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

function Kamaitachi:draw()
    self:updateAnimationPositions()
    if self.hit_timer > self.hit_time then
        self.current_anim[self.direction]:draw()
    elseif self.blink_timer > self.blink_time/2 then
        self.current_anim[self.direction]:draw()
    end
end

function Kamaitachi:updateAnimationPositions()
    for i, anim in ipairs(self.current_anim) do
        anim.x = self.rect.x
        anim.y = self.rect.y
    end
end
