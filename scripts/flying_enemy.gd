class_name FlyingEnemy
extends Creature

enum State {IDLE, WAKE, WALK, RUN, ATTACK, HIT, STUNNED}

@export var STUN_TIME = 0.5
@onready var raycast: RayCast2D = $Pivot/RayCast
@onready var killzone: Area2D = $KillArea2D
@onready var blood_parent: Node2D = $BloodParent2D
@onready var blood_sprite: AnimatedSprite2D = $BloodParent2D/BloodSprite2D

var state: State = State.IDLE
var stun_timer = STUN_TIME
var player: Node2D = null
var direction_2d = Vector2(0,0)
var dead = false

func _physics_process(delta: float) -> void:
	
	if dead:
		velocity.x = 0
		killzone.monitorable = false
		killzone.monitoring = false
		return
	
	match state:
		State.IDLE:
			handle_idle()
		State.WAKE:
			handle_wake()
		State.WALK:
			handle_walk()
		State.RUN:
			handle_run()
		State.ATTACK:
			handle_attack()
		State.HIT:
			handle_hit()
		State.STUNNED:
			handle_stun(delta)
				
	super._physics_process(delta)
	
func _ready() -> void:
	print("facing_right: ", facing_right)
	
func get_dist_to_player():
	return global_position.distance_to(%Knight.global_position)
	
func face_player() -> void:
	if not player:
		return
		
	facing_right = %Knight.global_position.x > global_position.x
	pivot.scale.x = abs(pivot.scale.x) * direction

func handle_idle() -> void:
	
	animated_sprite.play("idle")
	if get_dist_to_player() < 160:
		state = State.WAKE
		
func handle_wake() -> void:
	
	animated_sprite.play("wake")
	await animated_sprite.animation_finished
	state = State.WALK
	
func handle_walk() -> void:
	
	animated_sprite.play("walk")
	velocity.x = 0
	velocity.y = 0
	
func handle_run() -> void:
	
	face_player()	
	direction_2d = (%Knight.global_position - global_position)
	velocity = direction_2d * WALK_SPEED * 0.025

	animated_sprite.play("run")
	
func handle_attack() -> void:
	return
	
func handle_hit() -> void:
	
	var hit_direction = get_hit_dir()
	blood_parent.scale.x = abs(blood_sprite.scale.x) * hit_direction

	blood_sprite.play("blood")
	animated_sprite.play("hit")
	await animated_sprite.animation_finished
	state = State.RUN
	
func handle_stun(delta: float) -> void: 
	
	velocity.x = 0
	stun_timer -= delta
	animated_sprite.play("knockback")
	
	if stun_timer <= 0:
		stun_timer = STUN_TIME
		state = State.RUN

func take_sword_hit(attacker: Creature) -> void:
	super.take_sword_hit(attacker)
	state = State.HIT

func take_shield_block(attacker: Creature) -> void:
	super.take_shield_block(attacker)
	state = State.STUNNED

func _on_aggro_body_entered(player: Node2D):

	if self.player == null:
		self.player = player
		state = State.RUN

func _on_aggro_body_exited(player: Node2D):

	if self.player == player:
		self.player = null
		state = State.WALK

func _on_killzone_body_entered(player: Node2D):
	if player is not Player:
		return

	player.receive_damage(DAMAGE)

func die():
	
	dead = true
	
	var hit_direction = get_hit_dir()
	blood_parent.scale.x = abs(blood_sprite.scale.x) * hit_direction
	
	blood_sprite.play("blood")
	animated_sprite.play("death")
	await animated_sprite.animation_finished
	
	print(name, " died")
	queue_free()
