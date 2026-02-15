extends Panel


func _on_knight_player_died() -> void:
	visible = true


func _on_button_restart_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/level_1.tscn")
