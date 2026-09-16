class_name Level
extends Node2D

@onready var tile_map_layer: TileMapLayer = %TileMapLayer

const LEVEL_WIDTH := 10 * 3
const LEVEL_HEIGHT := 8 * 10
const TILE_SIZE := 16 # px
@warning_ignore('integer_division')
const LEVEL_X_MIN := -LEVEL_WIDTH / 2
@warning_ignore('integer_division')
const LEVEL_X_MAX := LEVEL_WIDTH / 2
const LEVEL_Y_MIN := 0
const LEVEL_Y_MAX := LEVEL_HEIGHT - 1

enum CellType {
    EMPTY,
    DIRT,
    UNBREAKABLE,
}

class Cell:
	var type: CellType
	var health: int
	var max_health: int
	
var level_data: Dictionary[Vector2i, Cell] = {}

func _ready() -> void:
	_generate_level()

func _generate_level() -> void:
	level_data.clear()
	var eligible_coordinates: Array[Vector2i] = []

	for x in range(LEVEL_X_MIN, LEVEL_X_MAX + 1):
		for y in range(LEVEL_Y_MIN, LEVEL_Y_MAX + 1):
			var coordinate := Vector2i(x, y)
			var max_health := 5 + floori(float(y) / 10.0) * 5
			var cell := Cell.new()
			var is_boundary := x == LEVEL_X_MIN or x == LEVEL_X_MAX or y == LEVEL_Y_MAX
			cell.type = CellType.UNBREAKABLE if is_boundary else CellType.DIRT
			cell.health = max_health
			cell.max_health = max_health
			level_data[coordinate] = cell

			if y > LEVEL_Y_MIN and not is_boundary:
				eligible_coordinates.append(coordinate)

	eligible_coordinates.shuffle()

	var empty_count := roundi(float(eligible_coordinates.size()) * 0.10)
	var unbreakable_count := roundi(float(eligible_coordinates.size()) * 0.05)

	for i in range(empty_count):
		level_data[eligible_coordinates.pop_back()].type = CellType.EMPTY

	for i in range(unbreakable_count):
		level_data[eligible_coordinates.pop_back()].type = CellType.UNBREAKABLE

	tile_map_layer.clear()

	for x in range(LEVEL_X_MIN, LEVEL_X_MAX + 1):
		_update_tile_map_cell(Vector2i(x, 0))

func _update_tile_map_cell(coordinate: Vector2i) -> void:
	var cell: Cell = level_data.get(coordinate)
	if cell == null or cell.type == CellType.EMPTY:
		tile_map_layer.erase_cell(coordinate)
		return

	if cell.type == CellType.UNBREAKABLE:
		tile_map_layer.set_cell(coordinate, 0, Vector2i(0, 1))
		return

	var health_ratio := 0.0
	if cell.max_health > 0:
		health_ratio = clampf(float(cell.health) / cell.max_health, 0.0, 1.0)
	var dirt_frame := roundi((1.0 - health_ratio) * 5.0)
	tile_map_layer.set_cell(coordinate, 0, Vector2i(dirt_frame, 0))
