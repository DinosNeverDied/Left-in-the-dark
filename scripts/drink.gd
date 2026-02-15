class_name Drink extends Node2D

@export var is_dark: bool

func _on_body_entered(player: Node2D):
	if player is not Player:
		return

	print("Calling _on_body_entered for drink:", self.name, "is_dark:", is_dark, " => drink_acquired")
	GameManager.drink_acquired.emit(self)
	queue_free()
