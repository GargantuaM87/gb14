extends Upgrade

@export var maxHealthUpgrade := 40
@export var repairHealth := 40

func apply_upgrade() -> void:
	GlobalState.max_shield_health += maxHealthUpgrade
	GlobalState.shield_health += repairHealth
