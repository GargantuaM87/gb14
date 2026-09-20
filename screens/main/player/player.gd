class_name Player
extends CharacterBody2D

@onready var player_sprite: AnimatedSprite2D = %PlayerSprite

const PLAYER_WIDTH := 10
const PLAYER_HEIGHT := 10
var tile_position: Vector2 = Vector2(0, -1)
@export var level: Level

var drill_damage := 1
var drills_per_second := 4.0
var last_drill_time := -10.0
var facing_direction := Vector2i.DOWN

const TILE_MOVEMENT_DELAY := 0.2
var last_move_time := -10.0

func _ready() -> void:
	if !level:
		Util.fatal_error("Player: Level is not set.")
	
	GlobalState.player = self
	_update_self_position()
	_set_player_animation(false)
	

func _update_self_position() -> void:
	@warning_ignore('integer_division')
	var new_position := tile_position * Level.TILE_SIZE + level.global_position + Vector2((Level.TILE_SIZE - PLAYER_WIDTH) / 2, (Level.TILE_SIZE - PLAYER_HEIGHT) / 2)
	if global_position != new_position:
		global_position = new_position
		last_move_time = Util.time

func _physics_process(_delta: float) -> void:
	if GlobalState.is_shop_open:
		_set_player_animation(false)
		return
	
	# If you repeatedly tap a direction, the player will move in that direction
	# even if TILE_MOVEMENT_DELAY has not passed since last movement.
	var direction := _get_just_pressed_movement_direction()
	var is_just_pressed := direction != Vector2i.ZERO
	if direction == Vector2i.ZERO:
		direction = _get_movement_direction()
	if direction == Vector2i.ZERO:
		_set_player_animation(false)
		return

	facing_direction = direction
	var target_tile := Vector2i(tile_position) + direction
	target_tile.x = clampi(target_tile.x, Level.LEVEL_X_MIN, Level.LEVEL_X_MAX)
	target_tile.y = clampi(target_tile.y, Level.LEVEL_Y_MIN - 1, Level.LEVEL_Y_MAX)

	var cell: Level.Cell = level.level_data.get(target_tile)
	_set_player_animation(cell != null && cell.type == Level.CellType.DIRT)

	if !is_just_pressed && Util.time - last_move_time < TILE_MOVEMENT_DELAY:
		return

	if cell == null || cell.type == Level.CellType.EMPTY:
		tile_position = Vector2(target_tile)
		_update_self_position()
		return

	if cell.type != Level.CellType.DIRT:
		return
	
	assert(drills_per_second > 0.0 && drill_damage > 0)

	var drill_interval := 1.0 / drills_per_second
	if Util.time - last_drill_time < drill_interval:
		return

	last_drill_time = Util.time
	if level.do_damage(target_tile, drill_damage):
		last_move_time = Util.time # This ensures that we don't move into the tile we just destroyed until TILE_MOVEMENT_DELAY has passed.

func _set_player_animation(is_drilling: bool) -> void:
	var direction_name := "down"
	match facing_direction:
		Vector2i.LEFT:
			direction_name = "left"
		Vector2i.RIGHT:
			direction_name = "right"
		Vector2i.UP:
			direction_name = "up"

	var animation_name := StringName(("drill_" if is_drilling else "idle_") + direction_name)
	if player_sprite.animation != animation_name || !player_sprite.is_playing():
		player_sprite.play(animation_name)

func _get_just_pressed_movement_direction() -> Vector2i:
	var input_direction := Vector2.ZERO
	input_direction.x = float(Input.is_action_just_pressed("right")) - float(Input.is_action_just_pressed("left"))
	input_direction.y = float(Input.is_action_just_pressed("down")) - float(Input.is_action_just_pressed("up"))

	if absf(input_direction.x) > absf(input_direction.y):
		return Vector2i.RIGHT if input_direction.x > 0.0 else Vector2i.LEFT
	if absf(input_direction.y) > absf(input_direction.x):
		return Vector2i.DOWN if input_direction.y > 0.0 else Vector2i.UP
	return Vector2i.ZERO

func _get_movement_direction() -> Vector2i:
	var input_direction := Input.get_vector("left", "right", "up", "down")

	if absf(input_direction.x) > absf(input_direction.y):
		return Vector2i.RIGHT if input_direction.x > 0.0 else Vector2i.LEFT
	if absf(input_direction.y) > absf(input_direction.x):
		return Vector2i.DOWN if input_direction.y > 0.0 else Vector2i.UP
	return Vector2i.ZERO
