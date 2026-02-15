class_name Enemy
extends Creature

enum State {IDLE, WALK, RUN, HIT, STUNNED}

@export var STUN_TIME = 0.5
@onready var raycast: RayCast2D = $Pivot/RayCast
@onready var killzone: Area2D = $KillArea2D
@onready var blood_parent: Node2D = $BloodParent2D
@onready var blood_sprite: AnimatedSprite2D = $BloodParent2D/BloodSprite2D

var state: State = State.WALK
var idle_timer = IDLE_TIME
var stun_timer = STUN_TIME
var player: Node2D = null

func _physics_process(delta: float):
	
	match state:
		State.IDLE:
			handle_idle(delta)
		State.WALK:
			handle_walk(delta)
		State.RUN:
			handle_run()
		State.HIT:
			handle_hit(delta)
		State.STUNNED:
			handle_stun(delta)
				
	super._physics_process(delta)
	

func handle_walk(delta: float):
	
	if raycast.is_colliding():
		state = State.IDLE
		facing_right = not facing_right
		print("Ray cast front colliding. facing_right = ", facing_right)
			
	if is_on_floor():
		velocity.x = direction * WALK_SPEED
		animated_sprite.play("walk")

		
func handle_idle(delta: float):
	
	velocity.x = 0
	animated_sprite.play("idle")
	
	idle_timer -= delta
	if idle_timer <= 0:
		idle_timer = IDLE_TIME
		state = State.WALK


func handle_run():
	
	if not player:
		state = State.WALK
		return
	
	facing_right = sign(player.global_position.x - global_position.x) > 0
	velocity.x = direction * RUN_SPEED
	animated_sprite.play("run")
	

func handle_hit(delta: float):
	
	var hit_direction = get_hit_dir()
	blood_parent.scale.x = abs(blood_sprite.scale.x) * hit_direction
	
	animated_sprite.play("hit")
	blood_sprite.play("blood")
	await animated_sprite.animation_finished
	state = State.RUN if player != null else State.WALK
	

func handle_stun(delta: float):
	
	velocity.x = 0
	stun_timer -= delta
	animated_sprite.play("knockback")
	
	if stun_timer <= 0:
		stun_timer = STUN_TIME
		state = State.RUN if player != null else State.WALK


func take_sword_hit(player: Creature):
	receive_damage(player.DAMAGE)
	receive_knockback(player.KNOCKBACK_FORCE)
	state = State.HIT
	

func take_shield_block(player: Creature):
	
	receive_knockback(player.KNOCKBACK_FORCE * 3)
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
	
	velocity.x = 0
	killzone.monitorable = false
	killzone.monitoring = false
	
	var hit_direction = get_hit_dir()
	blood_parent.scale.x = abs(blood_sprite.scale.x) * hit_direction
	
	animated_sprite.play("hit")
	blood_sprite.play("blood")
	await animated_sprite.animation_finished
	
	print(name, " died")
	queue_free()
