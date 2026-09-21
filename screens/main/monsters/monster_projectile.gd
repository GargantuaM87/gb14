class_name MonsterProjectile
extends Node2D

var hp := 1

func take_damage(damage: int) -> void:
	if is_queued_for_deletion():
		return
	
	hp -= damage

	if hp <= 0:
		queue_free()
