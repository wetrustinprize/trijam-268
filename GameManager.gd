class_name GameManager extends Node

static var Instance: GameManager

@onready var spawn_center: Node2D = get_node("Spawn Center")
@onready var humans_node: Node = get_node("Humans")

@onready var gui_canvas: CanvasLayer = get_node("GUI")
@onready var end_game_canvas: CanvasLayer = get_node("EndGameGUI")

@export var human_scene: PackedScene

var player_data: PlayerData

signal human_died
signal game_over

var score: int = 0;

var initial_spawn_min_radius: float = 300
var initial_spawn_max_radius: float = 800

var spawn_min_radius: float = 1920 * 2
var spawn_max_radius: float = 1920 * 2

var initial_humans: int = 35
var humans: Array = []
var is_game_over: bool = false

var time: float = 2 * 60

func _init():
	Instance = self

func _ready():
	human_died.connect(add_score)
	human_died.connect(create_new_humans)

	for i in range(initial_humans):
		var instance = human_scene.instantiate()
		instance.position = get_random_point_from_spawn(initial_spawn_min_radius, initial_spawn_max_radius)

		humans_node.add_child(instance)
		humans.append(instance)

	player_data = load("user://player_data.tres")

	if player_data == null:
		player_data = PlayerData.new()

func _process(delta):
	if is_game_over: return

	time = max(0, time - delta)

	if time <= 0:
		is_game_over = true
		game_over.emit()
		on_game_over()

func on_game_over():
	gui_canvas.hide()
	end_game_canvas.show()

	if score > player_data.best_score:
		player_data.best_score = score
		ResourceSaver.save(player_data, "user://player_data.tres")

func add_score():
	score += 5;

func create_new_humans():
	for i in range(5):
		var instance = human_scene.instantiate()
		instance.position = get_random_point_from_spawn(spawn_min_radius, spawn_max_radius)

		humans_node.add_child(instance)
		humans.append(instance)

func get_random_point_from_spawn(min_radius, max_radius) -> Vector2:
	var theta: float = randf() * 2 * PI
	var point: Vector2 = Vector2(cos(theta), sin(theta)) * sqrt(randf())

	var radius = randf_range(min_radius, max_radius)

	return spawn_center.position + point * radius
