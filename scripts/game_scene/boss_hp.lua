BossHp = {}

BossHp.image = StillImage.new("boss_heart.png", 0, 0, 0.5, 0.5)
BossHp.y = 20
BossHp.x = Screen.width - 20
BossHp.dist = 24

function BossHp.draw(entityTable)
    BossHp.calculateHpTotal(entityTable)
    if BossHp.hp_total > 0 then
        for i=1,BossHp.hp_total do
            local x = BossHp.x - (i-1)*BossHp.dist
            BossHp.image.x = x
            BossHp.image.y = BossHp.y
            BossHp.image:draw()
        end
    end
end

function BossHp.calculateHpTotal(entityTable)
    BossHp.hp_total = 0
    for i,entity in ipairs(entityTable) do
        if entity.name ~= "player" then
            BossHp.hp_total = BossHp.hp_total + entity.hp
        end
    end
end
