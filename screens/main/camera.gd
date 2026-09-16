extends Camera2D

@export var player: Player
@export var follow_speed := 8.0

var _smoothed_position := Vector2.ZERO
var _is_initialized := false

func _process(delta: float) -> void:
	if !player:
		return

	if !_is_initialized:
		_smoothed_position = player.global_position
		global_position = _smoothed_position.round()
		_is_initialized = true
		return

	var smoothing_weight := 1.0 - exp(-follow_speed * delta)
	_smoothed_position = _smoothed_position.lerp(player.global_position, smoothing_weight)
	global_position = _smoothed_position.round()
