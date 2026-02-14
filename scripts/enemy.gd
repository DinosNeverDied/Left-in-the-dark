class_name Enemy
extends Creature

@onready var ray_cast_left: RayCast2D = $RayCast2D
@onready var ray_cast_right: RayCast2D = $RayCast2D2

func _physics_process(delta: float):
	#change direction according to which raycast is colliding
	if ray_cast_left.is_colliding():
		facing_right = true	
	if ray_cast_right.is_colliding():
		facing_right = false

	#handling movement 
	if is_on_floor():
		velocity.x = (-1 if facing_right else 1) * SPEED
		animated_sprite.play("run")

	super._physics_process(delta)
