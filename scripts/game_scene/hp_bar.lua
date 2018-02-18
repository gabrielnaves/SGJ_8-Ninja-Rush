HpBar = {}

HpBar.image = StillImage.new("heart.png", 0, 0, 0.5, 0.5)
HpBar.y = 20
HpBar.x = 20
HpBar.dist = 25

function HpBar.draw(player_hp)
    if player_hp > 0 then
        for i=1,player_hp do
            local x = HpBar.x + (i-1)*HpBar.dist
            HpBar.image.x = x
            HpBar.image.y = HpBar.y
            HpBar.image:draw()
        end
    end
end
