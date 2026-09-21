extends Upgrade

@export var upgrade : String = ""

func apply_upgrade() -> void:
	EventBus.trigger_weapon_upgrade(upgrade)
