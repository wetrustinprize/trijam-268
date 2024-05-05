class_name GameManager extends Node

static var Instance: GameManager

@onready var spawn_center: Node2D = get_node("Spawn Center")
@onready var humans_node: Node = get_node("Humans")

@export var human_scene: PackedScene

signal human_died
signal game_over

var points: int = 0;

var min_radius: float = 300
var max_radius: float = 800

var initial_humans: int = 35
var humans: Array = []
var is_game_over: bool = false

var time: float = 2 * 60
# var time: float = 5

func _ready():
	Instance = self

	human_died.connect(add_score)
	human_died.connect(create_new_humans)

	for i in range(initial_humans):
		var instance = human_scene.instantiate()
		instance.position = get_random_point_from_spawn()

		humans_node.add_child(instance)
		humans.append(instance)

func _process(delta):
	if is_game_over: return

	time = max(0, time - delta)

	if time <= 0:
		is_game_over = true
		game_over.emit()

		Cloud.Instance.queue_free()

		for human in humans:
			human.queue_free()

func add_score():
	points += 5;

func create_new_humans():
	pass

func get_random_point_from_spawn() -> Vector2:
	var theta: float = randf() * 2 * PI
	var point: Vector2 = Vector2(cos(theta), sin(theta)) * sqrt(randf())

	var radius = randf_range(min_radius, max_radius)

	return spawn_center.position + point * radius
