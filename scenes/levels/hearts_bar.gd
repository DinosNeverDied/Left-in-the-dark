extends HBoxContainer

@export var player: Player

@onready var heart1: TextureRect = $Heart1
@onready var heart2: TextureRect = $Heart2
@onready var heart3: TextureRect = $Heart3
@onready var heart4: TextureRect = $Heart4
@onready var heart5: TextureRect = $Heart5


func _process(_delta: float):
	heart1.visible = player.HEALTH >= 1
	heart2.visible = player.HEALTH >= 2
	heart3.visible = player.HEALTH >= 3
	heart4.visible = player.HEALTH >= 4
	heart5.visible = player.HEALTH >= 5
	pass
