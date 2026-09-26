class_name IntroScreen
extends Node2D

signal continue_requested

var _transitioning := false

func _ready() -> void:
	var labels: Array[Label] = []
	for child in get_children():
		if child is Label:
			var label := child as Label
			label.modulate.a = 0.0
			labels.append(label)

	_fade_labels(labels)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("a_button"):
		_load_main_scene()

func _fade_labels(labels: Array[Label]) -> void:
	for label_index in labels.size():
		if _transitioning:
			return

		var fade_tween := create_tween()
		fade_tween.tween_property(labels[label_index], "modulate:a", 1.0, 1.0)
		await fade_tween.finished

		if _transitioning || !is_inside_tree():
			return
		if label_index < labels.size() - 1:
			await get_tree().create_timer(1.0).timeout

func _load_main_scene() -> void:
	if _transitioning:
		return

	_transitioning = true
	set_process(false)
	continue_requested.emit()
