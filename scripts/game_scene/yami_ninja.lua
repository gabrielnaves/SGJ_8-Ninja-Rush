require("scripts.game_scene.shuriken")

YamiNinja = {}
YamiNinja.mt = { __index=YamiNinja }

YamiNinja.name = "yami ninja"
YamiNinja.states = { idle='idle', moving='moving' }
YamiNinja.directions = { up=1, down=2, left=3, right=4 }

function YamiNinja.new()
    local t = {}
    -- Animation data
    t.idle_anims = {
        StillAnimation.new("yami ninja/yami_ninja_idle_up.png", 4, 0.1, 0, 0, 0.5, 1),
        StillAnimation.new("yami ninja/yami_ninja_idle_down.png", 4, 0.1, 0, 0, 0.5, 1),
        StillAnimation.new("yami ninja/yami_ninja_idle_left.png", 4, 0.1, 0, 0, 0.5, 1),
        StillAnimation.new("yami ninja/yami_ninja_idle_right.png", 4, 0.1, 0, 0, 0.5, 1),
    }
    t.mov_anims = {
        StillAnimation.new("yami ninja/yami_ninja_moving_up.png", 4, 0.1, 0, 0, 0.5, 1),
        StillAnimation.new("yami ninja/yami_ninja_moving_down.png", 4, 0.1, 0, 0, 0.5, 1),
        StillAnimation.new("yami ninja/yami_ninja_moving_left.png", 4, 0.1, 0, 0, 0.5, 1),
        StillAnimation.new("yami ninja/yami_ninja_moving_right.png", 4, 0.1, 0, 0, 0.5, 1),
    }
    t.direction = YamiNinja.directions.down
    t.current_anim = t.idle_anims

    -- State data
    t.state = YamiNinja.states.idle
    t.updateFunction = YamiNinja.updateIdle

    -- Movement data
    t.rect = Rectangle.new(Screen.width/2, Screen.height/2, 30, 20, 0.5, 1)
    t.velocity = Vector.new(0, 0)
    t.acceleration = Vector.new(0, 0)
    t.max_velocity = 400
    t.max_accel = 2000
    t.vel_decay = 0.6
    t.proximity = 200

    -- Health
    t.hp = 10

    -- Timers
    t.attack_cooldown = SceneManager.current_scene.music_manager.loop_time/2
    t.attack_timer = 0
    t.ult_cooldown = 4*t.attack_cooldown
    t.ult_timer = 0

    t.hit_time = 0.8
    t.hit_timer = t.hit_time
    t.blink_time = 0.2
    t.blink_timer = 0

    t.projectiles = {}

    return setmetatable(t, YamiNinja.mt)
end

function YamiNinja:receiveDamage(player)
    if self.hit_timer > self.hit_time then
        self.hit_timer = 0
        self.hp = self.hp - 1
        local current_pos = Vector.new(self.rect.x, self.rect.y)
        local player_pos = Vector.new(player.rect.x, player.rect.y)
        self.velocity = (current_pos - player_pos):normalized() * self.max_velocity
    end
end

function YamiNinja:changeState(state, updateFunction, anim)
    self:resetAnimations()
    self.state = state
    self.updateFunction = updateFunction
    self.current_anim = anim
end

function YamiNinja:resetAnimations()
    for i, anim in ipairs(self.idle_anims) do
        anim:reset()
    end
    for i, anim in ipairs(self.mov_anims) do
        anim:reset()
    end
end

function YamiNinja:update(dt, player)
    self:updateFixedTimers(dt, player)
    self:updateFunction(dt, player)
    self:updateProjectiles(dt, player)
    self:updateMotion(dt)
end

function YamiNinja:updateFixedTimers(dt, player)
    self.hit_timer = self.hit_timer + dt
    self.blink_timer = self.blink_timer + dt
    if self.blink_timer > self.blink_time then self.blink_timer = 0 end

    self.attack_timer = self.attack_timer + dt
    if self.attack_timer > self.attack_cooldown then
        self.attack_timer = self.attack_timer - self.attack_cooldown
        self:throwShuriken(player)
    end
    self.ult_timer = self.ult_timer + dt
    if self.ult_timer > self.ult_cooldown then
        self.ult_timer = self.ult_timer - self.ult_cooldown
        self:ult()
    end
end

function YamiNinja:updateIdle(dt, player)
    self:lookAtPlayer(player)
    self.current_anim[self.direction]:update(dt)
    if (player.rect:position()-self.rect:position()):magnitude() < self.proximity then
        self:changeState(self.states.moving, self.updateMoving, self.mov_anims)
        self.random_angle = Mathf.randomFloat(math.rad(30), math.rad(60))
        if love.math.random() > 0.5 then self.random_angle = -self.random_angle end
    end
end

function YamiNinja:updateMoving(dt, player)
    self:lookAtPlayer(player)
    self.current_anim[self.direction]:update(dt)
    local distance_vector = self.rect:position()-player.rect:position()
    local player_distance = distance_vector:magnitude()
    if player_distance > self.proximity then
        self:changeState(self.states.idle, self.updateIdle, self.idle_anims)
        self.acceleration = Vector.new(0, 0)
    else
        local accel = (player_distance / self.proximity) * self.max_accel
        distance_vector = Vector.fromPolar(player_distance, distance_vector:angle() + self.random_angle)
        self.acceleration = distance_vector:normalized() * accel
    end
end

function YamiNinja:lookAtPlayer(player)
    local player_pos = player.rect:position()
    local current_pos = self.rect:position()
    local angle = math.deg((player_pos - current_pos):angle())
    if math.abs(angle) <= 45 then
        self.direction = self.directions.right
    elseif angle < -45 and angle >= -135 then
        self.direction = self.directions.up
    elseif angle > 45 and angle <= 135 then
        self.direction = self.directions.down
    else
        self.direction = self.directions.left
    end
    self.attack_vector = player_pos - current_pos
end

function YamiNinja:updateMotion(dt)
    self:updateVelocity(dt)
    self:updatePosition(dt)
end

function YamiNinja:updateVelocity(dt)
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

function YamiNinja:updatePosition(dt)
    self.rect.x = self.rect.x + self.velocity.x * dt
    self.rect.y = self.rect.y + self.velocity.y * dt

    -- Check X limits
    if self.rect:topLeft().x < Screen.left_bound then
        self.rect.x = Screen.left_bound + self.rect.width*self.rect.pivotX
        self.velocity.x = self.max_velocity * 2.5
        self.random_angle = math.abs(self.random_angle)
    elseif self.rect:bottomRight().x > Screen.right_bound then
        self.rect.x = Screen.right_bound - self.rect.width*(1-self.rect.pivotX)
        self.velocity.x = -self.max_velocity * 2.5
        self.random_angle = math.abs(self.random_angle)
    end

    -- Check Y limits
    if self.rect:topRight().y < Screen.upper_bound then
        self.rect.y = Screen.upper_bound + self.rect.height*self.rect.pivotY
        self.velocity.y = self.max_velocity * 2.5
        self.random_angle = math.abs(self.random_angle)
    elseif self.rect:bottomLeft().y > Screen.lower_bound then
        self.rect.y = Screen.lower_bound - self.rect.height*(1-self.rect.pivotY)
        self.velocity.y = -self.max_velocity * 2.5
        self.random_angle = math.abs(self.random_angle)
    end
end

function YamiNinja:throwShuriken(player)
    local shuriken = Shuriken.new(self.rect.x, self.rect.y - self.rect.height/2,
                                  player.rect:position()-self.rect:position())
    table.insert(self.projectiles, shuriken)
end

function YamiNinja:ult()
    local shuriken = nil
    for i=0,330,30 do
        shuriken = Shuriken.new(self.rect.x, self.rect.y - self.rect.height/2,
                                Vector.fromPolar(1, math.rad(i)))
        table.insert(self.projectiles, shuriken)
    end
end

function YamiNinja:updateProjectiles(dt, player)
    for i,projectile in ipairs(self.projectiles) do
        projectile:update(dt, player)
    end
    local index = 1
    while index <= #self.projectiles do
        if self.projectiles[index].rect.x > Screen.right_bound or
           self.projectiles[index].rect.x < Screen.left_bound or
           self.projectiles[index].rect.y > Screen.lower_bound or
           self.projectiles[index].rect.y < Screen.upper_bound then
            table.remove(self.projectiles, index)
        else
            index = index + 1
        end
    end
end

function YamiNinja:draw()
    self:updateAnimationPositions()
    if self.hit_timer > self.hit_time then
        self.current_anim[self.direction]:draw()
    elseif self.blink_timer > self.blink_time / 2 then
        self.current_anim[self.direction]:draw()
    end
    for i,projectile in ipairs(self.projectiles) do
        projectile:draw()
    end
end

function YamiNinja:updateAnimationPositions()
    for i, anim in ipairs(self.current_anim) do
        anim:setPosFromVector(self.rect:position())
    end
end
