Kamaitachi = {}
Kamaitachi.mt = { __index=Kamaitachi }

Kamaitachi.states = { idle="idle", attacking="attacking", dead="dead" }
Kamaitachi.directions = { up=1, down=2, left=3, right=4 }

function Kamaitachi.new()
    local t = {}

    -- Animation data
    t.idle_anims = {
        StillAnimation.new("kamaitachi/kama_idle_up.png", 4, 0.1, Screen.width/4, Screen.height/2, 0.5, 1),
        StillAnimation.new("kamaitachi/kama_idle_down.png", 4, 0.1, Screen.width/4, Screen.height/2, 0.5, 1),
        StillAnimation.new("kamaitachi/kama_idle_left.png", 4, 0.1, Screen.width/4, Screen.height/2, 0.5, 1),
        StillAnimation.new("kamaitachi/kama_idle_right.png", 4, 0.1, Screen.width/4, Screen.height/2, 0.5, 1),
    }
    t.atk_anims = {
        StillAnimation.new("kamaitachi/kama_idle_up.png", 4, 0.1, Screen.width/4, Screen.height/2, 0.5, 1),
        StillAnimation.new("kamaitachi/kama_idle_down.png", 4, 0.1, Screen.width/4, Screen.height/2, 0.5, 1),
        StillAnimation.new("kamaitachi/kama_idle_left.png", 4, 0.1, Screen.width/4, Screen.height/2, 0.5, 1),
        StillAnimation.new("kamaitachi/kama_idle_right.png", 4, 0.1, Screen.width/4, Screen.height/2, 0.5, 1),
    }
    t.direction = Kamaitachi.directions.down
    t.current_anim = t.idle_anims

    -- State data
    t.state = Kamaitachi.states.idle
    t.updateFunction = Kamaitachi.updateIdle

    -- Motion data
    t.rect = Rectangle.new(3*Screen.width/4, Screen.height/3, 30, 20, 0.5, 1)
    t.attack_angle = 0

    -- Timers
    t.attack_cooldown = 2
    t.attack_timer = 0

    return setmetatable(t, Kamaitachi.mt)
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
    self:updateFunction(dt, player)
end

function Kamaitachi:updateIdle(dt, player)
    local player_pos = Vector.new(player.rect.x, player.rect.y)
    local current_pos = Vector.new(self.rect.x, self.rect.y)
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
    self.current_anim[self.direction]:update(dt)
    self.attack_timer = self.attack_timer + dt
    if self.attack_timer > self.attack_cooldown then
        self.attack_angle = angle
        self:changeState(Kamaitachi.states.attacking, self.updateAttacking, self.atk_anims)
    end
end

function Kamaitachi.updateAttacking(dt, player)

end

function Kamaitachi:draw()
    self:updateAnimationPositions()
    self.current_anim[self.direction]:draw()
end

function Kamaitachi:updateAnimationPositions()
    for i, anim in ipairs(self.current_anim) do
        anim.x = self.rect.x
        anim.y = self.rect.y
    end
end
