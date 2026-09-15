extends Node2D

func _process(_delta: float) -> void:
	if !GlobalState.is_shop_open:
		return
	
	if Input.is_action_just_pressed("b_button"):
		await get_tree().process_frame # Avoid the same button being processed by main too.
		GlobalState.is_shop_open = false
		hide()
