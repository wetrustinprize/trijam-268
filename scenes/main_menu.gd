extends Control

@onready var credits_page: Sprite2D = get_node("CreditsPage")
@onready var context_page: Sprite2D = get_node("ContextPage")
@onready var controls_page: Sprite2D = get_node("ControlsPage")

func _ready():
	credits_page.visible = false
	context_page.visible = false
	controls_page.visible = false

func _on_quit_button_pressed():
	get_tree().quit()

func _on_play_button_pressed():
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_credits_button_pressed():
	credits_page.visible = true
	context_page.visible = false
	controls_page.visible = false

func _on_info_button_pressed():
	credits_page.visible = false
	context_page.visible = true
	controls_page.visible = false

func _on_controls_button_pressed():
	credits_page.visible = false
	context_page.visible = false
	controls_page.visible = true

func _on_return_button_pressed():
	credits_page.visible = false
	context_page.visible = false
	controls_page.visible = false
