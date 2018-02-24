require("scripts.game_scene.dark_kamaitachi")
require("scripts.game_scene.light_kamaitachi")
require("scripts.game_scene.gashadokuro")

EnemySpawner = {}

function EnemySpawner.spawnEnemies(entityTable, room)
    EnemySpawner.bossSpawnFunctions[room.count](entityTable)
end

function EnemySpawner.randomPosition()
    return Mathf.randomFloat(Screen.left_bound, Screen.right_bound),
           Mathf.randomFloat(Screen.upper_bound, Screen.lower_bound-40)
end

function EnemySpawner.spawnKamaitachiBoss(entityTable)
    local dark_kamaitachi = DarkKamaitachi.new()
    dark_kamaitachi.rect.x, dark_kamaitachi.rect.y = 2*Screen.width/6, Screen.height/4
    table.insert(entityTable, dark_kamaitachi)

    local light_kamaitachi = LightKamaitachi.new()
    light_kamaitachi.rect.x, light_kamaitachi.rect.y = 4*Screen.width/6, Screen.height/4
    table.insert(entityTable, light_kamaitachi)
end

function EnemySpawner.spawnGashadokuroBoss(entityTable)
    local boss = Gashadokuro.new("big")
    boss.rect.x, boss.rect.y = EnemySpawner.randomPosition()
    table.insert(entityTable, boss)
end

EnemySpawner.bossSpawnFunctions = {
    nil,
    EnemySpawner.spawnKamaitachiBoss,
    EnemySpawner.spawnGashadokuroBoss,
}
