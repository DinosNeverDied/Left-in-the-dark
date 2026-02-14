extends CharacterBody2D

enum State {IDLE, WALK, RUN, HIT, STUNNED, DEAD}

@export var IDLE_SPEED = 0
@export var IDLE_TIME = 2.0
@export var MAX_HP = 3
@export var WALK_SPEED = 60.0
@export var RUN_SPEED = 120.0
@export var KNOCKBACK_FORCE = 220.0
@export var STUN_TIME = 0.4

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_cast: RayCast2D = $RayCast2D
@onready var ray_cast2: RayCast2D = $RayCast2D2
@onready var aggro: Area2D = $Aggro
@onready var hitbox: Area2D = $Hitbox

var direction = 1
var state: State = State.WALK
var idle_timer = 0.0
var stun_timer = STUN_TIME
var knockback_velocity = Vector2.ZERO
var current_hp = MAX_HP
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
				
	move_and_slide()
	
func handle_walk(delta: float) -> void:
	
	#change direction according to which raycast is colliding
	#idle after hitting an edge
	if ray_cast.is_colliding():
		direction = -1
		state = State.IDLE
	elif ray_cast2.is_colliding():
		direction = 1
		state = State.IDLE
		
	if is_on_floor():
		velocity.x = direction * WALK_SPEED
		animated_sprite_2d.play("walk")
	#apply gravity
	else:
		velocity += get_gravity() * delta
	#flipping the sprite according to direction
	if direction == 1:
		animated_sprite_2d.flip_h = true
	else:
		animated_sprite_2d.flip_h = false
		
func handle_idle(delta: float) -> void:
	
	velocity.x = IDLE_SPEED
	animated_sprite_2d.play("idle")
	
	idle_timer += delta
	if idle_timer >= IDLE_TIME:
		idle_timer = 0
		state = State.WALK

func handle_run() -> void:
	
	if not player:
		state = State.WALK
		return
	
	direction = sign(player.global_position.x - global_position.x)
	velocity.x = direction * RUN_SPEED
	animated_sprite_2d.play("run")
	
func handle_stunned(delta: float) -> void:
	
	stun_timer -= delta
	
	velocity.x = knockback_velocity.x
	knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 800 * delta)
	animated_sprite_2d.play("knockback")
	
	if stun_timer <= 0:
		stun_timer = STUN_TIME
		state = State.RUN if player != null else State.WALK

func _on_aggro_body_entered(body: CollisionShape2D):
	
	if body.is_in_group("knight"):
		player = body
		state = State.RUN
		
func _on_aggro_body_exited(body: CollisionShape2D):
	
	if body == player:
		player = null
		state = State.WALK

func take_damage(amount: int):
	
	current_hp -= amount
	animated_sprite_2d.play("hit")
	state = State.HIT
	
	if current_hp <= 0:
		die()
		
func die():
	
	state = State.DEAD
	velocity = Vector2.ZERO
	queue_free()
