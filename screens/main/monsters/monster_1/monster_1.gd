extends Monster

const SPEED := 15.0
const DAMAGE := 1

const MIN_DESCENT_ANGLE_DEGREES := 5.0
const MAX_DESCENT_ANGLE_DEGREES := 25.0
const SWAY_AMPLITUDE := 2.0
const SWAY_CYCLE_DURATION := 2.0

var _spawn_position := Vector2.ZERO
var _descent_direction := Vector2.DOWN
var _sway_direction := Vector2.RIGHT
var _elapsed_time := 0.0

func _ready() -> void:
	_spawn_position = position

	var minimum_angle := minf(MIN_DESCENT_ANGLE_DEGREES, MAX_DESCENT_ANGLE_DEGREES)
	var maximum_angle := maxf(MIN_DESCENT_ANGLE_DEGREES, MAX_DESCENT_ANGLE_DEGREES)
	var descent_angle := deg_to_rad(randf_range(minimum_angle, maximum_angle))
	if randf() < 0.5:
		descent_angle = - descent_angle

	_descent_direction = Vector2(sin(descent_angle), cos(descent_angle)).normalized()
	_sway_direction = Vector2(-_descent_direction.y, _descent_direction.x)

func _process(delta: float) -> void:
	_elapsed_time += delta

	var centerline_position := _spawn_position + _descent_direction * SPEED * _elapsed_time
	var sway := sin(TAU * _elapsed_time / SWAY_CYCLE_DURATION) * SWAY_AMPLITUDE
	position = centerline_position + _sway_direction * sway

func _on_area_2d_area_entered(_area: Area2D) -> void:
	if is_queued_for_deletion():
		return
	
	queue_free()

	EventBus.trigger_monster_hit_shield(DAMAGE)
