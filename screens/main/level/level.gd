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
	var is_revealed := false
	
class DepthProperties:
	var height: int
	var dirt_health: int
	var unbreakable_chance: float
	var empty_chance: float

	func _init(in_height: int, in_dirt_health: int, in_unbreakable_chance: float, in_empty_chance: float) -> void:
		self.height = in_height
		self.dirt_health = in_dirt_health
		self.unbreakable_chance = in_unbreakable_chance
		self.empty_chance = in_empty_chance

var depths: Array[DepthProperties] = [
	DepthProperties.new(10, 5, 0.01, 0.15),
	DepthProperties.new(10, 10, 0.05, 0.11),
	DepthProperties.new(10, 15, 0.05, 0.08),
	DepthProperties.new(10, 20, 0.07, 0.05),
	DepthProperties.new(10, 25, 0.08, 0.05),
	DepthProperties.new(100, 25, 0.08, 0.03),
]

var level_data: Dictionary[Vector2i, Cell] = {}

func _ready() -> void:
	_generate_level()

func _generate_level() -> void:
	level_data.clear()
	if depths.is_empty():
		Util.fatal_error("Level: At least one depth definition is required.")
		return

	var depth_start := LEVEL_Y_MIN
	for depth in depths:
		if depth_start > LEVEL_Y_MAX:
			break

		var depth_end := mini(depth_start + depth.height - 1, LEVEL_Y_MAX)
		_generate_depth(depth_start, depth_end, depth)
		depth_start = depth_end + 1

	if depth_start <= LEVEL_Y_MAX:
		_generate_depth(depth_start, LEVEL_Y_MAX, depths.back())

	tile_map_layer.clear()

	for x in range(LEVEL_X_MIN, LEVEL_X_MAX + 1):
		_reveal_cell(Vector2i(x, 0))

func _generate_depth(start_y: int, end_y: int, properties: DepthProperties) -> void:
	var eligible_coordinates: Array[Vector2i] = []

	for x in range(LEVEL_X_MIN, LEVEL_X_MAX + 1):
		for y in range(start_y, end_y + 1):
			var coordinate := Vector2i(x, y)
			var cell := Cell.new()
			var is_boundary := x == LEVEL_X_MIN || x == LEVEL_X_MAX || y == LEVEL_Y_MAX
			cell.type = CellType.UNBREAKABLE if is_boundary else CellType.DIRT
			cell.health = properties.dirt_health
			cell.max_health = properties.dirt_health
			level_data[coordinate] = cell

			if y > LEVEL_Y_MIN && !is_boundary:
				eligible_coordinates.append(coordinate)

	eligible_coordinates.shuffle()

	var empty_count := roundi(float(eligible_coordinates.size()) * properties.empty_chance)
	var unbreakable_count := roundi(float(eligible_coordinates.size()) * properties.unbreakable_chance)

	for i in range(empty_count):
		level_data[eligible_coordinates.pop_back()].type = CellType.EMPTY

	for i in range(unbreakable_count):
		level_data[eligible_coordinates.pop_back()].type = CellType.UNBREAKABLE

func _reveal_cell(start_coordinate: Vector2i) -> void:
	var reveal_stack: Array[Vector2i] = [start_coordinate]

	while !reveal_stack.is_empty():
		var coordinate: Vector2i = reveal_stack.pop_back()
		var cell: Cell = level_data.get(coordinate)
		if cell == null || cell.is_revealed:
			continue

		cell.is_revealed = true
		_update_tile_map_cell(coordinate)

		if cell.type != CellType.EMPTY:
			continue

		reveal_stack.append(coordinate + Vector2i.LEFT)
		reveal_stack.append(coordinate + Vector2i.RIGHT)
		reveal_stack.append(coordinate + Vector2i.UP)
		reveal_stack.append(coordinate + Vector2i.DOWN)

func _update_tile_map_cell(coordinate: Vector2i) -> void:
	var cell: Cell = level_data.get(coordinate)
	if cell == null || cell.type == CellType.EMPTY:
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

func do_damage(coordinate: Vector2i, damage: int) -> bool:
	if damage <= 0:
		return false

	var cell: Cell = level_data.get(coordinate)
	if cell == null || cell.type != CellType.DIRT:
		return false

	cell.health = maxi(cell.health - damage, 0)
	var destroyed := cell.health == 0
	if destroyed:
		cell.type = CellType.EMPTY
		cell.is_revealed = false
		_reveal_cell(coordinate)
	else:
		_update_tile_map_cell(coordinate)

	return destroyed
