extends Upgrade

@export var maxHealthUpgrade := 15
@export var repairHealth := 15

func apply_upgrade() -> void:
	GlobalState.max_shield_health += maxHealthUpgrade
	GlobalState.shield_health += repairHealth
