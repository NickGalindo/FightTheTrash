extends Node2D

#Variables go here
var enemySpawnTypes = [preload("res://CoalBat.tscn"), preload("res://TrashGolem.tscn"), preload("res://RadioactiveSkeleton.tscn")]
#var enemies = []
var space_state
var query = Physics2DShapeQueryParameters.new()
var shape = RectangleShape2D.new()
var spawnTime = 2
var spawnPosition = Vector2.ZERO
var try_spawn = false
var rand = RandomNumberGenerator.new()
var skeleton_spawned = 0
var golem_spawned = 0
var bat_spawned = 0


onready var scoreNode = $ScoreNode
onready var spw = $Area2D/CollisionShape2D
onready var timer = $Timer
onready var player = $Player
onready var health_bar = $CanvasLayer/HealthBar
onready var radioactive_bar = $CanvasLayer/RadioactiveBar
onready var trash_bar = $CanvasLayer/TrashBar
onready var coal_bar = $CanvasLayer/CoalBar

func _ready() -> void:
	health_bar.max_value = player.health
	health_bar.value = player.health
	radioactive_bar.max_value = 10
	radioactive_bar.value = 0
	coal_bar.max_value = 10
	coal_bar.value = 0
	trash_bar.max_value = 10
	trash_bar.value = 0
	timer.start(spawnTime)
	shape.extents = Vector2(20, 20)
	query.set_shape(shape)
	spw.shape = shape
	GlobalScoreNode.score = 0

func spawn():
	space_state = get_world_2d().direct_space_state
	rand.randomize()
	spawnPosition.x = rand.randi_range(48, 800)
	rand.randomize()
	spawnPosition.y = rand.randi_range(32, 272)
	spw.transform = Transform2D(Vector2(1, 0), Vector2(0, 1), spawnPosition)
	query.transform = Transform2D(Vector2(1, 0), Vector2(0, 1), spawnPosition)
	if len(space_state.intersect_shape(query)) > 0:
		return
	rand.randomize()
	var spawn_type = rand.randi_range(0, 2)
	var new_enemy = enemySpawnTypes[spawn_type].instance()
	if spawn_type == 0:
		bat_spawned += 1
		coal_bar.value = clamp(bat_spawned, 0, 10)
	elif spawn_type == 1:
		golem_spawned += 1
		trash_bar.value = clamp(golem_spawned, 0, 10)
	else:
		skeleton_spawned += 1
		radioactive_bar.value = clamp(skeleton_spawned, 0, 10)
	new_enemy.position = spawnPosition
	add_child(new_enemy)
	try_spawn = false
	timer.start(spawnTime)
	return

func _process(delta: float) -> void:

	health_bar.value = clamp(player.health, 0, 300)
	if player.health <= 0:
		get_tree().change_scene("res://HealthDeath.tscn")
		return
	if skeleton_spawned >= 10:
		get_tree().change_scene("res://RadioactiveDeath.tscn")
		return
	if golem_spawned >= 10:
		get_tree().change_scene("res://TrashDeath.tscn")
		return
	if bat_spawned >= 10:
		get_tree().change_scene("res://CoalDeath.tscn")
		return
	if try_spawn:
		spawn()
	return

func _on_Timer_timeout() -> void:
	try_spawn = true

func skeleton_death():
	skeleton_spawned -= 1
	radioactive_bar.value = clamp(skeleton_spawned, 0, 10)
	GlobalScoreNode.score += 1

func bat_death():
	bat_spawned -= 1
	coal_bar.value = clamp(bat_spawned, 0, 10)
	GlobalScoreNode.score += 1

func golem_death():
	golem_spawned -= 1
	trash_bar.value = clamp(golem_spawned, 0, 10)
	GlobalScoreNode.score += 1
