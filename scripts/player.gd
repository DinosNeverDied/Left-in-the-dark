class_name Player
extends Creature

@export var STAMINA = 3
@export var DEFAULT_MAX_HEALTH = 3
@export var DEFAULT_MAX_SHIELD_STAMINA = 3
# @export var DEFAULT_DAMAGE = 1
@export var DEFAULT_ATTACKING_SPEED = 2
# @export var DEFAULT_RUN_SPEED = 120
@export var DEFAULT_SPEED_MULTIPLIER_WHILE_ATTACKING = 0.5
@export var DEFAULT_SPEED_MULTIPLIER_WHILE_BLOCKING = 0.3

@export var JUMP_VELOCITY = -350.0
@export var INVULNERABILITY_DURATION = 1.0
@export var RECHARGE_TIME_PER_STAMINA = 2.0

@onready var dead_audioplayer: AudioStreamPlayer = $AudioStreamPlayer
@onready var knight_collision_shape: CollisionShape2D = $CollisionShape2D
@onready var sword_collision_shape: CollisionShape2D = $Pivot/SwordArea2D/SwordCollisionShape
@onready var shield_collision_shape: CollisionShape2D = $Pivot/ShieldArea2D/ShieldCollisionShape
@onready var invulnerability_timer: Timer = $InvulnerabilityTimer
@onready var stamina_recharge_timer: Timer = $StaminaRechargeTimer

var MAX_HEALTH:
	get:
		return DEFAULT_MAX_HEALTH + GameManager.check_for_boon_value(
			Boon.Type.HEALTH_PLUS, 0)

var MAX_SHIELD_STAMINA:
	get:
		return DEFAULT_MAX_SHIELD_STAMINA + GameManager.check_for_boon_value(
			Boon.Type.SHIELD_STAMINA_PLUS, 0)

var SPEED_MULTIPLIER_WHILE_ATTACKING:
	get:
		return DEFAULT_SPEED_MULTIPLIER_WHILE_ATTACKING * GameManager.check_for_boon_value(
			Boon.Type.ATTACK_MOVEMENT_SPEED_MULTIPLIER, 1)

var SPEED_MULTIPLIER_WHILE_BLOCKING:
	get:
		return DEFAULT_SPEED_MULTIPLIER_WHILE_BLOCKING * GameManager.check_for_boon_value(
			Boon.Type.BLOCK_MOVEMENT_SPEED_MULTIPLIER, 1)


var attacking = false
var is_flickering = false
var dead = false


func _ready():
	GameManager.player_health_changed.emit(self)
	GameManager.player_stamina_changed.emit(self)
	GameManager.boon_added.connect(_on_boon_added)
	stamina_recharge_timer.timeout.connect(_on_statmina_stamina_recharge_timer_timeout)
	

func _physics_process(delta: float):

	if dead:
		velocity.x = 0
		#knight_collision_shape.disabled
		super._physics_process(delta)
		return

	var player_wants_to_attack = Input.is_action_pressed("attack")
	var player_wants_to_block = Input.is_action_pressed("block")
	var player_wants_to_jump = Input.is_action_just_pressed("jump")
	var player_move_direction = Input.get_axis("move_left", "move_right")

	var on_floor = is_on_floor()
	var moving = player_move_direction != 0
	var blocking = player_wants_to_block and not attacking

	if attacking or blocking:
		stamina_recharge_timer.start(RECHARGE_TIME_PER_STAMINA)

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
		* RUN_SPEED 
		* (SPEED_MULTIPLIER_WHILE_ATTACKING if attacking else (SPEED_MULTIPLIER_WHILE_BLOCKING if blocking else 1.0))
		) if moving else 0.0
	
	if not (attacking or blocking):
		animated_sprite.play(("run" if moving else "idle") if on_floor else "jump")

	# sword is only active during certain frames
	sword_collision_shape.disabled = not (attacking and (animated_sprite.frame == 3 or animated_sprite.frame == 4))
	shield_collision_shape.disabled = not blocking
	
	super._physics_process(delta)


func _on_sword_body_entered(enemy: CharacterBody2D):
	if dead or enemy is not Creature:
		return

	enemy.take_sword_hit(self)

	var lifesteal_chance = GameManager.check_for_boon_value(Boon.Type.LIFESTEAL_CHANCE, 0)

	if randf() <= lifesteal_chance:
		HEALTH += 1


func _on_shield_body_entered(enemy: CharacterBody2D):
	if dead or enemy is not Creature or STAMINA <= 0:
		return

	STAMINA -= 1
	GameManager.player_stamina_changed.emit(self)

	print("Blocked by shield: ", enemy.name)
	var counter_damage = GameManager.check_for_boon_value(Boon.Type.BLOCK_DAMAGE, 0)
	if counter_damage > 0:
		enemy.receive_damage(counter_damage)
		
	enemy.take_shield_block(self)


func receive_damage(damage: int):
	if dead or is_flickering:
		return

	super.receive_damage(damage)

	GameManager.player_health_changed.emit(self)

	if not dead:
		start_flickering(1.3, 3)


func die():
	dead = true

	dead_audioplayer.play()
	animated_sprite.play("die")
	await animated_sprite.animation_finished

	GameManager.player_died.emit()


func start_flickering(time: float, flicker_count: int):
	is_flickering = true
	var total_intervals = 2 * flicker_count - 1
	var flicker_time = time / total_intervals

	for index in flicker_count:
		animated_sprite.modulate.a = 0.5
		invulnerability_timer.start(flicker_time)
		await invulnerability_timer.timeout
		
		animated_sprite.modulate.a = 1.0
		if index < flicker_count - 1:
			invulnerability_timer.start(flicker_time)
			await invulnerability_timer.timeout

	is_flickering = false


func _on_boon_added(boon: Boon):
	if boon.type == Boon.Type.ATTACK_DAMAGE_MULTIPLIER:
		DAMAGE *= GameManager.check_for_boon_value(
			Boon.Type.ATTACK_DAMAGE_MULTIPLIER, 1)

	elif boon.type == Boon.Type.SPEED_MULTIPLIER:
		RUN_SPEED *= GameManager.check_for_boon_value(
			Boon.Type.SPEED_MULTIPLIER, 1)

	elif boon.type == Boon.Type.BLOCK_KNOCKBACK_MULTIPLIER:
		KNOCKBACK_FORCE *= GameManager.check_for_boon_value(
			Boon.Type.BLOCK_KNOCKBACK_MULTIPLIER, 1)

	elif boon.type == Boon.Type.HEALTH_PLUS:
		increase_health(MAX_HEALTH) # Heal full

	elif boon.type == Boon.Type.ATTACK_SPEED_MULTIPLIER:
		# fps = animationFramesCount * attacking speed (latter is in 1/s)
		# e.g.  6 frames * 2/s = 12 fps
		animated_sprite.sprite_frames.set_animation_speed(
			"attack", 
			(animated_sprite.sprite_frames.get_frame_count("attack") 
				* DEFAULT_ATTACKING_SPEED 
				* GameManager.check_for_boon_value(Boon.Type.ATTACK_SPEED_MULTIPLIER, 1))) 


func increase_health(amount: int):
	HEALTH = min(HEALTH + amount, MAX_HEALTH)
	GameManager.player_health_changed.emit(self)
	

func take_sword_hit(attacker: Creature) -> void:
	if dead or is_flickering:
		return
	super.take_sword_hit(attacker)
	start_flickering(1.0, 3)


func _on_statmina_stamina_recharge_timer_timeout():
	if STAMINA < MAX_SHIELD_STAMINA:
		STAMINA += 1
		GameManager.player_stamina_changed.emit(self)
		stamina_recharge_timer.start(RECHARGE_TIME_PER_STAMINA)