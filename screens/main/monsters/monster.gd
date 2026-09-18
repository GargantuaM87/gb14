class_name Monster
extends Node2D

@export var base_hp := 1

const HP_INCREASE_INTERVAL := 2

var hp := 1
var max_hp := 1

func initialize_for_wave(wave_number: int) -> void:
	var hp_bonus := floori(float(maxi(wave_number - 1, 0)) / HP_INCREASE_INTERVAL)
	max_hp = maxi(base_hp + hp_bonus, 1)
	hp = max_hp

func take_damage(damage: int) -> void:
	if is_queued_for_deletion():
		return
	
	hp -= damage

	if hp <= 0:
		queue_free()
