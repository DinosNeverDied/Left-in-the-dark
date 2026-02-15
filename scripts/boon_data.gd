class_name BoonData
extends Resource

enum Type { HEALTH, ATTACK_MULTIPLIER, SPEED, DEFENSE }
enum Rarity { COMMON, RARE, EPIC }

@export var title: String
@export var description: String
@export var type: Type
@export var value: float
@export var rarity: Rarity