extends Node2D

@onready var current_screen: Node2D = %CurrentScreen

const INTRO_SCENE: PackedScene = preload("uid://c5qi0jrkvsu0c")
const MAIN_SCENE: PackedScene = preload("uid://cv5a6vc6okik7")

func _ready() -> void:
	_show_intro()

func _show_intro() -> void:
	var intro := INTRO_SCENE.instantiate() as IntroScreen
	intro.continue_requested.connect(_show_main)
	_set_current_screen(intro)

func _show_main() -> void:
	var main := MAIN_SCENE.instantiate() as MainScreen
	main.restart_requested.connect(_show_main)
	_set_current_screen(main)

func _set_current_screen(screen: Node2D) -> void:
	for child in current_screen.get_children():
		current_screen.remove_child(child)
		child.queue_free()

	current_screen.add_child(screen)
