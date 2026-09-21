extends PanelContainer

@export var upgResource : UpgradeResource:
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

@export var lockColorBorder : Color
@export var unlockColorBorder : Color

@onready var textureRect : TextureRect = $TextureRect


var parent : UpgradeResource

const UPGRADE_ICON_STYLEBOX = preload("res://screens/shop/upgrades/upg_icon_style.tres")

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
	var styleBox : StyleBoxFlat = get_theme_stylebox("panel").duplicate()
	
	if upgResource.isUnlocked:
		styleBox.border_color = unlockColorBorder
	else:
		styleBox.border_color = lockColorBorder
		
	add_theme_stylebox_override("panel", styleBox)
	
func set_parent(parent : UpgradeResource) -> void:
	self.parent = parent
	
func unlock_upgrade() -> void:
	if upgResource.isUnlocked == true:
		return
		
	if !parent or (parent and parent.isUnlocked):
		if GlobalState.money >= upgResource.upgradeCost:
			upgResource.isUnlocked = true
			GlobalState.money -= upgResource.upgradeCost
			set_style()
			if upgResource.app:
				upgResource.app.apply_upgrade()

func _on_button_pressed() -> void:
	unlock_upgrade()
