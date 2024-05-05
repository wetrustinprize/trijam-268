class_name Cloud extends Node2D

static var Instance: Cloud

enum CLOUD_STATE {MOVING, CLOSING, RAINING}

@export var moving_texture: Texture2D
@export var closing_texture: Texture2D
@export var raining_texture: Texture2D

@onready var animated_sprite: AnimatedSprite2D = get_node("AnimatedSprite2D")
@onready var raining_particles: GPUParticles2D = get_node("RainParticles")
@onready var rain_area: Area2D = get_node("RainArea")

signal state_change(new_state)

var state = CLOUD_STATE.MOVING;

func _ready():
	Instance = self

func _input(event):
	if event is InputEventMouseButton:
		if !event.pressed:
			return

		if event.button_index == 1:
			change_state(CLOUD_STATE.MOVING if state == CLOUD_STATE.CLOSING else CLOUD_STATE.CLOSING)
		if event.button_index == 2:
			change_state(CLOUD_STATE.CLOSING if state == CLOUD_STATE.MOVING or state == CLOUD_STATE.RAINING else CLOUD_STATE.RAINING)

	if event is InputEventMouseMotion:
		position = event.position

func change_state(new_state):
	match new_state:
		CLOUD_STATE.CLOSING:
			animated_sprite.play("closing")
			raining_particles.emitting = false;
		CLOUD_STATE.MOVING:
			animated_sprite.play("moving")
			raining_particles.emitting = false;
		CLOUD_STATE.RAINING:
			animated_sprite.play("raining")
			raining_particles.emitting = true;

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
