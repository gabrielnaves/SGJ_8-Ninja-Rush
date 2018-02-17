Mathf = {}

function Mathf.clamp(value, max, min)
    return math.max(math.min(value, max), min)
end

function Mathf.lerp(start_val, end_val, percentage)
    return start_val + (end_val - start_val) * percentage
end
