extends Panel

@onready var uName = $UpgradeInfo/Name
@onready var uDesc = $UpgradeInfo/Desc
@onready var uCost = $UpgradeInfo/Cost

var upgrades : Array[PanelContainer]
var upgradePointer := 0



func _ready() -> void:
	for node in find_children("*", "", true):
		if node.is_in_group("upgrades"):
			upgrades.append(node)
	set_upgrade_pointer(0)

func _process(_delta: float) -> void:
	if !visible:
		return

	queue_redraw()
	
	# For navigating the upgrade nodes
	if Input.is_action_just_pressed("down"):
		set_upgrade_pointer(upgradePointer + 1)
		SfxManager.play_sfx_menu_hover()
	elif Input.is_action_just_pressed("up"):
		set_upgrade_pointer(upgradePointer - 1)
		SfxManager.play_sfx_menu_hover()
	# Implement those later
	elif Input.is_action_just_pressed("right"):
		pass
	elif Input.is_action_just_pressed("left"):
		pass
	
	if visible and Input.is_action_just_pressed("a_button"):
		upgrades[upgradePointer].unlock_upgrade()

# Change the upgrade pointer
func set_upgrade_pointer(value : int) -> void:
	handle_upgrade_pointer(false)
	upgradePointer = wrapi(value, 0, upgrades.size())
	handle_upgrade_pointer(true)

# Update the nodes that are accessed by the upgrade pointer
func handle_upgrade_pointer(enabled : bool) -> void:
	var node = upgrades[upgradePointer]
	
	if !node:
		return
		
	uName.text = node.upgResource.upgradeName
	uDesc.text = node.upgResource.upgradeDesc
	uCost.text = "Cost: " + str(node.upgResource.upgradeCost)
	
	if node.upgResource.isUnlocked:
		return
	
	var color = Color.WHITE if enabled else Color.BLACK
	
	var styleBox : StyleBoxFlat = node.get_theme_stylebox("panel").duplicate()
	styleBox.border_color = color
		
	node.add_theme_stylebox_override("panel", styleBox)

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
