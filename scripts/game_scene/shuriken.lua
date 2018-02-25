Shuriken = {}
Shuriken.mt = { __index=Shuriken }

function Shuriken.new(x, y, dir)
    local t = {}
    t.anim = StillAnimation.new("yami ninja/shuriken.png", 4, 0.1, x, y, 0.5, 0.5)
    t.rect = Rectangle.new(x, y, t.anim.width, t.anim.height, 0.5, 0.5)
    t.vel = 400
    t.velocity = dir:normalized() * t.vel
    return setmetatable(t, Shuriken.mt)
end

function Shuriken:update(dt, player)
    self.anim:update(dt)
    self.rect.x = self.rect.x + self.velocity.x * dt
    self.rect.y = self.rect.y + self.velocity.y * dt

    if self.rect:overlapping(player.rect) then
        player:receiveDamage(self)
    end
end

function Shuriken:draw()
    self.anim:setPosFromVector(self.rect:position())
    self.anim:draw()
end
