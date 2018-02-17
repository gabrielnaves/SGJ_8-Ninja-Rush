Vector = {}
Vector.mt = {
    __index = Vector,
    __add = function (lhs, rhs)
        return Vector.new(lhs.x+rhs.x, lhs.y + rhs.y)
    end,
    __mul = function (lhs, rhs)
        return Vector.new(lhs.x*rhs, lhs.y * rhs)
    end,
}

function Vector.new(x, y)
    if math.abs(x) < 1e-10 then x = 0 end
    if math.abs(y) < 1e-10 then y = 0 end
    return setmetatable({ x=x, y=y }, Vector.mt)
end

function Vector.fromPolar(mag, th)
    return Vector.new(mag*math.cos(th), mag*math.sin(th))
end

function Vector:magnitude()
    return math.sqrt(self.x*self.x + self.y*self.y)
end

function Vector:angle()
    return math.atan2(self.y, self.x)
end

function Vector:normalized()
    if self.x == 0 and self.y == 0 then return self end
    return Vector.fromPolar(1, self:angle())
end

Rectangle = {}

function Rectangle.new(x, y, width, height, pivotX, pivotY)
    pivotX = pivotX or 0.0
    pivotY = pivotY or 0.0
    local mt = { __index=Rectangle }
    local t = { x=x, y=y, width=width, height=height, pivotX=pivotX, pivotY=pivotY }
    return setmetatable(t, mt)
end

function Rectangle:topLeft()
    return Vector.new(self.x - self.width*self.pivotX, self.y - self.height*self.pivotY)
end

function Rectangle:topRight()
    return Vector.new(self.x + self.width*(1-self.pivotX), self.y - self.height*self.pivotY)
end

function Rectangle:bottomLeft()
    return Vector.new(self.x - self.width*self.pivotX, self.y + self.height*(1-self.pivotY))
end

function Rectangle:bottomRight()
    return Vector.new(self.x + self.width*(1-self.pivotX), self.y + self.height*(1-self.pivotY))
end

function Rectangle:overlapping(other)
    return Geometry.overlappingRects(self, other)
end

Geometry = {}

function Geometry.pointInRect(point, rect)
    local rx = rect.x - rect.width*rect.pivotX
    local ry = rect.y - rect.height*rect.pivotY
    return point.x > rx and point.x < rx+rect.width and
           point.y > ry and point.y < ry+rect.height
end

function Geometry.overlappingRects(rect1, rect2)
    local rx1 = rect1.x - rect1.width*rect1.pivotX
    local ry1 = rect1.y - rect1.height*rect1.pivotY
    local rx2 = rect2.x - rect2.width*rect2.pivotX
    local ry2 = rect2.y - rect2.height*rect2.pivotY

    return rx2 < rx1+rect1.width and rx1 < rx2+rect2.width and
           ry2 < ry1+rect1.height and ry1 < ry2+rect2.height
end
