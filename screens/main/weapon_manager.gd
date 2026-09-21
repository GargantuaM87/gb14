extends Node2D

@export var unlockedUpgrades : Dictionary[String, Node2D] = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBus.weapon_upgraded.connect(activate_weapon)

func activate_weapon(weapon : String) -> void:
	unlockedUpgrades[weapon].process_mode = Node.PROCESS_MODE_INHERIT
	unlockedUpgrades[weapon].show()
