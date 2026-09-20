extends Node2D

@onready var rightArrow : TextureRect = $SelectionPanel/RightArrow
@onready var leftArrow : TextureRect = $SelectionPanel/LeftArrow
@onready var selectionPanel : Panel = $SelectionPanel

@export var shops : Array[Panel] = []
@export var upgrades : Dictionary[String, Panel] 

enum ShopState { SELECT, IN_SELECTION }

var selectionCounter = 0
var currentState : ShopState = ShopState.SELECT

func _process(_delta: float) -> void:
	if !GlobalState.is_shop_open:
		return
	
	if Input.is_action_just_pressed("b_button") and currentState == ShopState.SELECT:
		await get_tree().process_frame # Avoid the same button being processed by main too.
		GlobalState.is_shop_open = false
		hide()
	# When the player is selecting a shop to enter
	if currentState == ShopState.SELECT:
		scroll_shop()
	
	# While the player is inside a shop
	if currentState == ShopState.IN_SELECTION:
		handle_shop()
			
	
func scroll_shop() -> void:
	if Input.is_action_just_pressed("right"):
		arrow_tween(rightArrow, 5, 0.25)
		shops[selectionCounter].hide()
		selectionCounter = wrapi(selectionCounter + 1, 0, shops.size())
		shops[selectionCounter].show()
	elif Input.is_action_just_pressed("left"):
		arrow_tween(leftArrow, -5, 0.25)
		shops[selectionCounter].hide()
		selectionCounter = wrapi(selectionCounter - 1, 0, shops.size())
		shops[selectionCounter].show()
	
	if Input.is_action_just_pressed("a_button"):
		enter_shop(shops[selectionCounter].name)
		#get_viewport().set_input_as_handled()

func enter_shop(name : String) -> void:
	selectionPanel.hide()
	upgrades[name.to_lower()].show()
	currentState = ShopState.IN_SELECTION
	
func handle_shop() -> void:
	if Input.is_action_just_pressed("b_button"):
		await get_tree().process_frame
		upgrades[shops[selectionCounter].name.to_lower()].hide()
		selectionPanel.show()
		currentState = ShopState.SELECT
	
	
# So far, the player can overtween the arrows, going to fix that later
func arrow_tween(object, amount : int, duration : float) -> void:
	var tween = get_tree().create_tween()
	var origPos = object.position
	tween.tween_property(object, "position", Vector2(object.position.x + amount, object.position.y), duration).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(object, "position", Vector2(origPos), duration).set_trans(Tween.TRANS_LINEAR)
	
