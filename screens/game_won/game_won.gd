class_name GameWon
extends Node2D

signal continue_requested

@onready var play_again_label: Label = %PlayAgainLabel

var _can_restart := false
var _restart_sequence := 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	play_again_label.modulate.a = 0.0

func begin_restart_sequence() -> void:
	_restart_sequence += 1
	var sequence := _restart_sequence
	_can_restart = false
	play_again_label.modulate.a = 0.0

	await get_tree().create_timer(2.0).timeout
	if sequence != _restart_sequence || !is_inside_tree():
		return

	var fade_tween := create_tween()
	fade_tween.tween_property(play_again_label, "modulate:a", 1.0, 1.0)
	await fade_tween.finished
	if sequence == _restart_sequence && is_inside_tree():
		_can_restart = true

func _process(_delta: float) -> void:
	if _can_restart && Input.is_action_just_pressed("a_button"):
		_can_restart = false
		continue_requested.emit()
