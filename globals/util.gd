@tool
extends Node

var normal_time: float = 0.0
var physics_time: float = 0.0
var time: float: # Stops counting when the browser is minimized
	get:
		return normal_time if normal_time >= physics_time else physics_time

var time2: float: # Keeps counting, even when the browser is minimized
	get:
		return Time.get_ticks_msec() / 1000.0

var is_paused := false

enum ControlTypes {
	KEYBOARD,
	CONTROLLER,
	TOUCH,
}

var current_control_type := ControlTypes.TOUCH if DisplayServer.is_touchscreen_available() else ControlTypes.KEYBOARD

var user_has_interacted := !OS.has_feature("web")

var uid_cache: Dictionary[String, int]

func _ready() -> void:
	# Taken from: https://github.com/godotengine/godot/issues/75617#issuecomment-2640078921
	var f := FileAccess.open("res://.godot/uid_cache.bin", FileAccess.READ)
	var count := f.get_32()
	for i in count:
		var id := f.get_64()
		var leng = f.get_32()
		var buffer := f.get_buffer(leng)
		uid_cache[buffer.get_string_from_ascii()] = id
	f.close()
	
func _process(delta: float) -> void:
	normal_time += delta

	if Engine.is_editor_hint():
		return
		
	if Input.is_action_just_pressed("any_keyboard_action"):
		current_control_type = ControlTypes.KEYBOARD
	elif Input.is_action_just_pressed("any_controller_action"):
		current_control_type = ControlTypes.CONTROLLER

func _physics_process(delta):
	physics_time += delta

func _input(event):
	if !user_has_interacted:
		if event is InputEventMouseButton \
		|| event is InputEventKey \
		|| event is InputEventScreenTouch \
		|| event is InputEventJoypadButton:
			user_has_interacted = true

	if Engine.is_editor_hint():
		return

	if event is InputEventScreenTouch || event is InputEventScreenDrag:
		current_control_type = ControlTypes.TOUCH

func recently(in_time: float, threshold: float) -> bool:
	return in_time + threshold >= time

func find_ancestor_in_group(node: Node, group: String) -> Node:
	var parent := node
	while parent != null:
		if parent.is_in_group(group):
			return parent
		parent = parent.get_parent()
	return null

func find_descendants_in_group(root: Node, group: String) -> Array[Node]:
	return root.get_tree().get_nodes_in_group(group)

func for_each_descendant(root: Node, action: Callable) -> void:
	for child in root.get_children():
		action.call(child)
		for_each_descendant(child, action)

func round_to_decimals(value: float, decimals: int) -> float:
	var factor = pow(10.0, decimals)
	return round(value * factor) / factor

func get_uid_from_scene(scene: Node) -> String:
	# This doesn't work in exported builds, so we are using a workaround: https://github.com/godotengine/godot/issues/75617#issuecomment-2640078921
	# return ResourceUID.id_to_text(ResourceLoader.get_resource_uid(scene.scene_file_path))
	return ResourceUID.id_to_text(uid_cache[scene.scene_file_path])

func range_inc(start: int, end_inclusive: int, step: int) -> Array[int]:
	var result: Array[int] = []
	var i := start
	while i <= end_inclusive:
		result.append(i)
		i += step
	return result

func rangef(start: float, end_exclusive: float, step: float) -> Array[float]:
	var result: Array[float] = []
	var i := start
	while i < end_exclusive:
		result.append(i)
		i += step
	return result

func rangef_inc(start: float, end_inclusive: float, step: float) -> Array[float]:
	var result: Array[float] = []
	var i := start
	while i <= end_inclusive:
		result.append(i)
		i += step
	return result

func is_exported_build() -> bool:
	return OS.has_feature("template")

func fatal_error(message: String) -> void:
	push_error(message)
	get_tree().quit(1)