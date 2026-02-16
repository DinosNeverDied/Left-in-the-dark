class_name LevelExit extends Node2D

@export var drink_to_collect: Drink
@export var is_dark_exit: bool

var was_drink_acquired = false


func _ready():
	GameManager.drink_acquired.connect(_on_drink_acquired)


func _on_body_entered(player: Node2D):
	if player is not Player:
		return

	if not was_drink_acquired:
		print("Player tries exiting without having drink acquired.")
		return

	GameManager.go_next_level(is_dark_exit)
	# $AudioStreamPlayer2D.play()


func _on_drink_acquired(drink: Drink):
	if drink.is_dark == is_dark_exit:
		was_drink_acquired = true
		print("Drink was acquired and "
		+ ("dark" if is_dark_exit else "light") + " exit can now be used.")
