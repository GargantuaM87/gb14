extends Upgrade

@export var shieldUpgrade : String = ""

func apply_upgrade() -> void:
	EventBus.trigger_shield_upgrade(shieldUpgrade)
