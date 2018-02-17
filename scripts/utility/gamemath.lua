gamemath = {}

function gamemath.clamp(value, max, min)
    return math.max(math.min(value, max), min)
end
