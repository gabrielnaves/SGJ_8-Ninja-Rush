MusicManager = {}
MusicManager.mt = { __index=MusicManager }

MusicManager.tracks = {
    { src=love.audio.newSource("assets/music/Drums 1.ogg", "static"), vol=1 },
    { src=love.audio.newSource("assets/music/Drums 2.ogg", "static"), vol=1 },
    { src=love.audio.newSource("assets/music/Drums 3.ogg", "static"), vol=1 },
    { src=love.audio.newSource("assets/music/Drums 4.ogg", "static"), vol=1 },
    { src=love.audio.newSource("assets/music/Bass 1.ogg", "static"), vol=1 },
    { src=love.audio.newSource("assets/music/Piano 1.ogg", "static"), vol=0.4 },
    { src=love.audio.newSource("assets/music/Flute 1.ogg", "static"), vol=1 },
    { src=love.audio.newSource("assets/music/Flute 2.ogg", "static"), vol=1 },
}

MusicManager.loop_time = MusicManager.tracks[1].src:getDuration()

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
    local tracks_to_play = { 1, 2, 5}
    for i=1,#tracks_to_play do
        self.tracks[tracks_to_play[i]].src:setVolume(self.tracks[tracks_to_play[i]].vol)
    end
end

function MusicManager:stage3Music()
    if self.requested_change then
        self.loop_count = 0
    end
    self.loop_count = self.loop_count + 1

    local tracks_to_play = { 1, 2, 5, 6 }

    if self.loop_count == 1 then table.insert(tracks_to_play, 7) end
    if self.loop_count == 2 then table.insert(tracks_to_play, 8) end
    if self.loop_count == 4 then self.loop_count = 0 end

    for i=1,#tracks_to_play do
        self.tracks[tracks_to_play[i]].src:setVolume(self.tracks[tracks_to_play[i]].vol)
    end
end

function MusicManager:stage4Music()
    if self.requested_change then
        self.loop_count = 0
    end
    self.loop_count = self.loop_count + 1

    local tracks_to_play = { 1, 2, 5, 6 }

    if self.loop_count == 1 then table.insert(tracks_to_play, 7) end
    if self.loop_count == 2 then table.insert(tracks_to_play, 8) end
    if self.loop_count == 4 then self.loop_count = 0 end

    for i=1,#tracks_to_play do
        self.tracks[tracks_to_play[i]].src:setVolume(self.tracks[tracks_to_play[i]].vol)
    end
end

function MusicManager:stage5Music()
    if self.requested_change then
        self.loop_count = 0
    end
    self.loop_count = self.loop_count + 1

    local tracks_to_play = { 1, 2, 5, 6 }

    if self.loop_count == 1 then table.insert(tracks_to_play, 7) end
    if self.loop_count == 2 then table.insert(tracks_to_play, 8) end
    if self.loop_count == 4 then self.loop_count = 0 end

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
