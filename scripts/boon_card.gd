extends Control

var regex = RegEx.new()

@export var title_node: Control
@export var description_node: Control
@export var rarity_node: Control

var boon: Boon


func _ready():
	regex.compile("\\{(.*?)\\}")



func load_boon(_boon: Boon):
	boon = _boon

	title_node.text = boon.title

	title_node.text = boon.title
	rarity_node.text = Boon.Rarity.keys()[boon.rarity].capitalize()
	description_node.text = process_rarity_text(
		boon.description.replace("VALUE", str(snapped(boon.value, 0.01))))

	%IconDark.visible = boon.is_dark
	%IconLight.visible = not boon.is_dark


func _on_choosing_button_pressed():
	get_viewport().set_input_as_handled()

	GameManager.boon_selected.emit(boon)


# {x/y/z} syntax allows us to write descriptions like "Increases attack by {10%/20%/30%} based on rarity"
func process_rarity_text(input: String) -> String:
	var result = input
	var matches = regex.search_all(input)
	
	for m in matches:
		var full_match = m.get_string()
		var content = m.get_string(1)
		var options = content.split("/")
		
		var index = min(boon.rarity, options.size() - 1)
		var picked = options[index]
		
		result = result.replace(full_match, picked)
	
	return result
