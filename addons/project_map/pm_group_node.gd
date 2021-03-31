tool
extends GraphNode

const file_node_script = preload("res://addons/project_map/pm_file_node.gd")

var icon = NodePath("MarginContainer/HBoxContainer/Icon")
var header = NodePath("MarginContainer/HBoxContainer/Title")

var drag_offset = null
var drag_nodes = []

func _enter_tree():
	
	connect("resize_request", self, "_on_GraphNode_resize_request")
	get_node(icon).texture = get_icon("WindowDialog", "EditorIcons")
	
	get_node(header).text = name

func _on_GraphNode_resize_request(new_minsize:Vector2):

	new_minsize = get_parent().snap(new_minsize)
	
	rect_min_size = new_minsize
	rect_size = new_minsize
	
	get_parent().dirty = true


func _on_Title_text_entered(new_text):
	
	#lose focus
	hide()
	show()
	name = new_text
	get_parent().dirty = true


#deselect when validating title
func _on_Title_focus_exited():
	
	name = get_node(header).text
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
			
			if get_global_rect().has_point(child.get_global_rect().position):
				nodes.append(child)
				
	return nodes

#drag the group node using the icon
func _on_Icon_gui_input(event):
	
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
	
		#drag start
		if event.pressed:
			drag_offset = get_local_mouse_position() #event.position
			selected = true
			drag_nodes = get_group_nodes()
		else:
			drag_offset = null
			
		accept_event()
	
	#dragging node
	elif drag_offset and event is InputEventMouseMotion:
		
		var offset_ori = offset
		offset += get_local_mouse_position() - drag_offset
		offset = get_parent().snap(offset)
		
		for node in drag_nodes:
			node.offset += offset - offset_ori

		get_parent().dirty = true
		accept_event()
