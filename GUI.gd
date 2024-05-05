extends CanvasLayer

@onready var timer_label: Label = get_node("Time")
@onready var points_label: Label = get_node("Points")

func _process(delta):
	var game_seconds = GameManager.Instance.time

	var minutes = int(game_seconds / 60.0)
	var seconds = int(max(0, game_seconds - (minutes * 60)))

	if seconds >= 10:
		timer_label.text = str(minutes) + ":" + str(seconds)
	else:
		timer_label.text = str(minutes) + ":0" + str(seconds)
	
	points_label.text = str(GameManager.Instance.score) + " points."
