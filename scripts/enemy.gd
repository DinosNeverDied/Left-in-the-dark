class_name Enemy
extends Creature

enum State {IDLE, WALK, RUN, HIT, STUNNED, DEAD}

@export var STUN_TIME = 0.4

@onready var raycast: RayCast2D = $Pivot/RayCast
@onready var aggro: Area2D = $Aggro
@onready var hitbox: Area2D = $Hitbox

var state: State = State.WALK
var idle_timer = 0.0
var stun_timer = STUN_TIME
var knockback_velocity = Vector2.ZERO
var player: Node2D = null

func _physics_process(delta: float) -> void:
	
	match state:
		State.IDLE:
			handle_idle(delta)
		State.WALK:
			handle_walk(delta)
		State.RUN:
			handle_run()
		State.STUNNED:
			handle_stunned(delta)
		State.HIT:
			pass
		State.DEAD:
			return
				
	super._physics_process(delta)
	
func _ready() -> void:
	print("facing_right: ", facing_right)
	
func handle_walk(delta: float) -> void:
	
	if raycast.is_colliding():
		state = State.IDLE
		facing_right = not facing_right
		print("Ray cast front colliding. facing_right = ", facing_right)
			
	if is_on_floor():
		#("direction: " , direction)
		#print("WALK_SPEED: " , WALK_SPEED)
		velocity.x = direction * WALK_SPEED
		animated_sprite.play("walk")

		
func handle_idle(delta: float) -> void:
	
	velocity.x = 0
	animated_sprite.play("idle")
	
	idle_timer += delta
	if idle_timer >= IDLE_TIME:
		idle_timer = 0
		state = State.WALK


func handle_run() -> void:
	
	if not player:
		state = State.WALK
		return
	
	facing_right = sign(player.global_position.x - global_position.x) > 0
	velocity.x = direction * RUN_SPEED
	animated_sprite.play("run")

	
func handle_stunned(delta: float) -> void:
	
	stun_timer -= delta
	
	velocity.x = knockback_velocity.x
	knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 800 * delta)
	animated_sprite.play("knockback")

	
	if stun_timer <= 0:
		stun_timer = STUN_TIME
		state = State.RUN if player != null else State.WALK


func _on_aggro_body_entered(body: Node2D):
	
	if body.is_in_group("player"):
		player = body
		state = State.RUN
		
		
func _on_aggro_body_exited(body: Node2D):
	
	if body == player:
		player = null
		state = State.WALK
		
		
func _on_hitbox_body_entered(body: Node2D):
	if body.is_in_group("player_attack"):
		take_damage(1)
	elif body.is_in_group("player_block"):
		apply_blocked_knockback(body)
		
		
func apply_blocked_knockback(source: Node2D):
	state = State.STUNNED
	stun_timer = STUN_TIME
	
	var knock_dir = sign(global_position.x - source.global_position.x)
	direction = knock_dir
	
	knockback_velocity = Vector2(
		knock_dir * KNOCKBACK_FORCE,
		-40
	)
	animated_sprite.play("knockback")


func take_damage(amount: int):
	
	HEALTH -= amount
	animated_sprite.play("hit")
	state = State.HIT
	
	if HEALTH <= 0:
		die()
