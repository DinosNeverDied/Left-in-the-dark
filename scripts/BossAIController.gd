class_name BossAIController
extends Node

@onready var knight: Boss = $"../Knight"
@onready var target: Player

@export var attack_range = 40.0
@export var reaction_time = 0.4

var decision_timer = 0.0

func _ready() -> void:
	target = get_tree().get_first_node_in_group("player")

func _physics_process(delta):
	if knight.dead:
		return

	decision_timer -= delta
	if decision_timer > 0:
		return

	decision_timer = reaction_time

	var distance = abs(target.global_position.x - knight.global_position.x)
	var direction = sign(target.global_position.x - knight.global_position.x)

	knight.wants_to_attack = false
	knight.wants_to_block = false

	knight.move_direction = direction if distance > attack_range else 0

	if target.global_position.y < knight.global_position.y and knight.is_on_floor() and target.is_on_floor():
		knight.wants_to_jump = true
		return

	if target.attacking and distance <= attack_range:
		if knight.STAMINA > 0:
			knight.wants_to_block = true
			return

	if not target.attacking and distance <= attack_range:
		if randf() < 0.75:
			knight.wants_to_attack = true
			return

	if distance > attack_range:
		if randf() < 0.2:
			knight.wants_to_block = true
