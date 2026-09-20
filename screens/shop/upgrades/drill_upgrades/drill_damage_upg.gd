extends Upgrade

@export var drillDamage := 1

func apply_upgrade() -> void:
	GlobalState.player.drill_damage = drillDamage
	
