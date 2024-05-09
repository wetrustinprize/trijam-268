class_name Cloud extends Node2D

static var Instance: Cloud

enum CLOUD_STATE {MOVING, CLOSING, RAINING}

@export var moving_texture: Texture2D
@export var closing_texture: Texture2D
@export var raining_texture: Texture2D

@onready var cloud_sprite: AnimatedSprite2D = get_node("Cloud")
@onready var raining_particles: GPUParticles2D = get_node("RainParticles")
@onready var rain_area: Area2D = get_node("RainArea")

@onready var thunder_sfx: AudioStreamPlayer2D = get_node("Thunder")
@onready var rain_sfx: AudioStreamPlayer2D = get_node("Rain")

signal state_change(new_state)

var state = CLOUD_STATE.MOVING;

func _init():
	Instance = self

func _ready():
	GameManager.Instance.game_over.connect(on_game_over)

func _process(delta):
	position = position.lerp(get_global_mouse_position(), 10 * delta)

func _input(event):
	if event is InputEventMouseButton:
		if !event.pressed:
			return

		print(event.button_index)

		if event.button_index == 5||event.button_index == 4:
			change_state(CLOUD_STATE.MOVING if state == CLOUD_STATE.CLOSING else CLOUD_STATE.CLOSING)
		if event.button_index == 1&&state == CLOUD_STATE.CLOSING:
			change_state(CLOUD_STATE.RAINING)

func on_game_over():
	queue_free()

func change_state(new_state):
	match new_state:
		CLOUD_STATE.CLOSING:
			cloud_sprite.play("closing")
			raining_particles.emitting = false
			thunder_sfx.play()
			rain_sfx.stop()
		CLOUD_STATE.MOVING:
			cloud_sprite.play("moving")
			raining_particles.emitting = false
			rain_sfx.stop()
		CLOUD_STATE.RAINING:
			cloud_sprite.play("raining")
			raining_particles.emitting = true
			rain_sfx.play()

			for body in rain_area.get_overlapping_bodies():
				check_human(body)
		_:
			push_error("Invalid state");
	
	state = new_state
	state_change.emit(new_state)

func check_human(node: Node2D):
	if not (node is Human): return

	if state != CLOUD_STATE.RAINING: return ;
	node.on_rain = true;

func _on_rain_area_body_entered(body: Node2D):
	check_human(body)

func _on_rain_area_body_exited(body: Node2D):
	if not (body is Human): return
	body.on_rain = false;
