class_name Gold
extends Node2D

@export var value := 1

func _on_area_2d_body_entered(_body: Node2D) -> void:
	if is_queued_for_deletion():
		return
	
	SfxManager.play_sfx_gold()
	queue_free()

	GlobalState.money += value * GlobalState.moneyMult
