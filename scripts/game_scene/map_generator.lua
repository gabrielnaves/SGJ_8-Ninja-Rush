MapGenerator = {}
MapGenerator.mt = { __index=MapGenerator }

MapGenerator.room_amount = 4

function MapGenerator.new()
    local map = {}
    map.rooms = {}

    -- Generate rooms
    for i=1,MapGenerator.room_amount do
        table.insert(map.rooms, Room.new(i, map.rooms))
    end

    return setmetatable(map, MapGenerator.mt)
end

function MapGenerator:update(dt)
    for i, room in ipairs(self.rooms) do
        room.image.y = room.image.y + dt * 200
    end
end

function MapGenerator:draw()
    for i, room in ipairs(self.rooms) do
        room:draw()
    end
end


Room = {}
Room.mt = { __index=Room }

function Room.new(i, rooms)
    local room = {}

    room.previous = previous
    room.visited = false
    room.image = StillImage.new("room.png", 0, -(i-1)*(Screen.height+150), 0, 0)
    room.doors = {}
    if i > 1 then
        room.doors.down = StillImage.new("doors/door_up.png", Screen.width/2, Screen.height, 0.5, 1)
    end
    if i == MapGenerator.room_amount-1 then
        room.doors.up = StillImage.new("doors/boss_door.png", Screen.width/2, 0, 0.5, 0)
    elseif i < MapGenerator.room_amount-1 then
        room.doors.up = StillImage.new("doors/door_down.png", Screen.width/2, 0, 0.5, 0)
    end

    return setmetatable(room, Room.mt)
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
