extends Upgrade

@export var goldMultipler : int = 1

func apply_upgrade() -> void:
	GlobalState.moneyMult = goldMultipler
