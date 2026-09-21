extends Panel

@onready var uName = $UpgradeInfo/Name
@onready var uDesc = $UpgradeInfo/Desc
@onready var uCost = $UpgradeInfo/Cost

var upgrades: Array[PanelContainer]
var upgradePointer := 0


func _ready() -> void:
	for node in find_children("*", "", true):
		if node.is_in_group("upgrades"):
			upgrades.append(node)
	set_upgrade_pointer(0)
	visibility_changed.connect(_on_visibility_changed)

func _on_visibility_changed() -> void:
	if visible:
		set_upgrade_pointer(0)

func _process(_delta: float) -> void:
	if GlobalState.is_game_over || !visible:
		return

	queue_redraw()
	
	# For navigating the upgrade nodes
	if Input.is_action_just_pressed("down"):
		set_upgrade_pointer(upgradePointer + 1)
		SfxManager.play_sfx_menu_hover()
	elif Input.is_action_just_pressed("up"):
		set_upgrade_pointer(upgradePointer - 1)
		SfxManager.play_sfx_menu_hover()
	elif Input.is_action_just_pressed("right"):
		if move_horizontal(1):
			SfxManager.play_sfx_menu_hover()
	elif Input.is_action_just_pressed("left"):
		if move_horizontal(-1):
			SfxManager.play_sfx_menu_hover()
	
	if visible and Input.is_action_just_pressed("a_button"):
		var node = upgrades[upgradePointer]
		node.unlock_upgrade()
		node.set_selected(true)

# Change the upgrade pointer
func set_upgrade_pointer(value: int) -> void:
	handle_upgrade_pointer(false)
	upgradePointer = wrapi(value, 0, upgrades.size())
	handle_upgrade_pointer(true)

# Move to the icon in the same row of the adjacent column.
func move_horizontal(direction: int) -> bool:
	var current_node := upgrades[upgradePointer]
	var current_column := current_node.get_parent()
	var row := current_column.get_children().find(current_node)
	var columns := current_column.get_parent().get_children()
	var column_index := columns.find(current_column)
	var target_column_index := column_index + direction

	if row < 0 || target_column_index < 0 || target_column_index >= columns.size():
		return false

	var target_column = columns[target_column_index]
	if row >= target_column.get_child_count():
		return false

	var target_node = target_column.get_child(row)
	var target_pointer := upgrades.find(target_node)
	if target_pointer == -1:
		return false

	set_upgrade_pointer(target_pointer)
	return true

# Update the nodes that are accessed by the upgrade pointer
func handle_upgrade_pointer(enabled: bool) -> void:
	var node = upgrades[upgradePointer]
	
	if !node:
		return
		
	uName.text = node.upgResource.upgradeName
	uDesc.text = node.upgResource.upgradeDesc
	uCost.text = "Cost: " + str(node.upgResource.upgradeCost)
	
	node.set_selected(enabled)

# Draw lines between upgrade nodes
func _draw() -> void:
	for node in get_tree().get_nodes_in_group("upgrades"):
		for resource in node.upgResource.unlockUpgs:
			var targetNode = get_node_with_resource(resource)
			
			if targetNode == null:
				continue
			
			var sourcePos = (node.global_position) + (node.get_center())
			var targetPos = (targetNode.global_position) + (targetNode.get_center())
			var color = Color.WHITE if node.upgResource.isUnlocked else Color.BLACK
			
			targetNode.set_parent(node.upgResource)
			
			# draw_line(sourcePos, targetPos, color, 2.0)
			
# Return node with the given resource
func get_node_with_resource(resource):
	for node in get_tree().get_nodes_in_group("upgrades"):
		if node.upgResource == resource:
			return node
