MusicManager = {}
MusicManager.mt = { __index=MusicManager }

MusicManager.tracks = {
    { src=love.audio.newSource("assets/music/1(FLUTE)F.wav", "static"), vol=1 },
    { src=love.audio.newSource("assets/music/1(BASS)F.wav", "static"), vol=1 },
    { src=love.audio.newSource("assets/music/1(BATERIA)F.wav", "static"), vol=1 },
    { src=love.audio.newSource("assets/music/1(TECLADO)F.wav", "static"), vol=1 },
    { src=love.audio.newSource("assets/music/1(STRINGS)F.wav", "static"), vol=1 },
}

MusicManager.loop_time = MusicManager.tracks[1].src:getDuration() / 16 -- 16 compassos no loop

for i, track in ipairs(MusicManager.tracks) do
    track.src:setLooping(true)
end

function MusicManager.new()
    local t = {}
    setmetatable(t, MusicManager.mt)

    t:stopAll()
    t:playAll()
    t:muteAll()

    t.timer = 0
    t.current_room = 1
    t.onLoopEnd = t.onLoopEndFunctions[1]

    t.tracks[1].src:setVolume(t.tracks[1].vol)

    return t
end

function MusicManager:muteAll()
    for i,track in ipairs(self.tracks) do
        track.src:setVolume(0)
    end
end

function MusicManager:playAll()
    for i,track in ipairs(self.tracks) do
        track.src:play()
    end
end

function MusicManager:stopAll()
    for i,track in ipairs(self.tracks) do
        track.src:stop()
        track.src:rewind()
    end
end

function MusicManager:nextRoom()
    self.requested_change = true;
    self.current_room = self.current_room + 1
    self.onLoopEnd = self.onLoopEndFunctions[self.current_room]
end

function MusicManager:update(dt)
    self:updateTimer(dt)
    if self.timer >= self.loop_time then
        self.timer = self.timer - self.loop_time
        self:muteAll()
        self:onLoopEnd()
        if self.requested_change then
            self.requested_change = false
        end
    end
end

function MusicManager:updateTimer(dt)
    -- Hacky way of synchronizing the timer with the actual music time
    if self.timer < 3 * self.loop_time / 4 then
        self.timer = self.tracks[1].src:tell()
    else
        self.timer = self.timer + dt
    end
end

function MusicManager:stage1Music()
    local tracks_to_play = { 1 }
    for i=1,#tracks_to_play do
        self.tracks[tracks_to_play[i]].src:setVolume(self.tracks[tracks_to_play[i]].vol)
    end
end

function MusicManager:stage2Music()
    local tracks_to_play = { 1, 2, 3 }
    for i=1,#tracks_to_play do
        self.tracks[tracks_to_play[i]].src:setVolume(self.tracks[tracks_to_play[i]].vol)
    end
end

function MusicManager:stage3Music()
    local tracks_to_play = { 1, 2, 3, 4 }
    for i=1,#tracks_to_play do
        self.tracks[tracks_to_play[i]].src:setVolume(self.tracks[tracks_to_play[i]].vol)
    end
end

function MusicManager:stage4Music()
    local tracks_to_play = { 1, 2, 3, 4, 5 }
    for i=1,#tracks_to_play do
        self.tracks[tracks_to_play[i]].src:setVolume(self.tracks[tracks_to_play[i]].vol)
    end
end

function MusicManager:stage5Music()
    local tracks_to_play = { 1, 2, 3, 4, 5 }
    for i=1,#tracks_to_play do
        self.tracks[tracks_to_play[i]].src:setVolume(self.tracks[tracks_to_play[i]].vol)
    end
end

MusicManager.onLoopEndFunctions = {
    MusicManager.stage1Music,
    MusicManager.stage2Music,
    MusicManager.stage3Music,
    MusicManager.stage4Music,
    MusicManager.stage5Music,
}
