Gashadokuro = {}
Gashadokuro.mt = { __index=Gashadokuro }

Gashadokuro.name = "gashadokuro"

function Gashadokuro.new(size)
    local t = {}
    local x, y = Screen.width/2, Screen.height/2

    t.size = size
    if size == "big" then
        t.image = StillImage.new("gashadokuro/gashadokuro_big.png", x, y, 0.5, 1)
        t.rect = Rectangle.new(x, y, 60, 40, 0.5, 1)
        t.hp = love.math.random(6, 10)
        t.max_speed = Mathf.randomFloat(120, 220)
    elseif size == "medium" then
        t.image = StillImage.new("gashadokuro/gashadokuro_med.png", x, y, 0.5, 1)
        t.rect = Rectangle.new(x, y, 30, 20, 0.5, 1)
        t.hp = love.math.random(4, 6)
        t.max_speed = Mathf.randomFloat(180, 280)
    else
        t.image = StillImage.new("gashadokuro/gashadokuro_small.png", x, y, 0.5, 1)
        t.rect = Rectangle.new(x, y, 15, 10, 0.5, 1)
        t.hp = love.math.random(2, 4)
        t.max_speed = Mathf.randomFloat(240, 360)
    end

    -- Motion data
    t.angle = math.rad(Mathf.randomFloat(-180, 180))
    t.velocity = Vector.new(0, 0)

    -- Timers
    t.hit_time = 0.4
    t.hit_timer = t.hit_time
    t.blink_time = 0.2
    t.blink_timer = 0

    return setmetatable(t, Gashadokuro.mt)
end

function Gashadokuro:receiveDamage(player)
    if self.hit_timer > self.hit_time then
        self.hit_timer = 0
        self.hp = self.hp - 1

        self.angle = (self.rect:position()-player.rect:position()):angle()

        if self.hp == 0 and self.size ~= "small" then
            local entities = SceneManager.current_scene.entities
            if self.size == "big" then
                table.insert(entities, Gashadokuro.new("medium"))
                table.insert(entities, Gashadokuro.new("medium"))
                entities[#entities - 1].rect.x, entities[#entities - 1].rect.y = EnemySpawner.randomPosition()
                entities[#entities].rect.x, entities[#entities].rect.y = EnemySpawner.randomPosition()
            else
                table.insert(entities, Gashadokuro.new("small"))
                table.insert(entities, Gashadokuro.new("small"))
                entities[#entities - 1].rect.x, entities[#entities - 1].rect.y = EnemySpawner.randomPosition()
                entities[#entities].rect.x, entities[#entities].rect.y = EnemySpawner.randomPosition()
            end
        end
    end
end

function Gashadokuro:update(dt, player)
    self.hit_timer = self.hit_timer + dt
    self.blink_timer = self.blink_timer + dt
    if self.blink_timer > self.blink_time then self.blink_timer = 0 end

    self.velocity = Vector.fromPolar(self.max_speed, self.angle)
    self:updatePosition(dt)
end

function Gashadokuro:updateVelocity(dt)
    self.velocity = self.velocity + self.acceleration * dt
    if self.velocity:magnitude() > self.max_speed then
        self.velocity = self.velocity:normalized() * self.max_speed
    end
end

function Gashadokuro:updatePosition(dt)
    self.rect.x = self.rect.x + self.velocity.x * dt
    self.rect.y = self.rect.y + self.velocity.y * dt

    -- Check X limits
    if self.rect:topLeft().x < Screen.left_bound then
        self.rect.x = Screen.left_bound + self.rect.width*self.rect.pivotX
        if self.angle > 0 then self.angle = math.rad(180) - self.angle
        else self.angle = math.rad(-180) - self.angle end
    elseif self.rect:bottomRight().x > Screen.right_bound then
        self.rect.x = Screen.right_bound - self.rect.width*(1-self.rect.pivotX)
        if self.angle < 0 then self.angle = math.rad(-180) - self.angle
        else self.angle = math.rad(180) - self.angle end
    end

    -- Check Y limits
    if self.rect:topRight().y < Screen.upper_bound then
        self.rect.y = Screen.upper_bound + self.rect.height*self.rect.pivotY
        self.angle = -self.angle
    elseif self.rect:bottomLeft().y > Screen.lower_bound then
        self.rect.y = Screen.lower_bound - self.rect.height*(1-self.rect.pivotY)
        self.angle = -self.angle
    end
end

function Gashadokuro:draw()
    self.image.x, self.image.y = self.rect.x, self.rect.y
    if self.hit_timer > self.hit_time then
        self.image:draw()
    elseif self.blink_timer > self.blink_time/2 then
        self.image:draw()
    end
end
