extends Node

signal money_changed()
signal seconds_until_next_wave_changed()
signal monster_hit_shield(damage: int)
signal shield_health_changed()

func trigger_money_changed() -> void:
	money_changed.emit()

func trigger_seconds_until_next_wave_changed() -> void:
	seconds_until_next_wave_changed.emit()

func trigger_monster_hit_shield(damage: int) -> void:
	monster_hit_shield.emit(damage)

func trigger_shield_health_changed() -> void:
	shield_health_changed.emit()