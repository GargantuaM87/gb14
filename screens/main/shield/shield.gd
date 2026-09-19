extends Node2D

@onready var camera : Camera2D = %Camera

func _ready() -> void:
	EventBus.monster_hit_shield.connect(_on_monster_hit_shield)

func _on_monster_hit_shield(damage: int) -> void:
	GlobalState.shield_health -= damage
	#if GlobalState.shield_health <= GlobalState.max_shield_health * 0.25:
	#camera.add_trauma(1.0)
	if GlobalState.shield_health <= 0:
		print("Game Over")
