extends Node

signal player_stamina_changed(player: Player)
signal player_health_changed(player: Player)
signal player_died
signal drink_acquired(drink: Drink)
# Player selects a boon from the boon dialog but may not 
# yet be in the collected boons list
signal boon_selected(boon: Boon)
# A boon was added to the collected boons list
signal boon_added(boon: Boon)

var level_index = 1
var last_exit_was_dark = false
var collected_boons = []

func _ready():
	boon_selected.connect(_on_boon_selected)
	player_died.connect(_on_player_died)


func _on_boon_selected(boon: Boon):
	print("Boon selected:", boon.title)
	collected_boons.append(boon)
	boon_added.emit(boon)


func _on_player_died():
	print("Player haas died. Game Over.")
	level_index = 1
	collected_boons = []


func check_for_boon_value(
		type: Boon.Type, 
		default_value: float
	) -> float:
	for boon in collected_boons:
		if boon.type == type:
			print("Found boon of type", type, "with value", boon.value)
			return boon.value
	return default_value


func go_next_level(used_dark_exist: bool):
	last_exit_was_dark = used_dark_exist
	level_index += 1
	get_tree().change_scene_to_file(
		"res://scenes/levels/level_" + str(level_index) + ".tscn")
