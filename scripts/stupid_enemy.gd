class_name StupidEnemy
extends Creature

@onready var ray_cast_right: RayCast2D = $RayCast2D
@onready var ray_cast_left: RayCast2D = $RayCast2D2


func _physics_process(delta: float):
	# change direction according to which raycast is colliding
	if ray_cast_right.is_colliding():
		facing_right = false
	if ray_cast_left.is_colliding():
		facing_right = true	

	# handling movement 
	if is_on_floor():
		velocity.x = direction * RUN_SPEED
		animated_sprite.play("run")

	super._physics_process(delta)


# Todo: Fix and put take_shield_block into Creature
func take_shield_block(player: Creature):
	receive_knockback(player.KNOCKBACK_FORCE * 3)


func _on_killzone_body_entered(player: CharacterBody2D):
	if player is not Player:
		return

	player.receive_damage(DAMAGE)

