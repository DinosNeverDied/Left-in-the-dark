class_name Shields extends HBoxContainer

func _ready() -> void:
	GameManager.player_stamina_changed.connect(_on_stamina_changed)

func _on_stamina_changed(player: Player):
	$Stamina1.visible = player.STAMINA >= 1
	$Stamina2.visible = player.STAMINA >= 2
	$Stamina3.visible = player.STAMINA >= 3
	$Stamina4.visible = player.STAMINA >= 4
	$Stamina5.visible = player.STAMINA >= 5
	$Stamina6.visible = player.STAMINA >= 6
