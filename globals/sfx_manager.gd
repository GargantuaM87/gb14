extends Node

var sfx_gold_1: AudioStream = preload("uid://btx8o6veuc8af")
var sfx_gold_2: AudioStream = preload("uid://c7bvjt4pjdgmi")
var sfx_gold_3: AudioStream = preload("uid://bvp3ublk17gct")
var sfx_gold_4: AudioStream = preload("uid://c8io1q8bf8iap")
var sfx_enemy_die_1: AudioStream = preload("uid://c4vomaw3et1gt")
var sfx_enemy_die_2: AudioStream = preload("uid://b2erjtut05qjt")
var sfx_enemy_die_3: AudioStream = preload("uid://b3sjt0vy8774w")
var sfx_laser_shoot_1: AudioStream = preload("uid://6ih28sm6ux5v")
var sfx_laser_shoot_2: AudioStream = preload("uid://rapdsbe5c63s")
var sfx_lose: AudioStream = preload("uid://c6aao2wlym4iq")
var sfx_move_1: AudioStream = preload("uid://cfrw3v25xr634")
var sfx_move_2: AudioStream = preload("uid://bgvp5vsaprla7")
var sfx_not_drill: AudioStream = preload("uid://bhsobg48pgh5y")
var sfx_rocket_shoot_1: AudioStream = preload("uid://dd5asa8mas8at")
var sfx_rocket_shoot_2: AudioStream = preload("uid://dcui620hqgxjv")
var sfx_shield_damage_1: AudioStream = preload("uid://dgghys3gkh28u")
var sfx_shield_damage_2: AudioStream = preload("uid://bovb02j8cil6a")
var sfx_shoot_1: AudioStream = preload("uid://cd03trynpjjbm")
var sfx_shoot_2: AudioStream = preload("uid://begfy1oki2xej")
var sfx_menu_click: AudioStream = preload("uid://h5qyn3biih2x")
var sfx_menu_hover: AudioStream = preload("uid://d2ti4bu66acxn")

const NOT_DRILL_COOLDOWN_SECONDS := 0.1
var _last_not_drill_time := -10.0
const DRILL_COOLDOWN_SECONDS := 0.05
var _last_drill_sfx_time := -10.0


func _linear_to_db(linear: float) -> float:
	if linear <= 0.0001:
		return -80.0
	return 20.0 * (log(linear) / log(10.0))


func play_sfx(clip: AudioStream, volume_linear: float = -1.0, pitch: float = 1.0) -> void:
	if clip == null:
		return

	var sound_player := AudioStreamPlayer.new()
	sound_player.stream = clip
	sound_player.volume_db = _linear_to_db(1.0 if volume_linear < 0.0 else volume_linear)
	sound_player.pitch_scale = pitch
	sound_player.bus = &"SFX"

	get_tree().current_scene.add_child(sound_player)
	sound_player.play()
	await sound_player.finished
	if is_instance_valid(sound_player):
		sound_player.queue_free()


func play_sfx_gold() -> void:
	var pitch := randf_range(0.8, 1.2)
	var clip := [sfx_gold_1, sfx_gold_2, sfx_gold_3, sfx_gold_4].pick_random() as AudioStream
	play_sfx(clip, -1.0, pitch)


func play_sfx_enemy_die() -> void:
	var pitch := randf_range(0.8, 1.2)
	var clip := [sfx_enemy_die_1, sfx_enemy_die_2, sfx_enemy_die_3].pick_random() as AudioStream
	play_sfx(clip, -1.0, pitch)


func play_sfx_laser_shoot() -> void:
	var pitch := randf_range(0.8, 1.2)
	var clip := [sfx_laser_shoot_1, sfx_laser_shoot_2].pick_random() as AudioStream
	play_sfx(clip, -1.0, pitch)


func play_sfx_lose() -> void:
	var pitch := randf_range(0.8, 1.2)
	play_sfx(sfx_lose, -1.0, pitch)


func play_sfx_move() -> void:
	var pitch := randf_range(0.8, 1.2)
	var clip := [sfx_move_1, sfx_move_2].pick_random() as AudioStream
	play_sfx(clip, -1.0, pitch)


func play_sfx_not_drill() -> void:
	var now := Util.time
	if now - _last_not_drill_time < NOT_DRILL_COOLDOWN_SECONDS:
		return
	_last_not_drill_time = now

	var pitch := randf_range(1.0, 1.4)
	play_sfx(sfx_not_drill, -1.0, pitch)


func play_sfx_drill() -> void:
	var now := Util.time
	if now - _last_drill_sfx_time < DRILL_COOLDOWN_SECONDS:
		return
	_last_drill_sfx_time = now

	var pitch := randf_range(0.5, 0.7)
	var clip := [sfx_shoot_1, sfx_shoot_2].pick_random() as AudioStream
	play_sfx(clip, -1.0, pitch)


func play_sfx_rocket_shoot() -> void:
	var pitch := randf_range(0.8, 1.2)
	var clip := [sfx_rocket_shoot_1, sfx_rocket_shoot_2].pick_random() as AudioStream
	play_sfx(clip, -1.0, pitch)


func play_sfx_shield_damage() -> void:
	var pitch := randf_range(0.8, 1.2)
	var clip := [sfx_shield_damage_1, sfx_shield_damage_2].pick_random() as AudioStream
	play_sfx(clip, -1.0, pitch)


func play_sfx_shoot() -> void:
	var pitch := randf_range(0.8, 1.2)
	var clip := [sfx_shoot_1, sfx_shoot_2].pick_random() as AudioStream
	play_sfx(clip, -1.0, pitch)
