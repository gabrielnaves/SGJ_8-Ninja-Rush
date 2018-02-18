Kamaitachi = {}
Kamaitachi.mt = { __index=Kamaitachi }

Kamaitachi.states = { idle="idle", preparing_attack="preparing attack", attacking="attacking" }
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
    t.direction = Kamaitachi.directions.down
    t.current_anim = t.idle_anims

    -- State data
    t.state = Kamaitachi.states.idle
    t.updateFunction = Kamaitachi.updateIdle

    -- Motion data
    t.rect = Rectangle.new(Screen.width/4, Screen.height/2, 30, 20, 0.5, 1)

    return setmetatable(t, Kamaitachi.mt)
end

function Kamaitachi:changeState(state, updateFunction, anim)
    self:resetAnimations(self.current_anim)
    self.state = state
    self.updateFunction = updateFunction
    self.current_anim = anim
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
end

function Kamaitachi:draw()
    self.current_anim[self.direction]:draw()
end

