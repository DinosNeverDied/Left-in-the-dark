class_name Player
extends Creature

@export var SPEED_MULTIPLIER_WHILE_ATTACKING = 0.5
@export var SPEED_MULTIPLIER_WHILE_BLOCKING = 0.1
@export var JUMP_VELOCITY = -300.0

@onready var sword_collision_shape: CollisionShape2D = $Pivot/SwordArea2D/SwordColissionShape

var attacking = false

func _physics_process(delta: float):

	# check for attack stop
	if attacking and animated_sprite.frame == animated_sprite.sprite_frames.get_frame_count("attack") - 1:
		attacking = false

	# handling movement
	var direction = Input.get_axis("move_left", "move_right")
	var moving = direction != 0
	if moving:
		facing_right = direction > 0

	# handlig jump and gravity
	var on_floor = is_on_floor()
	if on_floor:
		#adding jump through input key for jump
		if Input.is_action_just_pressed("jump"):
			velocity.y = JUMP_VELOCITY

	if Input.is_action_pressed("attack") and not attacking:
		attacking = true
		animated_sprite.play("attack")

	var blocking = not attacking and Input.is_action_pressed("block")

	sword_collision_shape.disabled = not (attacking and animated_sprite.frame == 3 or animated_sprite.frame == 4)

	if blocking:
		animated_sprite.play("walk_total" if (moving and on_floor) else "block")
		if not moving and animated_sprite.frame == animated_sprite.sprite_frames.get_frame_count("block") - 1:
			animated_sprite.pause()

	velocity.x = (
		(1.0 if facing_right else -1.0) 
		* SPEED 
		* (SPEED_MULTIPLIER_WHILE_ATTACKING if attacking else (SPEED_MULTIPLIER_WHILE_BLOCKING if blocking else 1.0))
		) if moving else 0.0
	
	if not (attacking or blocking):
		animated_sprite.play(("run" if moving else "idle") if on_floor else "jump")

	super._physics_process(delta)


func _on_sword_body_entered(body: CharacterBody2D):
	if body is Enemy:
		body.is_attacked(self)
