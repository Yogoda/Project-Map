tool
extends "res://addons/project_map/pm_common_node.gd"

export(String) var group_name = "Group (click to edit)"

var icon = NodePath("MarginContainer/HBoxContainer/Icon")
var header = NodePath("MarginContainer/HBoxContainer/Title")

var drag_offset = null

var last_offset #used for undo move

#nodes inside the group
var children = []

func _enter_tree():
	
	connect("resize_request", self, "_on_GraphNode_resize_request")
	get_node(icon).texture = get_icon("WindowDialog", "EditorIcons")
	
	get_node(header).text = group_name
	

func init():
	pass

func set_children():
	
	children = get_group_nodes()

func _on_GraphNode_resize_request(new_minsize:Vector2):

	new_minsize = get_parent().snap(new_minsize)
	
	rect_min_size = new_minsize
	rect_size = new_minsize
	
	get_parent().dirty = true


func _on_Title_text_entered(new_text):
	
	#lose focus, will call focus_exited
	hide()
	show()


#deselect when validating title
func _on_Title_focus_exited():
	
	group_name = get_node(header).text
	get_node(header).deselect()
	get_parent().dirty = true


#select text when clicking on title
func _on_Title_gui_input(event):
	
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
	
		if event.pressed:
			accept_event()
			get_node(header).select_all()
		else:
			accept_event()
			
#returns all nodes inside a group panel
func get_group_nodes():
	
	var nodes = []
	
	for child in get_parent().get_children():
		
		if child is file_node_script:
			
			if is_node_child(child):
				nodes.append(child)

				
	return nodes
	
func is_node_child(node):
	
	return get_global_rect().has_point(node.get_global_rect().position)


#file node moved
func on_file_node_moved(node):
	
	if is_node_child(node):
		if not children.has(node):
			children.append(node)
	else:
		if children.has(node):
			children.erase(node)

##drag the group node using the icon
func _on_Icon_gui_input(event):
	
	var offset_ori = offset
	
	._on_Icon_gui_input(event)
	
	if dragging and event is InputEventMouseMotion:

		#move group nodes, don't if shift or alt is pressed
		if not (Input.is_key_pressed(KEY_ALT) or Input.is_key_pressed(KEY_SHIFT)):

			for node in children:
				node.offset += offset - offset_ori #offset - drag_start

	pass

