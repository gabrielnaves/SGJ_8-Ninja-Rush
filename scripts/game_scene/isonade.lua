Isonade = {}
Isonade.mt = { __index=Isonade }

Isonade.name = "isonade"
Isonade.states = { idle="idle", appearing="appearing", vanishing="vanishing", following="following" }

function Isonade.new()
    local t = {}

    -- Animation data
    t.appearing_anim = StillAnimation.new("isonade/isonade_appearing.png", 47, 0.01, 0, 0, 0.5, 1, false)
    t.idle_anim = StillAnimation.new("isonade/isonade_idle.png", 2, 1, 0, 0, 0.5, 1)
    t.vanish_anim = StillAnimation.new("isonade/isonade_appearing.png", 47, 0.01, 0, 0, 0.5, 1, false, true)

    -- State data
    t.state = Isonade.states.idle
    t.updateFunction = Isonade.updateIdle
    t.drawFunction = Isonade.drawIdle

    -- Motion data
    t.rect = Rectangle.new(Screen.width/4, Screen.height/2, 162, 30, 0.5, 1)
    t.move_speed = 200
    t.velocity = Vector.new(0, 0)

    -- Timers
    t.idle_time = 2
    t.follow_time = 2
    t.timer = 0

    t.hit_time = 0.4
    t.hit_timer = t.hit_time
    t.blink_time = 0.2
    t.blink_timer = 0

    -- Health
    t.hp = 16

    return setmetatable(t, Isonade.mt)
end

function Isonade:receiveDamage()
    if self.hit_timer > self.hit_time and
       (self.state == self.states.idle or self.state == self.states.appearing) then
        self.hit_timer = 0
        self.hp = self.hp - 1
        self.move_speed = self.move_speed + 20
        self.idle_time = self.idle_time - 0.07
    end
end

function Isonade:changeState(state, updateFunction, drawFunction)
    self:resetAnimations()
    self.state = state
    self.updateFunction = updateFunction
    self.drawFunction = drawFunction
    self.timer = 0
end

function Isonade:resetAnimations(anims)
    self.appearing_anim:reset()
    self.idle_anim:reset()
    self.vanish_anim:reset()
end

function Isonade:update(dt, player)
    self.hit_timer = self.hit_timer + dt
    self.blink_timer = self.blink_timer + dt
    if self.blink_timer > self.blink_time then self.blink_timer = 0 end
    self:updateFunction(dt, player)
end

function Isonade:updateIdle(dt, player)
    self.idle_anim:update(dt)
    self.timer = self.timer + dt
    if self.timer > self.idle_time then
        self:changeState(self.states.vanishing, self.updateVanishing, self.drawVanishing)
    end
end

function Isonade:updateVanishing(dt, player)
    self.vanish_anim:update(dt)
    if self.vanish_anim.ended then
        self:changeState(self.states.following, self.updateFollowing, self.drawFollowing)
    end
end

function Isonade:updateFollowing(dt, player)
    self.velocity = (player.rect:position() - self.rect:position()):normalized() * self.move_speed
    self:updatePosition(dt)
    self.timer = self.timer + dt
    if self.timer > self.follow_time then
        self:changeState(self.states.appearing, self.updateAppearing, self.drawAppearing)
    end
end

function Isonade:updateAppearing(dt, player)
    self.appearing_anim:update(dt)
    if self.appearing_anim.ended then
        self:changeState(self.states.idle, self.updateIdle, self.drawIdle)
    end
end

function Isonade:updatePosition(dt)
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

function Isonade:draw()
    self:updateAnimationPositions()
    if self.hit_timer > self.hit_time then
        self:drawFunction()
    elseif self.blink_timer > self.blink_time/2 then
        self:drawFunction()
    end
end

function Isonade:drawAppearing()
    self.appearing_anim:draw()
end

function Isonade:drawIdle()
    self.idle_anim:draw()
end

function Isonade:drawVanishing()
    self.vanish_anim:draw()
end

function Isonade:drawFollowing()
    self.appearing_anim:draw()
end

function Isonade:updateAnimationPositions()
    self.appearing_anim:setPosFromVector(self.rect:position())
    self.idle_anim:setPosFromVector(self.rect:position())
    self.vanish_anim:setPosFromVector(self.rect:position())
end
