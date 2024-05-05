class_name Human extends CharacterBody2D

@export var animated_sprites: Array[SpriteFrames]
@export var modulate_in_life: GradientTexture1D

@onready var animated_sprite: AnimatedSprite2D = get_node("AnimatedSprite2D")
@onready var flee_timer: Timer = get_node("FleeTimer")

@onready var acid_sfx: AudioStreamPlayer2D = get_node("Burn")

var min_radius: float = 100
var max_radius: float = 300

var go_to: Vector2 = Vector2.ZERO

var speed: float = 25
var flee_speed: float = 60
var distance_threshold: float = 10
var health: float = 3

var on_rain: bool = false;
var dead: bool = false;

var fleeing: bool = false;
var currentHealth: float;

func _ready():
	animated_sprite.sprite_frames = animated_sprites[randi() % animated_sprites.size()]
	animated_sprite.play("forward")

	currentHealth = health;

	go_to = GameManager.Instance.get_random_point_from_spawn()

	Cloud.Instance.state_change.connect(cloud_change_state)
	flee_timer.timeout.connect(enable_flee)

func cloud_change_state(new_state):
	match new_state:
		Cloud.CLOUD_STATE.CLOSING:
			flee_timer.start()
		Cloud.CLOUD_STATE.RAINING:
			flee_timer.stop()
			fleeing = true;
		_:
			flee_timer.stop()
			fleeing = false;
	pass

func _process(delta):
	if dead: return

	if not on_rain:
		currentHealth = min(health, currentHealth + delta)
	else:
		currentHealth = currentHealth - delta

	animated_sprite.modulate = modulate_in_life.gradient.sample(currentHealth / health)

	if currentHealth <= 0:
		GameManager.Instance.human_died.emit()
		dead = true
		animated_sprite.modulate = Color.WHITE
		animated_sprite.play("dead")
		acid_sfx.play()

func enable_flee():
	fleeing = true

func _physics_process(delta):
	if dead: return

	if not fleeing:
		var dist = position.distance_to(go_to)
		if dist <= distance_threshold:
			go_to = GameManager.Instance.get_random_point_from_spawn()

	var dir = position.direction_to(go_to if not fleeing else get_flee_position())

	animated_sprite.flip_h = dir.x > 0

	if abs(dir.x) > abs(dir.y):
		animated_sprite.play("side")
	else:
		animated_sprite.play("forward" if dir.y > 0 else "back")

	velocity = dir * (flee_speed if fleeing else speed)
	move_and_slide()

func get_flee_position() -> Vector2:
	var screensize: Vector2 = get_viewport().get_visible_rect().size
	var flee_position: Vector2 = Vector2.ZERO;

	if position.x > (screensize.x / 2):
		flee_position.x = screensize.x + 100
	else:
		flee_position.x = -100

	if position.y > (screensize.y / 2):
		flee_position.y = screensize.y + 100
	else:
		flee_position.y = -100

	return flee_position

func _on_burn_finished():
	queue_free()
