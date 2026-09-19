extends Camera2D

@export var player: Player
@export var follow_speed := 8.0

var _smoothed_position := Vector2.ZERO
var _is_initialized := false
# Shake Parameters
@export_group("Shake Parameters")
@export var decay : float = 0.6 # Time period for the shaking
@export var max_offset : Vector2 = Vector2(100, 75) # How much the shaking will displace the camera
@export var max_roll : float = 0.1 # Rotations involved in the shake (radians)

var trauma = 0.0 # Shake strength
var trauma_power = 2 # Shake exponential multiplier

func _ready() -> void:
	randomize()

func _process(delta: float) -> void:
	if !player:
		return
		
	if trauma:
		trauma = max(trauma - decay * delta, 0)
		shake_camera()

	if !_is_initialized:
		_smoothed_position = player.global_position
		global_position = _smoothed_position.round()
		_is_initialized = true
		return

	var smoothing_weight := 1.0 - exp(-follow_speed * delta)
	_smoothed_position = _smoothed_position.lerp(player.global_position, smoothing_weight)
	global_position = _smoothed_position.round()

func add_trauma(amount : float):
	trauma = min(trauma + amount, 0)
	
func shake_camera():
	var amount = pow(trauma, trauma_power)
	rotation = max_roll * amount * randi_range(-1, 1)
	offset.x = max_offset.x * amount * randi_range(-1, 1)
	offset.y = max_offset.y * amount * randi_range(-1, 1)
