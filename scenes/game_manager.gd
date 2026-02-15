extends Node

signal player_health_changed(player: Player)
signal player_died
signal drink_acquired(drink: Drink)
signal boon_selected(boon: Boon)

var collected_boons = []

func _ready():
	boon_selected.connect(_on_boon_selected)
	player_died.connect(_on_player_died)
	

func _on_boon_selected(boon: Boon):
	print("Boon selected:", boon.title)
	collected_boons.append(boon)


func _on_player_died():
	print("Player has died. Game Over.")
	collected_boons = []


func check_for_drink_value(type: Boon.Type, default_value: float) -> float:
	for drink in collected_boons:
		if drink.data.type == type:
			print("Found drink of type", type, "with value", drink.data.value)
			return drink.data.value
	return default_value
