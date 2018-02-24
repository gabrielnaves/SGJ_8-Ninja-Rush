MusicManager = {}
MusicManager.mt = { __index=MusicManager }

MusicManager.tracks = {
    love.audio.newSource("assets/music/Drums 1.wav", "static"),
    love.audio.newSource("assets/music/Drums 2.wav", "static"),
    love.audio.newSource("assets/music/Drums 3.wav", "static"),
    love.audio.newSource("assets/music/Drums 4.wav", "static"),
    love.audio.newSource("assets/music/Bass 1.wav", "static"),
    love.audio.newSource("assets/music/Piano 1.wav", "static"),
    love.audio.newSource("assets/music/Flute 1.wav", "static"),
    love.audio.newSource("assets/music/Flute 2.wav", "static"),
}

function MusicManager.new()
    local t = {}
    setmetatable(t, MusicManager.mt)

    t.compass_time = 2.41
    t.timer = 0

    for i,track in ipairs(t.tracks) do
        track:setLooping(true)
        track:play()
        track:setVolume(0)
    end

    t.tracks[1]:setVolume(1)

    return t
end

function MusicManager:muteAll()
    for i,track in ipairs(self.tracks) do
        track:setVolume(0)
    end
end

function MusicManager:stopAll()
    for i,track in ipairs(self.tracks) do
        track:stop()
    end
end

function MusicManager:update(dt)

end
