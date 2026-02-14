class_name Player
extends Creature

@export var SPEED_MULTIPLIER_WHILE_ATTACKING = 0.5
@export var SPEED_MULTIPLIER_WHILE_BLOCKING = 0.1
@export var JUMP_VELOCITY = -300.0
@export var INVULNERABILITY_DURATION = 1.0
@export var STRENGTH = 1

@onready var sword_collision_shape: CollisionShape2D = $Pivot/SwordArea2D/SwordCollisionShape
@onready var shield_collision_shape: CollisionShape2D = $Pivot/ShieldArea2D/ShieldCollisionShape
@onready var invulnerability_timer: Timer = $InvulnerabilityTimer
var is_invulnerable = false

var attacking = false

func _physics_process(delta: float):

	var player_wants_to_attack = Input.is_action_pressed("attack")
	var player_wants_to_block = Input.is_action_pressed("block")
	var player_wants_to_jump = Input.is_action_just_pressed("jump")
	var player_move_direction = Input.get_axis("move_left", "move_right")

	var on_floor = is_on_floor()
	var moving = player_move_direction != 0
	var blocking = player_wants_to_block and not attacking

	if moving:
		facing_right = player_move_direction > 0

	# check for attack stop
	if attacking and animated_sprite.frame >= animated_sprite.sprite_frames.get_frame_count("attack") - 1:
		attacking = false

	# handlig jump and gravity
	if on_floor and player_wants_to_jump:
		velocity.y = JUMP_VELOCITY

	if player_wants_to_attack and not attacking:
		attacking = true
		animated_sprite.play("attack")

	if blocking:
		animated_sprite.play("walk" if (moving and on_floor) else "block")
		if not moving and animated_sprite.frame >= animated_sprite.sprite_frames.get_frame_count("block") - 1:
			animated_sprite.pause()

	velocity.x = (direction 
		* SPEED 
		* (SPEED_MULTIPLIER_WHILE_ATTACKING if attacking else (SPEED_MULTIPLIER_WHILE_BLOCKING if blocking else 1.0))
		) if moving else 0.0
	
	if not (attacking or blocking):
		animated_sprite.play(("run" if moving else "idle") if on_floor else "jump")

	# sword is only active during certain frames
	sword_collision_shape.disabled = not (attacking and (animated_sprite.frame == 3 or animated_sprite.frame == 4))
	shield_collision_shape.disabled = not blocking
	
	if last_animation != animated_sprite.animation:
		last_animation = animated_sprite.animation
		print("Animation:", animated_sprite.animation)

	super._physics_process(delta)

# For debugging 
var last_animation = ""

func _on_sword_body_entered(enemy: CharacterBody2D):
	if enemy is not Enemy:
		return

	enemy.receive_damage(DAMAGE)


func _on_shield_body_entered(enemy: CharacterBody2D):
	if enemy is not Enemy:
		return

	print("Blocked by shield: ", enemy.name)
	receive_knockback(enemy.momentum / STRENGTH)
	enemy.receive_knockback(100)#momentum * STRENGTH)


func receive_damage(damage: int):
	if is_invulnerable:
		return

	super.receive_damage(damage)

	if HEALTH > 0:
		is_invulnerable = true
		invulnerability_timer.start(INVULNERABILITY_DURATION)

func _on_invulnerability_timer_timeout():
	is_invulnerable = false

func die():
	print("GAME OVER")
	get_tree().reload_current_scene()
