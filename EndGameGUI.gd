extends CanvasLayer

@onready var score_label = get_node("Panel/Score")
@onready var best_score_label = get_node("Panel/BestScore")

func _ready():
	GameManager.Instance.game_over.connect(on_game_over)

func on_game_over():
	score_label.text = str(GameManager.Instance.score) + " points"
	best_score_label.text = str(GameManager.Instance.player_data.best_score) + " points"

func _on_try_again_button_pressed():
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_quit_button_pressed():
	get_tree().quit()
