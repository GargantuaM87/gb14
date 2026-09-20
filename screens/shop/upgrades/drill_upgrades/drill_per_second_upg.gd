extends Upgrade

@export var drillPerSecond := 1

func apply_upgrade() -> void:
	GlobalState.player.drills_per_second = drillPerSecond
