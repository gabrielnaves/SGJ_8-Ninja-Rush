Text = {}

Text.font = love.graphics.newImageFont("assets/font.png",
    " abcdefghijklmnopqrstuvwxyz" .. "ABCDEFGHIJKLMNOPQRSTUVWXYZ" ..
    "0123456789" .. ":.,!")
Text.font:setFilter('linear', 'nearest')
love.graphics.setFont(Text.font)

function Text.printCentered(text, color, x, y, scale)
    local draw_x = math.floor(x-Text.font:getWidth(text)/2 * scale)
    local draw_y = math.floor(y-Text.font:getHeight(text)/2 * scale)
    love.graphics.print({color, text}, draw_x, draw_y, 0, scale, scale)
end
