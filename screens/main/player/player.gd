class_name Player
extends CharacterBody2D

const PLAYER_WIDTH := 10
const PLAYER_HEIGHT := 10
const SPEED := 100.0
var tile_position: Vector2 = Vector2(0, -1)
@export var level: Level

const TILE_MOVEMENT_DELAY := 0.2
var last_move_time := 0.0

func _ready() -> void:
	if not level:
		push_error("Player: Level is not set.")

	_update_self_position()
	

func _update_self_position() -> void:
	@warning_ignore('integer_division')
	var new_position := tile_position * Level.TILE_SIZE + level.global_position + Vector2((Level.TILE_SIZE - PLAYER_WIDTH) / 2, (Level.TILE_SIZE - PLAYER_HEIGHT) / 2)
	if global_position != new_position:
		global_position = new_position
		last_move_time = Util.time

func _physics_process(_delta: float) -> void:
	if GlobalState.is_shop_open:
		return
	
	if Util.time - last_move_time < TILE_MOVEMENT_DELAY:
		return

	var direction := Input.get_vector("left", "right", "up", "down")

	if absf(direction.x) > absf(direction.y):
		if direction.x > 0:
			tile_position.x += 1
		else:
			tile_position.x -= 1
	elif absf(direction.y) > absf(direction.x):
		if direction.y > 0:
			tile_position.y += 1
		else:
			tile_position.y -= 1

	tile_position.x = clamp(tile_position.x, Level.LEVEL_X_MIN, Level.LEVEL_X_MAX)
	tile_position.y = clamp(tile_position.y, Level.LEVEL_Y_MIN - 1, Level.LEVEL_Y_MAX)
	_update_self_position()
