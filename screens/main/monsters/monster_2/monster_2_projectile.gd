extends MonsterProjectile

const SPEED := 20.0
const DAMAGE := 1

func _process(delta: float) -> void:
	position.y += SPEED * delta

func _on_area_2d_area_entered(_area: Area2D) -> void:
	if is_queued_for_deletion():
		return
	
	queue_free()

	EventBus.trigger_monster_hit_shield(DAMAGE)