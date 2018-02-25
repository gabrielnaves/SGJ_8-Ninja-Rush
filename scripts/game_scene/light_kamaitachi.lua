LightKamaitachi = {}
LightKamaitachi.mt = { __index=LightKamaitachi }

LightKamaitachi.name = "light kamaitachi"
LightKamaitachi.states = { idle="idle", vanishing="vanishing", attacking="attacking", appearing="appearing" }
LightKamaitachi.directions = { up=1, down=2, left=3, right=4 }

function LightKamaitachi.new()
    local t = {}

    -- Animation data
    t.idle_anims = {
        StillAnimation.new("kamaitachi/kama_idle_up.png", 4, 0.1, 0, 0, 0.5, 1),
        StillAnimation.new("kamaitachi/kama_idle_down.png", 4, 0.1, 0, 0, 0.5, 1),
        StillAnimation.new("kamaitachi/kama_idle_left.png", 4, 0.1, 0, 0, 0.5, 1),
        StillAnimation.new("kamaitachi/kama_idle_right.png", 4, 0.1, 0, 0, 0.5, 1),
    }
    t.vanish_anims = {
        StillAnimation.new("kamaitachi/kama_vanish_up.png", 8, 0.1, 0, 0, 0.5, 1, false),
        StillAnimation.new("kamaitachi/kama_vanish_down.png", 8, 0.1, 0, 0, 0.5, 1, false),
        StillAnimation.new("kamaitachi/kama_vanish_left.png", 8, 0.1, 0, 0, 0.5, 1, false),
        StillAnimation.new("kamaitachi/kama_vanish_right.png", 8, 0.1, 0, 0, 0.5, 1, false),
    }
    t.appear_anims = {
        StillAnimation.new("kamaitachi/kama_vanish_up.png", 8, 0.1, 0, 0, 0.5, 1, false, true),
        StillAnimation.new("kamaitachi/kama_vanish_down.png", 8, 0.1, 0, 0, 0.5, 1, false, true),
        StillAnimation.new("kamaitachi/kama_vanish_left.png", 8, 0.1, 0, 0, 0.5, 1, false, true),
        StillAnimation.new("kamaitachi/kama_vanish_right.png", 8, 0.1, 0, 0, 0.5, 1, false, true),
    }
    t.atk_anims = {
        StillAnimation.new("kamaitachi/kama_atk.png", 4, 0.1, 0, 0, 0.5, 1),
    }
    t.direction = LightKamaitachi.directions.down
    t.current_anim = t.idle_anims

    -- State data
    t.state = LightKamaitachi.states.idle
    t.updateFunction = LightKamaitachi.updateIdle

    -- Motion data
    t.rect = Rectangle.new(Screen.width/4, Screen.height/2, 30, 20, 0.5, 1)
    t.acceleration = 2000
    t.max_vel = 1000
    t.acceleration_vector = Vector.new(0, 0)
    t.velocity = Vector.new(0, 0)

    -- Timers
    t.min_attack_cooldown = 1
    t.max_attack_cooldown = 2
    t.attack_cooldown = Mathf.randomFloat(t.min_attack_cooldown, t.max_attack_cooldown)

    t.min_attack_time = 2
    t.max_attack_time = 4
    t.attack_time = Mathf.randomFloat(t.min_attack_time, t.max_attack_time)
    t.attack_timer = 0

    t.hit_time = 0.4
    t.hit_timer = t.hit_time
    t.blink_time = 0.2
    t.blink_timer = 0

    -- Health
    t.hp = 6

    return setmetatable(t, LightKamaitachi.mt)
end

function LightKamaitachi:receiveDamage()
    if self.state == LightKamaitachi.states.idle or self.state == LightKamaitachi.states.appearing then
        if self.hit_timer > self.hit_time then
            self.hit_timer = 0
            self.hp = self.hp - 1
        end
    end
end

function LightKamaitachi:changeState(state, updateFunction, anim)
    self:resetAnimations(self.current_anim)
    self.state = state
    self.updateFunction = updateFunction
    self.current_anim = anim
    self.attack_cooldown = Mathf.randomFloat(self.min_attack_cooldown, self.max_attack_cooldown)
    self.attack_time = Mathf.randomFloat(self.min_attack_time, self.max_attack_time)
    self.attack_timer = 0
end

function LightKamaitachi:resetAnimations(anims)
    for i, anim in ipairs(anims) do
        anim:reset()
    end
end

function LightKamaitachi:update(dt, player)
    self.hit_timer = self.hit_timer + dt
    self.blink_timer = self.blink_timer + dt
    if self.blink_timer > self.blink_time then self.blink_timer = 0 end
    self.atk_anims[1]:update(dt)
    self:updateFunction(dt, player)
end

function LightKamaitachi:updateIdle(dt, player)
    self:lookAtPlayer(player)
    self.current_anim[self.direction]:update(dt)
    self.attack_timer = self.attack_timer + dt
    if self.attack_timer > self.attack_cooldown then
        self:changeState(LightKamaitachi.states.vanishing, self.updateVanishing, self.vanish_anims)
    end
end

function LightKamaitachi:lookAtPlayer(player)
    local player_pos = player.rect:position()
    local current_pos = self.rect:position()
    local angle = math.deg((player_pos - current_pos):angle())
    if math.abs(angle) <= 45 then
        self.direction = LightKamaitachi.directions.right
    elseif angle < -45 and angle >= -135 then
        self.direction = LightKamaitachi.directions.up
    elseif angle > 45 and angle <= 135 then
        self.direction = LightKamaitachi.directions.down
    else
        self.direction = LightKamaitachi.directions.left
    end
    self.attack_vector = player_pos - current_pos
end

function LightKamaitachi:updateVanishing(dt, player)
    self.current_anim[self.direction]:update(dt)
    if self.current_anim[self.direction].ended then
        self:changeState(LightKamaitachi.states.attacking, self.updateAttacking, self.atk_anims)
    end
end

function LightKamaitachi:updateAttacking(dt, player)
    self.attack_timer = self.attack_timer + dt
    self.acceleration_vector = (player.rect:position() - self.rect:position()):normalized() * self.acceleration
    self:updateVelocity(dt)
    self:updatePosition(dt)
    if self.attack_timer > self.attack_time then
        self.acceleration_vector = Vector.new(0, 0)
        self.velocity = Vector.new(0, 0)
        self:changeState(LightKamaitachi.states.appearing, self.updateAppearing, self.appear_anims)
    end
end

function LightKamaitachi:updateAppearing(dt, player)
    self.current_anim[self.direction]:update(dt)
    if self.current_anim[self.direction].ended then
        self:changeState(LightKamaitachi.states.idle, self.updateIdle, self.idle_anims)
    end
end

function LightKamaitachi:updateVelocity(dt)
    self.velocity = self.velocity + self.acceleration_vector * dt
    if self.velocity:magnitude() > self.max_vel then
        self.velocity = self.velocity:normalized() * self.max_vel
    end
end

function LightKamaitachi:updatePosition(dt)
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

function LightKamaitachi:draw()
    self:updateAnimationPositions()
    if self.state ~= LightKamaitachi.states.idle then
        self.atk_anims[1]:draw()
    end
    if self.state ~= LightKamaitachi.states.attacking then
        if self.hit_timer > self.hit_time then
            self.current_anim[self.direction]:draw()
        elseif self.blink_timer > self.blink_time/2 then
            self.current_anim[self.direction]:draw()
        end
    end
end

function LightKamaitachi:updateAnimationPositions()
    for i, anim in ipairs(self.current_anim) do
        anim:setPos(self.rect.x, self.rect.y)
    end
    self.atk_anims[1]:setPos(self.rect.x, self.rect.y)
end
