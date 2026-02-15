extends Node

signal player_health_changed(player: Player)
signal player_died
signal boon_acquired(boon: Boon)

var boons = []

func _ready():
	boon_acquired.connect(_on_boon_acquired)

func _on_boon_acquired(boon: Boon):
	boons.append(boon)
	print("Boon acquired:", boon.title)