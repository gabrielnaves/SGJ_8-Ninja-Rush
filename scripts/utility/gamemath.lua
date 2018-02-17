Gamemath = {}

function Gamemath.clamp(value, max, min)
    return math.max(math.min(value, max), min)
end
