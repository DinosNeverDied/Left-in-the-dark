extends CharacterBody2D


@export var SPEED = 120.0
@export var ATTACK_SPEED_MULTIPLIER = 0.5
@export var BLOCK_SPEED_MULTIPLIER = 0.1
@export var JUMP_VELOCITY = -300.0

@onready var animated_sprite: AnimatedSprite2D = $Sprite

var facing_right = true
var attacking = false
var blocking = false

func _physics_process(delta: float) -> void:
	#adding movement through input keys for left and right

	var moving = false
	var jumping = false;

	if attacking and animated_sprite.frame == animated_sprite.sprite_frames.get_frame_count("attack") - 1:
		attacking = false

	#handlig jump and gravity
	if is_on_floor() :
		#adding jump through input key for jump
		if Input.is_action_just_pressed("jump"):
			velocity.y = JUMP_VELOCITY
	else:
		#applying gravity 
		velocity += get_gravity() * delta
		jumping = true

	if Input.is_action_pressed("move_left"):
		moving = true
		facing_right = false
	elif Input.is_action_pressed("move_right"):
		moving = true	
		facing_right = true

	if Input.is_action_pressed("attack") and not attacking:
		attacking = true
		animated_sprite.play("attack")

	blocking = Input.is_action_pressed("block") and not attacking 

	if blocking:
		animated_sprite.play("walk_total" if (moving and not jumping) else "block")
		if not moving and animated_sprite.frame == animated_sprite.sprite_frames.get_frame_count("block") - 1:
			animated_sprite.pause()

	velocity.x = (
		(1.0 if facing_right else -1.0) 
		* SPEED 
		* (ATTACK_SPEED_MULTIPLIER if attacking else (BLOCK_SPEED_MULTIPLIER if blocking else 1.0))
		) if moving else 0.0
	animated_sprite.flip_h = not facing_right

		
	if not (attacking or blocking):
		animated_sprite.play("jump" if jumping else ("run" if moving else "idle"))

	move_and_slide()
