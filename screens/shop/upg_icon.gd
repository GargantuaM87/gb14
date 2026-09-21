extends PanelContainer

@export var upgResource: UpgradeResource:
	set(newValue):
		upgResource = newValue
		
		if not Engine.is_editor_hint():
			return
		
		if newValue == null:
			add_theme_stylebox_override("panel", StyleBoxEmpty.new())
			textureRect.texture = null
		else:
			add_theme_stylebox_override("panel", UPGRADE_ICON_STYLEBOX)
			textureRect.texture = upgResource.upgIcon

@onready var textureRect: TextureRect = $TextureRect


var parent: UpgradeResource
var is_selected := false

const UPGRADE_ICON_STYLEBOX = preload("res://screens/shop/upgrades/upg_icon_style.tres")
const AVAILABLE_BACKGROUND_COLOR := Color(0.35, 0.35, 0.35, 1.0)
const PURCHASED_BACKGROUND_COLOR := Color(0.65, 0.65, 0.65, 1.0)
const UNSELECTED_BORDER_COLOR := Color.BLACK
const SELECTED_BORDER_COLOR := Color.WHITE

func _ready() -> void:
	if not upgResource:
		return
	
	add_to_group("upgrades")
	textureRect.texture = upgResource.upgIcon
	
	add_theme_stylebox_override("panel", UPGRADE_ICON_STYLEBOX)
	
	set_style()

func get_center():
	return size / 2

func set_style():
	var styleBox: StyleBoxFlat = get_theme_stylebox("panel").duplicate()

	styleBox.bg_color = PURCHASED_BACKGROUND_COLOR if upgResource.isUnlocked else AVAILABLE_BACKGROUND_COLOR
	styleBox.border_color = SELECTED_BORDER_COLOR if is_selected else UNSELECTED_BORDER_COLOR
		
	add_theme_stylebox_override("panel", styleBox)

func set_selected(selected: bool) -> void:
	is_selected = selected
	set_style()
	
func set_parent(parent: UpgradeResource) -> void:
	self.parent = parent
	
func unlock_upgrade() -> void:
	if GlobalState.is_game_over || !upgResource:
		return

	if upgResource.isUnlocked == true:
		return
		
	if !parent or (parent and parent.isUnlocked):
		if GlobalState.money >= upgResource.upgradeCost:
			upgResource.isUnlocked = true
			GlobalState.money -= upgResource.upgradeCost
			SfxManager.play_fx_menu_upgrade()
			set_style()
			if upgResource.app:
				upgResource.app.apply_upgrade()
		else:
			SfxManager.play_sfx_cant_afford()
	else:
		SfxManager.play_sfx_cant_afford()

func _on_button_pressed() -> void:
	unlock_upgrade()
