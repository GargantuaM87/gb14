extends Node

signal money_changed()
signal seconds_until_next_wave_changed()
signal wave_state_changed()
signal player_above_ground_changed()
signal monster_hit_shield(damage: int)
signal shield_health_changed()
signal shield_upgraded(upgrade : String)
signal weapon_upgraded(upgrade : String)

func trigger_money_changed() -> void:
	money_changed.emit()

func trigger_seconds_until_next_wave_changed() -> void:
	seconds_until_next_wave_changed.emit()

func trigger_wave_state_changed() -> void:
	wave_state_changed.emit()

func trigger_player_above_ground_changed() -> void:
	player_above_ground_changed.emit()

func trigger_monster_hit_shield(damage: int) -> void:
	monster_hit_shield.emit(damage)

func trigger_shield_health_changed() -> void:
	shield_health_changed.emit()

func trigger_shield_upgrade(upgrade : String) -> void:
	shield_upgraded.emit(upgrade)

func trigger_weapon_upgrade(upgrade : String) -> void:
	weapon_upgraded.emit(upgrade)
