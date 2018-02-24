require("scripts.game_scene.dark_kamaitachi")
require("scripts.game_scene.gashadokuro")

EnemySpawner = {}

function EnemySpawner.spawnEnemies(entityTable, room)
    if not room.boss then
        for i=1,room.count do
            local new_enemy = DarkKamaitachi.new()
            new_enemy.rect.x, new_enemy.rect.y = EnemySpawner.randomPosition()
            table.insert(entityTable, new_enemy)
        end
    else
        EnemySpawner.spawnBoss(entityTable)
        if love.math.random() > 0.5 then EnemySpawner.spawnBoss(entityTable) end
    end
end

function EnemySpawner.randomPosition()
    return Mathf.randomFloat(Screen.left_bound, Screen.right_bound),
           Mathf.randomFloat(Screen.upper_bound, Screen.lower_bound-40)
end

function EnemySpawner.spawnBoss(entityTable)
    local boss = Gashadokuro.new("big")
    boss.rect.x, boss.rect.y = EnemySpawner.randomPosition()
    table.insert(entityTable, boss)
end
