extends Panel

func _ready():
	GameManager.player_died.connect(_on_player_died)


func _on_player_died():
	print("Player died, showing game over screen")
	visible = true


func _on_button_restart_pressed():
	get_tree().change_scene_to_file("res://scenes/levels/level_1.tscn")
	visible = false
