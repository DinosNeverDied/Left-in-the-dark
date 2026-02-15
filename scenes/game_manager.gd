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

var collected_boons = []

func _ready():
	boon_selected.connect(_on_boon_selected)
	player_died.connect(_on_player_died)


func _on_boon_selected(boon: Boon):
	print("Boon selected:", boon.title)
	collected_boons.append(boon)
	boon_added.emit(boon)

func _on_player_died():
	print("Player has died. Game Over.")
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
