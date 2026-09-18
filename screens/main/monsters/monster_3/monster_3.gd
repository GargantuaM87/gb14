extends Monster

@onready var level_1: Node2D = %Level1
@onready var level_2: Node2D = %Level2
@onready var level_3: Node2D = %Level3
@onready var level_4: Node2D = %Level4
@onready var levels: Array[Node2D] = [level_1, level_2, level_3, level_4]

const SPEED := 8.0
const MAX_DAMAGE := 10
const SWAY_AMPLITUDE := 2.0
const SWAY_CYCLE_DURATION := 2.0

var _spawn_position := Vector2.ZERO
var _elapsed_time := 0.0

func _ready() -> void:
	_update_level_visual()

	_spawn_position = position

func _process(delta: float) -> void:
	_elapsed_time += delta

	var centerline_position := _spawn_position + Vector2.DOWN * SPEED * _elapsed_time
	var sway := sin(TAU * _elapsed_time / SWAY_CYCLE_DURATION) * SWAY_AMPLITUDE
	position = centerline_position + Vector2.RIGHT * sway

func take_damage(damage: int) -> void:
	if is_queued_for_deletion():
		return

	super.take_damage(damage)
	if !is_queued_for_deletion():
		_update_level_visual()

func _update_level_visual() -> void:
	assert(max_hp > 0)
	var health_ratio := 0.0
	health_ratio = clampf(float(hp) / float(max_hp), 0.0, 1.0)
	var active_level_index := clampi(ceili(health_ratio * levels.size()) - 1, 0, levels.size() - 1)
	for i in range(levels.size()):
		levels[i].visible = i == active_level_index

func _on_area_2d_area_entered(_area: Area2D) -> void:
	if is_queued_for_deletion():
		return

	var damage := clampi(roundi(float(MAX_DAMAGE) * float(hp) / float(max_hp)), 1, MAX_DAMAGE)
	queue_free()

	EventBus.trigger_monster_hit_shield(damage)
