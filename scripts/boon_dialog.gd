class_name BoonDialog extends Control

@onready var dark_boons: Array[Boon]
@onready var light_boons: Array[Boon]


static var chance_by_rarity = {
	Boon.Rarity.COMMON: 0.80, 
	Boon.Rarity.RARE: 0.00, 
	Boon.Rarity.EPIC: 0.20
}

func _ready():
	reload_boons();
	GameManager.player_died.connect(_on_player_died)
	GameManager.drink_acquired.connect(_on_drink_acquired)
	GameManager.boon_selected.connect(_on_boon_selected)
	visible = false


func _on_drink_acquired(drink: Drink):
	var random_boons = pick_3_random_boons(drink.is_dark)
	var available_boon_count = random_boons.size()

	if available_boon_count == 0:
		return

	var cards = [%BoonCard1, %BoonCard2, %BoonCard3]

	for index in range(cards.size()):
		var card = cards[index]
		card.visible = index < available_boon_count
		if card.visible:
			card.load_boon(random_boons[index])

	visible = true
	get_tree().paused = true


func _on_boon_selected(boon: Boon):
	visible = false
	get_tree().paused = false

	if boon.is_dark:
		dark_boons.erase(boon)
	else:
		light_boons.erase(boon)


func _on_player_died():
	reload_boons()


func reload_boons():
	dark_boons = load_boons_from_directory(true)
	light_boons = load_boons_from_directory(false)


func load_boons_from_directory(is_dark) -> Array[Boon]:
	var path = "res://boons/" + ("dark" if is_dark else "light") + "/"
	var dir = DirAccess.open(path)

	if not dir:
		push_error("Failed to open boon directory: " + path)
		return []

	var boons: Array[Boon] = []
	for file in dir.get_files():
		if file.ends_with(".tres"):
			var resource = load(path + file)
			if resource is Boon:
				boons.append(resource)

	return boons


func pick_3_random_boons(is_dark: bool) -> Array[Boon]:
	var boons = dark_boons if is_dark else light_boons
	boons.shuffle()
	var three_boons = boons.slice(0, 3)
	for boon in three_boons:
		var added_chance = 0.0
		for rarity in chance_by_rarity:
			added_chance += chance_by_rarity[rarity]
			if randf() < added_chance:
				boon.rarity = rarity
				break
	return three_boons
