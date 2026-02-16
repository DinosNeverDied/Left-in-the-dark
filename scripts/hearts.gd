class_name Hearts extends HBoxContainer

func _ready() -> void:
	GameManager.player_health_changed.connect(_on_health_changed)

func _on_health_changed(player: Player):
	print("_on_health_changed: player = ", player.name)
	$Heart1.visible = player.HEALTH >= 1
	$Heart2.visible = player.HEALTH >= 2
	$Heart3.visible = player.HEALTH >= 3
	$Heart4.visible = player.HEALTH >= 4
	$Heart5.visible = player.HEALTH >= 5
	$Heart6.visible = player.HEALTH >= 6
