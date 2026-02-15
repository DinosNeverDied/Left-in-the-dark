class_name Creature
extends CharacterBody2D

@export var DAMAGE = 1
@export var HEALTH = 3
@export var WALK_SPEED = 60.0
@export var RUN_SPEED = 120.0
@export var KNOCKBACK_FORCE = 660.0
@export var WEIGHT = 80.0
@onready var pivot: Node2D = $Pivot
@onready var animated_sprite: AnimatedSprite2D = $Pivot/AnimatedSprite2D

var facing_right = true

var direction: int:
	get:
		return 1 if facing_right else -1

var momentum: int:
	get:
		return RUN_SPEED * WEIGHT

func get_hit_dir():
	return sign(%Knight.global_position.x - global_position.x)

func receive_damage(damage: int):
	print(name, " HP: ", HEALTH, " => ", HEALTH - damage)
	HEALTH -= damage
	if HEALTH <= 0:
		die()


func receive_knockback(knockback_momentum: float):
	# print(name, " was blocked by " + creature.name)
	var dir = get_hit_dir()
	position += Vector2(knockback_momentum / WEIGHT * -dir, 0)

func _physics_process(delta: float):
	pivot.scale.x = direction

	# apply gravity 
	if not is_on_floor():
		velocity += get_gravity() * delta

	move_and_slide()

func die():
	print(name, " died")
	queue_free()
