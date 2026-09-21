extends Node2D

const MIN_X := -50.0
const MAX_X := 50.0
const MOVE_SPEED := 8.0
const MIN_MOVE_DURATION := 0.5
const MAX_MOVE_DURATION := 2.5
const MIN_PAUSE_DURATION := 1.0
const MAX_PAUSE_DURATION := 5.0

@onready var person: Node2D = %Person

func _ready() -> void:
	_wander()


func _wander() -> void:
	while is_inside_tree():
		var direction := _get_direction()
		person.scale.x = -1.0 if direction < 0.0 else 1.0
		var move_duration := randf_range(MIN_MOVE_DURATION, MAX_MOVE_DURATION)
		var target_x := person.position.x + direction * MOVE_SPEED * move_duration

		var tween := create_tween()
		tween.set_trans(Tween.TRANS_SINE)
		tween.set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(person, "position:x", target_x, move_duration)
		await tween.finished

		var pause_duration := randf_range(MIN_PAUSE_DURATION, MAX_PAUSE_DURATION)
		await get_tree().create_timer(pause_duration).timeout


func _get_direction() -> float:
	if person.position.x <= MIN_X:
		return 1.0
	if person.position.x >= MAX_X:
		return -1.0

	return -1.0 if randi_range(0, 1) == 0 else 1.0
