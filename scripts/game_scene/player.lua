Player = {}
Player.mt = { __index=Player }

function Player.new()
    local t = {
        anim = StillAnimation.new("ninja/ninja_idle_down.png", 4, 0.1, Screen.width/2, Screen.height/2, 0.5, 0.5)
    }
    return setmetatable(t, Player.mt)
end

function Player:update(dt)
    self.anim:update(dt)
end

function Player:draw()
    self.anim:draw()
end
