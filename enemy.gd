class_name Enemy
extends Creature

enum State { IDLE, WALK, RUN, HIT, STUNNED }

@export var IDLE_TIME = 2.0
@export var WALK_SPEED = 60.0
@export var KNOCKBACK_FORCE = 220.0
@export var STUN_TIME = 0.4

@onready var ray_cast: RayCast2D = $RayCast2D
@onready var ray_cast2: RayCast2D = $RayCast2D2
@onready var aggro: Area2D = $Aggro
@onready var hitbox: Area2D = $Hitbox

var state: State = State.WALK
var idle_timer = 0.0
var stun_timer = STUN_TIME
var knockback_velocity = Vector2.ZERO
var player_shape: Node2D = null

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
				
	move_and_slide()
	

func handle_walk(_delta: float) -> void:
	
	#change direction according to which raycast is colliding
	#idle after hitting an edge
	if ray_cast.is_colliding():
		facing_right = false
		state = State.IDLE
	elif ray_cast2.is_colliding():
		facing_right = true
		state = State.IDLE
		
	if is_on_floor():
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
	
	if not player_shape:
		state = State.WALK
		return
	
	direction = sign(player_shape.global_position.x - global_position.x)
	velocity.x = direction * RUN_SPEED
	animated_sprite.play("run")
	

func handle_stunned(delta: float) -> void:
	
	stun_timer -= delta
	
	velocity.x = knockback_velocity.x
	knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 800 * delta)
	animated_sprite.play("knockback")
	
	if stun_timer <= 0:
		stun_timer = STUN_TIME
		state = State.RUN if player_shape != null else State.WALK


func _on_aggro_body_entered(body: CollisionShape2D):
	player_shape = body
	state = State.RUN
		

func _on_aggro_body_exited(_body: CollisionShape2D):
	player_shape = null
	state = State.WALK
