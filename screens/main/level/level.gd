class_name Level
extends Node2D

@onready var dirt_layer: TileMapLayer = %DirtLayer
@onready var left_dirt_layer: TileMapLayer = %LeftDirtLayer
@onready var right_dirt_layer: TileMapLayer = %RightDirtLayer
@onready var top_dirt_layer: TileMapLayer = %TopDirtLayer
@onready var bottom_dirt_layer: TileMapLayer = %BottomDirtLayer
@onready var gold_layer: TileMapLayer = %GoldLayer

const GOLD_SCENE: PackedScene = preload("uid://hscc2e85bn4m")

const TILE_SOURCE_ID := 1
const DIRT_TILE_ROW := 0
const GOLD_TILE_ROW := 1
const INDESTRUCTIBLE_TILE := Vector2i(1, 2)
const LEFT_DIRT_TILE := Vector2i(0, 3)
const BOTTOM_DIRT_TILE := Vector2i(1, 3)
const RIGHT_DIRT_TILE := Vector2i(2, 3)
const TOP_DIRT_TILE := Vector2i(3, 3)

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
	var gold_value := 0
	var is_revealed := false
	
class DepthProperties:
	var height: int
	var dirt_health: int
	var unbreakable_chance: float
	var empty_chance: float
	var gold_chance: float
	var gold_value: int

	func _init(in_height: int, in_dirt_health: int, in_unbreakable_chance: float, in_empty_chance: float, in_gold_chance: float, in_gold_value: int) -> void:
		self.height = in_height
		self.dirt_health = in_dirt_health
		self.unbreakable_chance = in_unbreakable_chance
		self.empty_chance = in_empty_chance
		self.gold_chance = in_gold_chance
		self.gold_value = in_gold_value

var depths: Array[DepthProperties] = [
	DepthProperties.new(10, 5, 0.01, 0.15, 0.18, 1),
	DepthProperties.new(10, 10, 0.05, 0.11, 0.12, 3),
	DepthProperties.new(10, 15, 0.05, 0.08, 0.10, 5),
	DepthProperties.new(10, 20, 0.07, 0.05, 0.07, 10),
	DepthProperties.new(10, 25, 0.08, 0.05, 0.07, 15),
	DepthProperties.new(100, 25, 0.08, 0.03, 0.07, 20),
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

	dirt_layer.clear()
	left_dirt_layer.clear()
	right_dirt_layer.clear()
	top_dirt_layer.clear()
	bottom_dirt_layer.clear()
	gold_layer.clear()

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

	var gold_count := roundi(float(eligible_coordinates.size()) * properties.gold_chance)
	for i in range(gold_count):
		level_data[eligible_coordinates.pop_back()].gold_value = properties.gold_value

func _reveal_cell(start_coordinate: Vector2i) -> void:
	var reveal_stack: Array[Vector2i] = [start_coordinate]
	var reveal_directions: Array[Vector2i] = [
		Vector2i.UP, Vector2i.LEFT, Vector2i.RIGHT, Vector2i.DOWN
	]
	var draw_directions: Array[Vector2i] = [
		Vector2i.UP + Vector2i.LEFT, Vector2i.UP + Vector2i.RIGHT,
		Vector2i.DOWN + Vector2i.LEFT, Vector2i.DOWN + Vector2i.RIGHT
	]

	while !reveal_stack.is_empty():
		var coordinate: Vector2i = reveal_stack.pop_back()
		var cell: Cell = level_data.get(coordinate)
		if cell == null || cell.is_revealed:
			continue

		cell.is_revealed = true
		_update_tile_map_cell(coordinate)

		if cell.type != CellType.EMPTY:
			continue
	
		for direction in reveal_directions:
			reveal_stack.append(coordinate + direction)
		for direction in draw_directions:
			_update_tile_map_cell(coordinate + direction)

func _update_tile_map_cell(coordinate: Vector2i) -> void:
	var cell: Cell = level_data.get(coordinate)
	if cell == null:
		_clear_tile_map_cell(coordinate)
		return

	if cell.type == CellType.EMPTY:
		dirt_layer.erase_cell(coordinate)
		gold_layer.erase_cell(coordinate)
		_update_empty_cell_edges(coordinate)
		return

	_clear_empty_cell_edges(coordinate)
	gold_layer.erase_cell(coordinate)

	if cell.type == CellType.UNBREAKABLE:
		dirt_layer.set_cell(coordinate, TILE_SOURCE_ID, INDESTRUCTIBLE_TILE)
		return

	var destruction_ratio := 0.0
	if cell.max_health > 0:
		destruction_ratio = clampf(1.0 - float(cell.health) / cell.max_health, 0.0, 1.0)
	var dirt_frame := mini(floori(destruction_ratio * 4.0), 3)
	dirt_layer.set_cell(coordinate, TILE_SOURCE_ID, Vector2i(dirt_frame, DIRT_TILE_ROW))

	if cell.gold_value > 0:
		gold_layer.set_cell(coordinate, TILE_SOURCE_ID, Vector2i(dirt_frame, GOLD_TILE_ROW))

func _clear_tile_map_cell(coordinate: Vector2i) -> void:
	dirt_layer.erase_cell(coordinate)
	gold_layer.erase_cell(coordinate)
	_clear_empty_cell_edges(coordinate)

func _clear_empty_cell_edges(coordinate: Vector2i) -> void:
	left_dirt_layer.erase_cell(coordinate)
	bottom_dirt_layer.erase_cell(coordinate)
	right_dirt_layer.erase_cell(coordinate)
	top_dirt_layer.erase_cell(coordinate)

func _update_empty_cell_edges(coordinate: Vector2i) -> void:
	_clear_empty_cell_edges(coordinate)

	if _is_dirt_cell(coordinate + Vector2i.LEFT):
		left_dirt_layer.set_cell(coordinate, TILE_SOURCE_ID, LEFT_DIRT_TILE)
	if _is_dirt_cell(coordinate + Vector2i.DOWN):
		bottom_dirt_layer.set_cell(coordinate, TILE_SOURCE_ID, BOTTOM_DIRT_TILE)
	if _is_dirt_cell(coordinate + Vector2i.RIGHT):
		right_dirt_layer.set_cell(coordinate, TILE_SOURCE_ID, RIGHT_DIRT_TILE)
	if _is_dirt_cell(coordinate + Vector2i.UP):
		top_dirt_layer.set_cell(coordinate, TILE_SOURCE_ID, TOP_DIRT_TILE)

func _is_dirt_cell(coordinate: Vector2i) -> bool:
	var cell: Cell = level_data.get(coordinate)
	return cell != null && cell.type == CellType.DIRT

func do_damage(coordinate: Vector2i, damage: int) -> bool:
	if damage <= 0:
		return false

	var cell: Cell = level_data.get(coordinate)
	if cell == null || cell.type != CellType.DIRT:
		return false

	cell.health = maxi(cell.health - damage, 0)
	var destroyed := cell.health == 0
	if destroyed:
		var gold_value := cell.gold_value
		cell.gold_value = 0
		cell.type = CellType.EMPTY
		cell.is_revealed = false
		_reveal_cell(coordinate)
		for direction in [Vector2i.UP, Vector2i.LEFT, Vector2i.RIGHT, Vector2i.DOWN]:
			_update_tile_map_cell(coordinate + direction)
		if gold_value > 0:
			_spawn_gold(coordinate, gold_value)
	else:
		_update_tile_map_cell(coordinate)

	return destroyed

func _spawn_gold(coordinate: Vector2i, value: int) -> void:
	var gold := GOLD_SCENE.instantiate() as Gold
	gold.value = value
	gold.position = Vector2(coordinate * TILE_SIZE) + Vector2.ONE * (TILE_SIZE / 2.0)
	add_child(gold)
