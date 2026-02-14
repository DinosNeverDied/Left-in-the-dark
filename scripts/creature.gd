class_name Creature
extends CharacterBody2D

@export var DAMAGE = 1
@export var HEALTH = 1
@export var SPEED = 80.0

@onready var pivot: Node2D = $Pivot
@onready var animated_sprite: AnimatedSprite2D = $Pivot/AnimatedSprite2D

var direction = 1
var facing_right = true

func is_attacked(creature: Creature):
	HEALTH -= creature.DAMAGE
	if HEALTH <= 0:
		queue_free()

func _physics_process(delta: float):
	pivot.scale.x = -1 if not facing_right else 1

	# apply gravity 
	if not is_on_floor():
		velocity += get_gravity() * delta

	move_and_slide()
