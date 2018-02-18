require("scripts.game_scene.kamaitachi")

EnemySpawner = {}

function EnemySpawner.spawnEnemies(entityTable, room)
    if not room.boss then
        for i=1,room.count do
            local new_enemy = Kamaitachi.new()
            new_enemy.rect.x, new_enemy.rect.y = EnemySpawner.randomPosition()
            table.insert(entityTable, new_enemy)
        end
    end
end

function EnemySpawner.randomPosition()
    return Mathf.randomFloat(Screen.left_bound, Screen.right_bound),
           Mathf.randomFloat(Screen.upper_bound, Screen.lower_bound)
end
