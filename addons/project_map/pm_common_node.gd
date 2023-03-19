extends GraphNode

class_name PMCommonNode

signal end_node_move

const file_node_script = preload("res://addons/project_map/pm_file_node.gd")

var snap: = true

var drag_start = null
var mouse_drag_start
var dragging: = false

#drag the group node using the icon
func _on_Icon_gui_input(event):
	
	#click node
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
	
		#drag start
		if event.pressed:
			
			selected = true
			drag_start = position_offset
			mouse_drag_start = get_local_mouse_position()
			dragging = true
			
			#reorder nodes so selected group is on top of other groups
			move_to_front()
			
			for node in get_parent().get_children():
				if node is file_node_script:
					node.raise()

		else:

			emit_signal("end_node_move") 
			dragging = false
			
		accept_event()
	
	#drag selected node
	elif dragging and event is InputEventMouseMotion:
		
		position_offset += get_local_mouse_position() - mouse_drag_start
		
		if snap:
			position_offset = get_parent().snap(position_offset)

		get_parent().dirty = true
		accept_event()
