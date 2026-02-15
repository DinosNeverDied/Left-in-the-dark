class_name Miniboss
extends Creature

enum State {IDLE, WALK, RUN, HIT, ATTACK, DEAD}

@onready var raycast: RayCast2D = $Pivot/RayCast
@onready var aggro: Area2D = $Aggro
@onready var hitbox: Area2D = $Hitbox

var state: State = State.WALK
var idle_timer = 0.0
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
		State.ATTACK:
			handle_attack(delta)
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
	
	if abs(player.global_position.x - global_position.x) < 50:
		state = State.ATTACK

	
func handle_attack(delta: float) -> void:
	
	match randi() % 2:
		0:
			velocity.x = 0
			animated_sprite.play("attack2")
			if animated_sprite.animation_finished:
				state = State.HIT
		1:
			velocity.x /= 2
			animated_sprite.play("attack2b")
			if animated_sprite.animation_finished:
				state = State.HIT


func _on_aggro_body_entered(body: Node2D):
	
	if body.is_in_group("player"):
		player = body
		state = State.RUN
		
func die():
	animated_sprite.play("death")
	super.die()
