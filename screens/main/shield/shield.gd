extends Node2D

func _ready() -> void:
	EventBus.monster_hit_shield.connect(_on_monster_hit_shield)

func _on_monster_hit_shield(damage: int) -> void:
	GlobalState.shield_health -= damage

	if GlobalState.shield_health <= 0:
		print("Game Over")
