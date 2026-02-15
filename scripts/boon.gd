class_name Boon extends Node2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _on_body_entered(player: Node2D):
	if player is not Player:
		return

	queue_free()


