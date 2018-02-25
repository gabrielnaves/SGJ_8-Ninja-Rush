MapGenerator = {}
MapGenerator.mt = { __index=MapGenerator }

MapGenerator.room_amount = 3

function MapGenerator.new()
    local map = {}
    map.rooms = {}

    -- Generate rooms
    for i=1,MapGenerator.room_amount do
        table.insert(map.rooms, Room.new(i, map.rooms))
    end

    map.transitioning = false
    map.transition_time = 2
    map.transition_timer = 0
    map.room_distance = Screen.height+150
    map.current_height = 0
    map.start_height = 0
    map.end_height = 0
    map.current_room = 1

    return setmetatable(map, MapGenerator.mt)
end

function MapGenerator:canTransition()
    return not self.transitioning and self.current_room < MapGenerator.room_amount
end

function MapGenerator:startTransition(music_manager)
    self.start_height = self.current_height
    self.end_height = self.start_height + self.room_distance
    self.transitioning = true
    self.transition_timer = 0
    self.transition_time = music_manager.loop_time - music_manager.timer
    self.current_room = self.current_room + 1
end

function MapGenerator:update(dt)
    if self.transitioning then
        self.transition_timer = self.transition_timer + dt
        self.current_height = Mathf.lerp(self.start_height, self.end_height,
                                         self.transition_timer / self.transition_time)

        if self.transition_timer > self.transition_time then
            self.transitioning = false
            self.current_height = self.end_height
        end
    end
end

function MapGenerator:draw()
    for i, room in ipairs(self.rooms) do
        room.image.y = self.current_height-(i-1)*(self.room_distance)
        room:draw()
    end
end


Room = {}
Room.mt = { __index=Room }

function Room.new(i, rooms)
    local room = {}

    room.count = i
    room.boss = i == MapGenerator.room_amount
    room.image = StillImage.new("room.png", 0, -(i-1)*(Screen.height+150), 0, 0)

    -- Door generation
    room.doors = {}
    if i > 1 then
        room.doors.down = StillImage.new("doors/door_up.png", Screen.width/2, Screen.height, 0.5, 1)
    end
    if i < MapGenerator.room_amount then
        room.doors.up = StillAnimation.new("doors/boss_door_down.png", 20, 0.02, Screen.width/2, 0, 0.5, 0, false)
    end

    return setmetatable(room, Room.mt)
end

function Room:update(dt)
    if self.doors.up ~= nil then
        self.doors.up:update(dt)
    end
end

function Room:draw()
    self.image:draw()
    if self.doors.down ~= nil then
        self.doors.down.y = self.image.y + Screen.height
        self.doors.down:draw()
    end
    if self.doors.up ~= nil then
        self.doors.up.y = self.image.y
        self.doors.up:draw()
    end
end
