class_name Music
extends Node2D

@onready var music_player_normal: AudioStreamPlayer = %MusicPlayerNormal
@onready var music_player_wave: AudioStreamPlayer = %MusicPlayerWave

const NORMAL_MUSIC_FADE_OUT_SECONDS := 2.0
const WAVE_MUSIC_FADE_OUT_SECONDS := 1.0
const NORMAL_MUSIC_FADE_IN_SECONDS := 1.0
const MUSIC_SILENCE_DB := -80.0
const MUSIC_FULL_VOLUME_DB := 0.0

var _music_tween: Tween
var _music_transition_serial := 0
var _normal_music_resume_position := 0.0
var _normal_music_position_saved := false

func _ready() -> void:
	music_player_wave.stop()
	music_player_wave.volume_db = MUSIC_FULL_VOLUME_DB
	music_player_normal.volume_db = MUSIC_FULL_VOLUME_DB
	music_player_normal.stream_paused = false
	if !music_player_normal.playing:
		music_player_normal.play()

func start_wave() -> void:
	_cancel_music_transition()

	music_player_wave.stop()
	music_player_wave.volume_db = MUSIC_FULL_VOLUME_DB

	var transition_serial := _music_transition_serial
	_music_tween = create_tween()
	_music_tween.set_trans(Tween.TRANS_CUBIC) # This avoids the majority of fade time being spent in the almost-mute range of the volume db.
	_music_tween.set_ease(Tween.EASE_IN)
	_music_tween.tween_property(
		music_player_normal,
		"volume_db",
		MUSIC_SILENCE_DB,
		NORMAL_MUSIC_FADE_OUT_SECONDS,
	)
	_music_tween.tween_callback(func() -> void:
		if transition_serial != _music_transition_serial:
			return
		_pause_normal_music()
		music_player_wave.volume_db = MUSIC_FULL_VOLUME_DB
		music_player_wave.stream_paused = false
		music_player_wave.play()
	)

func start_normal() -> void:
	_cancel_music_transition()

	# Keep the normal track paused while the wave track fades out. This also
	# handles a wave that is cleared before the opening fade has completed.
	music_player_normal.volume_db = MUSIC_SILENCE_DB
	_pause_normal_music()

	var transition_serial := _music_transition_serial
	if !music_player_wave.playing:
		_resume_normal_music(transition_serial)
		return

	_music_tween = create_tween()
	_music_tween.set_trans(Tween.TRANS_CUBIC)
	_music_tween.set_ease(Tween.EASE_IN)
	_music_tween.tween_property(
		music_player_wave,
		"volume_db",
		MUSIC_SILENCE_DB,
		WAVE_MUSIC_FADE_OUT_SECONDS,
	)
	_music_tween.tween_callback(func() -> void:
		if transition_serial != _music_transition_serial:
			return
		_resume_normal_music(transition_serial)
	)

func _cancel_music_transition() -> void:
	_music_transition_serial += 1
	if _music_tween != null and _music_tween.is_valid():
		_music_tween.kill()
		_music_tween = null

func _resume_normal_music(transition_serial: int) -> void:
	if transition_serial != _music_transition_serial:
		return
	music_player_wave.stop()
	music_player_wave.volume_db = MUSIC_FULL_VOLUME_DB
	if _normal_music_position_saved:
		music_player_normal.play(_normal_music_resume_position)
		music_player_normal.stream_paused = false
		_normal_music_position_saved = false
	else:
		if !music_player_normal.playing:
			music_player_normal.play()
		music_player_normal.stream_paused = false

	_music_tween = create_tween()
	_music_tween.set_trans(Tween.TRANS_CUBIC)
	_music_tween.set_ease(Tween.EASE_OUT)
	_music_tween.tween_property(
		music_player_normal,
		"volume_db",
		MUSIC_FULL_VOLUME_DB,
		NORMAL_MUSIC_FADE_IN_SECONDS,
	)

func _pause_normal_music() -> void:
	if !music_player_normal.stream_paused:
		_normal_music_resume_position = music_player_normal.get_playback_position()
		_normal_music_position_saved = true
	music_player_normal.stream_paused = true
