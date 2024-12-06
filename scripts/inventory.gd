extends CanvasLayer


@onready var health_bar: ProgressBar = $OuterMarginContainer/OuterVBox/PlayerStatsVBox/HealthBar
@onready var inv_item_list: ItemList = %InvItemList
@onready var inv_panel: Panel = %InvPanel
@onready var inv_textbox: RichTextLabel = %InvTextbox
@onready var armor_types_item_list: ItemList = %ArmorTypesItemList
@onready var armor_item_list: ItemList = %ArmorItemList
@onready var armor_item_list_bg_color = armor_item_list.get_theme_stylebox("panel", "ItemList").bg_color
@onready var max_hp_label: RichTextLabel = %MaxHPLabel
@onready var atk_label: RichTextLabel = %ATKLabel
@onready var mag_label: RichTextLabel = %MAGLabel
@onready var def_label: RichTextLabel = %DEFLabel
@onready var resume: Button = %Resume


""" Inventory items """
## Item IDs
enum ITEMS {HEALTH_POTION, GREATER_HEALTH_POTION, GRANDMAS_COOKIES, ARMORSKIN_POTION, STALE_BREAD}
## List of item dictionaries, where each dictionary's index is the item's ID
var ITEM_MAPPINGS = [
	{"name": "Health Potion",
	"icon": preload("res://assets/health-potion.png"),
	"script": preload("res://scripts/items/health_potion.gd"),
	"desc": "Heals 25% of max health."},
	
	{"name": "Greater Health Potion",
	"icon": preload("res://assets/greater-health-potion.png"),
	"script": preload("res://scripts/items/greater_health_potion.gd"),
	"desc": "Heals 50% of max health."},
	
	{"name": "Grandma's Cookies",
	"icon": preload("res://assets/grandma-cookies.png"),
	"script": preload("res://scripts/items/grandmas_cookies.gd"),
	"desc": "Restores all health."},
	
	{"name": "Armorskin Potion",
	"icon": preload("res://assets/armorskin-potion.png"),
	"script": preload("res://scripts/items/armorskin_potion.gd"),
	"desc": "Increases defense by 50% of base defense."},
	
	{"name": "Stale Bread",
	"icon": preload("res://assets/stale-bread.png"),
	"script": preload("res://scripts/items/stale_bread.gd"),
	"desc": "Increases defense by 100% of base defense."},
]
## List of item IDs
var _inventory = [ITEMS.HEALTH_POTION]


""" Equipment """
## The different types of equipment.
## Most equipment variables begin with one of these strings.
var equipment_types = ["weapon", "helmet", "chestpiece", "boot"]
## Weapon IDs
enum WEAPONS {WITCH_SWORD, KNIGHT_WAND, THIEF_DAGGER}
## List of weapon dictionaries, where each dictionary's index is the weapon's ID
var WEAPON_MAPPINGS = [
	{"name": "Witch's Wand",
	"icon": preload("res://assets/witch-wand.png"),
	"hp": 0,
	"atk": 1,
	"mag": 4,
	"def": 0},
	
	{"name": "Knight's Sword",
	"icon": preload("res://assets/sword-item.png"),
	"hp": 0,
	"atk": 6,
	"mag": 0,
	"def": 1},
	
	{"name": "Thief's Dagger",
	"icon": preload("res://assets/sword-item.png"),
	"hp": 0,
	"atk": 8,
	"mag": 0,
	"def": 0},
]
## List of weapon IDs
var weapons_collected = []
## A weapon ID, or, if no weapon is equipped, -1
var weapon_equipped = -1

## Helmet IDs
enum HELMETS {WITCH_HAT, KNIGHT_HELM, THIEF_MASK}
## List of helmet dictionaries, where each dictionary's index is the helmet's ID
var HELMET_MAPPINGS = [
	{"name": "Witch's Hat",
	"icon": preload("res://assets/witch-hat.png"),
	"hp": 0,
	"atk": 0,
	"mag": 1,
	"def": 1},
	
	{"name": "Knight's Helm",
	"icon": preload("res://assets/helmet-item.png"),
	"hp": 0,
	"atk": 0,
	"mag": 0,
	"def": 2},
	
	{"name": "Thief's Hood",
	"icon": preload("res://assets/thief-hood.png"),
	"hp": 0,
	"atk": 2,
	"mag": 0,
	"def": 1},
]
## List of helmet IDs
var helmets_collected = []
## A helmet ID, or, if no helmet is equipped, -1
var helmet_equipped = -1

## Chestpiece IDs
enum CHESTPIECES {WITCH_CLOAK, KNIGHT_PLATE, THIEF_CLOAK}
## List of chestpiece dictionaries, where each dictionary's index is the chestpiece's ID
var CHESTPIECE_MAPPINGS = [
	{"name": "Witch's Cloak",
	"icon": preload("res://assets/witch-cloak.png"),
	"hp": 1,
	"atk": 0,
	"mag": 3,
	"def": 2},
	
	{"name": "Knight's Chestplate",
	"icon": preload("res://assets/chest-item.png"),
	"hp": 2,
	"atk": 0,
	"mag": 0,
	"def": 5},
	
	{"name": "Thief's Cloak",
	"icon": preload("res://assets/thief-cloak.png"),
	"hp": 0,
	"atk": 6,
	"mag": 0,
	"def": 2},
]
## List of chestpiece IDs
var chestpieces_collected = []
## A chestpiece ID, or, if no chestpiece is equipped, -1
var chestpiece_equipped = -1

## Boots IDs
enum BOOTS {WITCH_BOOTS, KNIGHT_BOOTS, THIEF_BOOTS}
## List of boots dictionaries, where each dictionary's index is the boots' ID
var BOOT_MAPPINGS = [
	{"name": "Witch's Boots",
	"icon": preload("res://assets/witch-boots.png"),
	"hp": 0,
	"atk": 0,
	"mag": 1,
	"def": 1},
	
	{"name": "Knight's Boots",
	"icon": preload("res://assets/boots-item.png"),
	"hp": 0,
	"atk": 0,
	"mag": 0,
	"def": 2},
	
	{"name": "Thief's Boots",
	"icon": preload("res://assets/boots-item.png"),
	"hp": 0,
	"atk": 2,
	"mag": 0,
	"def": 1},
]
## List of boots IDs
var boots_collected = []
## A boots ID, or, if no boots are equipped, -1
var boot_equipped = -1


func _input(event: InputEvent) -> void:
	if (event.is_action_pressed("ui_cancel")
			and PlayerState.state != PlayerState.State.BATTLING):
		set_visible(!visible)


## Add the equipment to the player's collection.
## type is one of ["weapon", "helmet", "chestpiece", "boot"].
## equip_id is an equipment enum value for the given type.
func collect_equipment(type: String, equip_id: int):
	if not equipment_types.has(type):
		printerr("collect_equipment(): Invalid equipment type!")
		return
	
	if get((type + "s").to_upper()).values().has(equip_id):
		get(type + "s_collected").append(equip_id)
	else:
		printerr("collect_equipment(): %s doesn't exist!" % type)


## Equips a collected item of the given type.
## type is one of ["weapon", "helmet", "chestpiece", "boot"].
## collected_equipment is an index into the array of collected equipment of that type,
## which itself contains equipment IDs (or enum values)
func equip(type: String, collected_equipment: int):
	if not equipment_types.has(type):
		printerr("equip(): Invalid equipment type!")
		return
	
	var equipments_collected = get(type + "s_collected")
	var EQUIP_MAPPINGS = get(type.to_upper() + "_MAPPINGS")
	
	if (equipments_collected.size() - 1 < collected_equipment
			or EQUIP_MAPPINGS.size() - 1 < equipments_collected[collected_equipment]):
		printerr("equip(): %s does not exist!" % type)
		return
	
	var equipped = get(type + "_equipped")
	if equipped != -1:
		_remove_equipment_modifiers(EQUIP_MAPPINGS[equipped])
	
	equipped = equipments_collected[collected_equipment]
	set(type + "_equipped", equipped)
	
	var equipment_dict = EQUIP_MAPPINGS[equipped]
	_add_equipment_modifiers(equipment_dict)


## Get the dictionary of the currently equipped item of the given type.
func get_equipped_dict(type: String) -> Dictionary:
	var equipped_id = get(type + "_equipped")
	if equipped_id != -1:
		return get_equipment_dict(type, equipped_id)
	else:
		return {}


## Get the dictionary of the collected equipment at the given index of the given type.
## index is an index into the collected equipment array.
func get_collected_equip_dict(type: String, index: int) -> Dictionary:
	if not equipment_types.has(type):
		printerr("equip(): Invalid equipment type!")
		return {}

	var equip_collected = get(type + "s_collected")
	var equip_id = equip_collected[index]
	return get_equipment_dict(type, equip_id)


## Get the dictionary of the equipment of the given type with the ID id,
## where an ID is an equipment enum value.
func get_equipment_dict(type: String, id: int) -> Dictionary:
	if not equipment_types.has(type):
		printerr("equip(): Invalid equipment type!")
		return {}
	
	var EQUIP_MAPPINGS = get(type.to_upper() + "_MAPPINGS")
	return EQUIP_MAPPINGS[id]


## Adds the given item to the inventory.
## item_id is an ITEMS enum value representing a type of item.
func add_inventory_item(item_id: ITEMS):
	_inventory.append(item_id)
	inv_item_list.add_item(ITEM_MAPPINGS[item_id]["name"],
			ITEM_MAPPINGS[item_id]["icon"])


## Removes an inventory item from the array and the item list at the given index.
## index corresponds to the item list's as well as the inventory array's index.
func remove_inventory_item_at_index(index: int):
	_inventory.remove_at(index)
	inv_item_list.remove_item(index)


## Updates the player's stats to remove this equipment's modifiers.
## equipment is a dictionary of equipment attributes
func _remove_equipment_modifiers(equipment: Dictionary):
	if PlayerState.player_stats["hp"] == PlayerState.player_stats["max_hp"]:
		PlayerState.player_stats["hp"] -= equipment["hp"]
	PlayerState.player_stats["max_hp"] -= equipment["hp"]
	PlayerState.player_stats["atk"] -= equipment["atk"]
	PlayerState.player_stats["mag"] -= equipment["mag"]
	PlayerState.player_stats["def"] -= equipment["def"]


## Updates the player's stats with equipment modifiers.
## equipment is a dictionary of equipment attributes
func _add_equipment_modifiers(equipment: Dictionary):
	if PlayerState.player_stats["hp"] == PlayerState.player_stats["max_hp"]:
		PlayerState.player_stats["hp"] += equipment["hp"]
	PlayerState.player_stats["max_hp"] += equipment["hp"]
	PlayerState.player_stats["atk"] += equipment["atk"]
	PlayerState.player_stats["mag"] += equipment["mag"]
	PlayerState.player_stats["def"] += equipment["def"]


func _on_inv_item_list_item_selected(index: int) -> void:
	inv_textbox.text = ITEM_MAPPINGS[_inventory[index]]["desc"]


func _on_inv_item_list_item_activated(index: int) -> void:
	var m_item = ITEM_MAPPINGS[_inventory[index]]["script"].new()
	m_item.call("use")
	m_item.queue_free()
	remove_inventory_item_at_index(index)
	_update_health_bar()
	if (inv_item_list.get_item_count() == 0):
		inv_textbox.text = ""
		armor_types_item_list.grab_focus()


func _on_inv_item_list_focus_entered() -> void:
	if (inv_item_list.get_item_count() > 0):
		inv_panel.show()
	else:
		if Input.is_action_just_pressed("ui_down"):
			resume.grab_focus()
		else:
			armor_types_item_list.grab_focus()


func _on_inv_item_list_focus_exited() -> void:
	inv_panel.hide()


func _on_item_list_focus_exited(item_list_path, textbox_path=false) -> void:
	var item_list = get_node(item_list_path)
	item_list.deselect_all()
	
	if textbox_path:
		var textbox = get_node(textbox_path)
		textbox.text = ""


func _on_item_list_focus_entered(item_list_path) -> void:
	var item_list = get_node(item_list_path)
	if (item_list.get_item_count() > 0):
		item_list.select(0)
		item_list.item_selected.emit(0)
		item_list.ensure_current_is_visible()


func _on_armor_types_item_list_item_selected(index: int) -> void:
	var equip_type = equipment_types[index]
	armor_item_list.clear()
	_update_armor_item_list(equip_type)
	
	var equipped = get(equip_type + "_equipped")
	if equipped != -1:
		var equip_collected = get(equip_type + "s_collected")
		var index_of_equipped = equip_collected.find(equipped)
		armor_item_list.set_item_custom_bg_color(index_of_equipped, Color(1, 1, 1, 1))
	_reset_labels_to_default()


func _on_armor_item_list_item_selected(index: int) -> void:
	# Get equipment data
	var equip_type = equipment_types[armor_types_item_list.get_selected_items()[0]]
	var equip_dict = get_collected_equip_dict(equip_type, index)
	
	# Find the current player stats minus the modifiers of the currently equipped
	# item of this type
	var max_hp = PlayerState.player_stats["max_hp"]
	var atk = PlayerState.player_stats["atk"]
	var mag = PlayerState.player_stats["mag"]
	var def = PlayerState.player_stats["def"]
	
	var equipped_dict = get_equipped_dict(equip_type)
	if equipped_dict:
		max_hp -= equipped_dict["hp"]
		atk -= equipped_dict["atk"]
		mag -= equipped_dict["mag"]
		def -= equipped_dict["def"]
	
	# Calculate would-be player stats if the selected item is equipped
	var new_max_hp = max_hp + equip_dict["hp"]
	var new_atk = atk + equip_dict["atk"]
	var new_mag = mag + equip_dict["mag"]
	var new_def = def + equip_dict["def"]
	
	# Update labels
	_update_label_color(max_hp_label, new_max_hp, PlayerState.player_stats["max_hp"])
	max_hp_label.add_text("Max HP: %d" % new_max_hp)
	_update_label_color(atk_label, new_atk, PlayerState.player_stats["atk"])
	atk_label.add_text("ATK: %d" % new_atk)
	_update_label_color(mag_label, new_mag, PlayerState.player_stats["mag"])
	mag_label.add_text("MAG: %d" % new_mag)
	_update_label_color(def_label, new_def, PlayerState.player_stats["def"])
	def_label.add_text("DEF: %d" % new_def)


func _on_armor_item_list_item_activated(index: int) -> void:
	# Show item as selected
	_reset_armor_item_list_item_colors()
	armor_item_list.set_item_custom_bg_color(index, Color(1, 1, 1, 1))
	
	# Equip the item
	var equip_type = equipment_types[armor_types_item_list.get_selected_items()[0]]
	equip(equip_type, index)
	
	_update_health_bar(false)


## Populates the armor item list with all collected items of the given type.
func _update_armor_item_list(equipment_type: String):
	if not equipment_types.has(equipment_type):
		printerr("equip(): Invalid equipment type!")
		return

	var equipments_collected = get(equipment_type + "s_collected")
	var EQUIP_MAPPINGS = get(equipment_type.to_upper() + "_MAPPINGS")
	for equipment_id in equipments_collected:
		var equip_dict = EQUIP_MAPPINGS[equipment_id]
		armor_item_list.add_item(equip_dict["name"], equip_dict["icon"])


## Sets every item's background color to the default background color.
func _reset_armor_item_list_item_colors():
	for index in range(0, armor_item_list.get_item_count()):
		armor_item_list.set_item_custom_bg_color(index, armor_item_list_bg_color)


## Changes the color of the given label based on whether its new value will
## be larger or smaller than the given int (generally a player stat).
func _update_label_color(label: RichTextLabel, new_value: int, compare_to: int):
	label.clear()
	if new_value > compare_to:
		label.push_color(Color(0, 1, 0, 1))
	elif new_value < compare_to:
		label.push_color(Color(1, 0, 0, 1))


## Sets all labels to the current player stats,
## as opposed to hypothetical stats from certain equipment.
func _reset_labels_to_default():
	max_hp_label.clear()
	max_hp_label.add_text("Max HP: %d" % PlayerState.player_stats["max_hp"])
	atk_label.clear()
	atk_label.add_text("ATK: %d" % PlayerState.player_stats["atk"])
	mag_label.clear()
	mag_label.add_text("MAG: %d" % PlayerState.player_stats["mag"])
	def_label.clear()
	def_label.add_text("DEF: %d" % PlayerState.player_stats["def"])


## Updates the player's health bar for the current hp and max_hp.
func _update_health_bar(to_tween=true):
	var health = PlayerState.player_stats["hp"]
	var max_health = PlayerState.player_stats["max_hp"]
	
	health_bar.max_value = max_health
	var t_tween = create_tween().bind_node(health_bar)
	if to_tween:
		t_tween.tween_property(health_bar, "value", health, 0.5)
	else:
		health_bar.value = health
	health_bar.get_node("Label").text = "%s: %d/%d" % ["HP", health, max_health]


func _on_visibility_changed() -> void:
	if visible:
		# Initialize inventory
		inv_item_list.clear()
		for item in _inventory:
			inv_item_list.add_item(ITEM_MAPPINGS[item]["name"],
					ITEM_MAPPINGS[item]["icon"])
		
		# Update view
		_update_health_bar(false)
		
		_reset_labels_to_default()
		
		armor_types_item_list.grab_focus()
		armor_types_item_list.select(0)
		armor_types_item_list.item_selected.emit(0)
		
		# Prevent player movement
		PlayerState.state = PlayerState.State.IN_MENU
	else:
		PlayerState.state = PlayerState.State.MOVING


func _on_resume_pressed() -> void:
	set_visible(false)
