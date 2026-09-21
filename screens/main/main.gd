extends Node2D

class MonsterType:
	var scene: PackedScene
	var first_wave: int

	func _init(in_scene: PackedScene, in_first_wave: int) -> void:
		scene = in_scene
		first_wave = in_first_wave

@onready var monsters: Node2D = %Monsters
@onready var player: Player = %Player
@onready var ground: Node2D = %Ground
@onready var camera: Camera2D = %Camera
@onready var monster_spawn_position: Marker2D = %MonsterSpawnPosition
@onready var shop: Node2D = %Shop
@onready var shop_notification: Node2D = %ShopNotification
@onready var music: Music = %Music

const WAVE_LENGTH_SECONDS := 60
const BASE_MONSTER_COUNT := 3
const SPAWN_X_MIN := -80.0
const SPAWN_X_MAX := 80.0
var monster_types: Array[MonsterType] = [
	MonsterType.new(preload("uid://bapq6tesgu84k"), 1),
	MonsterType.new(preload("uid://tprv2crptn14"), 2),
	MonsterType.new(preload("uid://dxmfm0d5pmloh"), 4),
]

var current_wave := 0
var _wave_monsters_remaining := 0
var _wave_in_progress := false

func _ready() -> void:
	current_wave = 0
	GlobalState.seconds_until_next_wave = WAVE_LENGTH_SECONDS

func _process(_delta: float) -> void:
	if is_above_ground():
		set_look_up(true)
		if !GlobalState.is_shop_open:
			shop_notification.show()

			if Input.is_action_just_pressed("b_button"):
				await get_tree().process_frame # Avoid the same button being processed by the shop too.
				GlobalState.is_shop_open = true
				shop.show()
				SfxManager.play_sfx_menu_click()
				shop_notification.hide()
	else:
		set_look_up(false)
		shop_notification.hide()

var offset_tween: Tween
var is_looking_up := false
func set_look_up(enabled: bool) -> void:
	if is_looking_up == enabled:
		return
	is_looking_up = enabled

	if offset_tween:
		offset_tween.kill()

	var target_offset := Vector2(0, -50) if enabled else Vector2.ZERO

	offset_tween = create_tween()
	offset_tween.set_trans(Tween.TRANS_CUBIC)
	offset_tween.set_ease(Tween.EASE_OUT)
	offset_tween.tween_property(camera, "offset", target_offset, 1.0)

func _on_wave_countdown_timer_timeout() -> void:
	if _wave_in_progress:
		return

	# Let the timer stay at 0:00 for a second before starting the next countdown.
	if GlobalState.seconds_until_next_wave <= 0:
		spawn_monster_wave()
	elif GlobalState.seconds_until_next_wave > 0:
		GlobalState.seconds_until_next_wave -= 1

func spawn_monster_wave() -> void:
	current_wave += 1
	_wave_in_progress = true
	GlobalState.seconds_until_next_wave = 0
	music.start_wave()

	var unlocked_monster_scenes: Array[PackedScene] = []
	for monster_type: MonsterType in monster_types:
		if current_wave >= monster_type.first_wave:
			unlocked_monster_scenes.append(monster_type.scene)

	var monster_count := BASE_MONSTER_COUNT + current_wave - 1
	_wave_monsters_remaining = monster_count
	var wave_monster_scenes: Array[PackedScene] = []

	# Guarantee that every unlocked monster type appears in the wave.
	for monster_scene in unlocked_monster_scenes:
		wave_monster_scenes.append(monster_scene)

	while wave_monster_scenes.size() < monster_count:
		wave_monster_scenes.append(unlocked_monster_scenes.pick_random() as PackedScene)
	wave_monster_scenes.shuffle()

	# Spread out the monsters horizontally
	var spawn_x_offsets: Array[float] = []
	for i in range(monster_count):
		var interpolation := 0.0 if monster_count == 1 else float(i) / (monster_count - 1.0)
		spawn_x_offsets.append(lerpf(SPAWN_X_MIN, SPAWN_X_MAX, interpolation))
	spawn_x_offsets.shuffle()

	for i in range(monster_count):
		var monster := wave_monster_scenes[i].instantiate() as Monster
		monster.initialize_for_wave(current_wave)
		monster.global_position.y = monster_spawn_position.global_position.y
		monster.global_position.x = monster_spawn_position.global_position.x + spawn_x_offsets[i] + randf_range(-2.0, 2.0)
		monster.tree_exited.connect(_on_wave_monster_tree_exited)
		monsters.add_child(monster)

func _on_wave_monster_tree_exited() -> void:
	if !_wave_in_progress:
		return

	_wave_monsters_remaining -= 1
	if _wave_monsters_remaining <= 0:
		_finish_wave()

func _finish_wave() -> void:
	_wave_in_progress = false
	_wave_monsters_remaining = 0
	GlobalState.seconds_until_next_wave = WAVE_LENGTH_SECONDS
	music.start_normal()

func is_above_ground() -> bool:
	return player.global_position.y < ground.global_position.y
