extends Area2D

@onready var timer: Timer = $Timer
@onready var audio: AudioStreamPlayer = $AudioStreamPlayer

@onready var player_start_position: Vector2 = %Knight.global_position

func _on_body_entered(body: Node2D) -> void:
	audio.play()
	#reducing the engine time by half on player end wtered
	%Knight.receive_damage(1)
	Engine.time_scale = 0.5
	timer.start()

func _on_timer_timeout() -> void:
	#engine time back to normal
	Engine.time_scale = 1.0
	%Knight.global_position = player_start_position
	# get_tree().reload_current_scene()
