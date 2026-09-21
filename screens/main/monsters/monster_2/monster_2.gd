extends Monster

@onready var projectile_spawn_point: Marker2D = %ProjectileSpawnPoint

@export var spawn_descent_distance := 40.0

const PROJECTILE_SCENE: PackedScene = preload("uid://bgc7ptaqd8lxg")
const DESCENT_DURATION := 2.0
const HORIZONTAL_SPEED := 20.0
const DOWNWARD_STEP_DISTANCE := 8.0
const DOWNWARD_DURATION := 0.4
const MIN_MOVE_DURATION := 3.0
const MAX_MOVE_DURATION := 5.0
const PAUSE_DURATION := 1.0
const PATROL_HALF_WIDTH := 100.0
const MAX_DOWNWARD_MOVES := 3

func _ready() -> void:
	_move()

func _move() -> void:
	var spawn_x := global_position.x

	var descent_tween := create_tween()
	descent_tween.set_trans(Tween.TRANS_LINEAR)
	descent_tween.tween_property(
		self,
		"global_position:y",
		global_position.y + spawn_descent_distance,
		DESCENT_DURATION,
	)
	await descent_tween.finished
	if !is_inside_tree():
		return

	var move_direction := -1.0 if randf() < 0.5 else 1.0
	var downward_move_count := 0

	while is_inside_tree():
		var move_duration := randf_range(MIN_MOVE_DURATION, MAX_MOVE_DURATION)
		var target_x := clampf(
			global_position.x + move_direction * HORIZONTAL_SPEED * move_duration,
			spawn_x - PATROL_HALF_WIDTH,
			spawn_x + PATROL_HALF_WIDTH,
		)
		var movement_distance := absf(target_x - global_position.x)
		var movement_duration := movement_distance / HORIZONTAL_SPEED

		if movement_distance > 0.0:
			var movement_tween := create_tween()
			movement_tween.set_trans(Tween.TRANS_LINEAR)
			movement_tween.tween_property(self, "global_position:x", target_x, movement_duration)
			await movement_tween.finished
			if !is_inside_tree():
				return

		var remaining_move_duration := move_duration - movement_duration
		if remaining_move_duration > 0.0:
			await get_tree().create_timer(remaining_move_duration, false).timeout
			if !is_inside_tree():
				return

		await get_tree().create_timer(PAUSE_DURATION, false).timeout
		if !is_inside_tree():
			return
		_shoot()

		await get_tree().create_timer(PAUSE_DURATION, false).timeout
		if !is_inside_tree():
			return

		if downward_move_count < MAX_DOWNWARD_MOVES:
			downward_move_count += 1
			var downward_tween := create_tween()
			downward_tween.set_trans(Tween.TRANS_LINEAR)
			downward_tween.tween_property(
				self,
				"global_position:y",
				global_position.y + DOWNWARD_STEP_DISTANCE,
				DOWNWARD_DURATION,
			)
			await downward_tween.finished
			if !is_inside_tree():
				return

			await get_tree().create_timer(PAUSE_DURATION, false).timeout
			if !is_inside_tree():
				return

		move_direction *= -1.0


func _shoot() -> void:
	if !is_inside_tree():
		return

	var projectile := PROJECTILE_SCENE.instantiate() as Node2D
	get_parent().add_child(projectile)
	projectile.global_position = projectile_spawn_point.global_position
