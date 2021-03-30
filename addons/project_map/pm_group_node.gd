tool
extends GraphNode

var icon = NodePath("MarginContainer/HBoxContainer/Icon")
var header = NodePath("MarginContainer/HBoxContainer/Title")

var dragging: = false
var drag_offset = null

func _enter_tree():
	
	connect("resize_request", self, "_on_GraphNode_resize_request")
#	get_node(icon).texture = get_icon("Groups", "EditorIcons")
	get_node(icon).texture = get_icon("WindowDialog", "EditorIcons")

func _unhandled_input(event):
	
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
	
		if event.pressed:
			dragging = true
			drag_offset = event.position
		else:
			dragging = false
			drag_offset = null
			
		print("clicky")
		accept_event()
			
	elif drag_offset and event is InputEventMouseMotion:
		
		offset = get_parent().scroll_offset + event.position
		
		print("movy")
		accept_event()

func _snap(pos:Vector2):

	var graph = get_parent()

	if graph.use_snap:
		
		var snap = graph.snap_distance
		
		pos = pos / snap
		pos = pos.floor() * snap
		
	return pos

func _on_GraphNode_resize_request(new_minsize:Vector2):

	new_minsize = _snap(new_minsize)
	
	rect_min_size = new_minsize
	rect_size = new_minsize
	
	get_parent().dirty = true


func _on_Title_text_entered(new_text):
	
	#lose focus
	hide()
	show()
	get_parent().dirty = true


func _on_Title_focus_entered():
#	yield(get_tree().create_timer(0.04), "timeout")
#	accept_event()
#	get_node(header).select_all()
	pass

func _on_Title_focus_exited():
	get_node(header).deselect()
	get_parent().dirty = true
	
	
func _on_Title_gui_input(event):
	
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
	
		if event.pressed:
			accept_event()
			get_node(header).select_all()
		else:
			accept_event()

func _on_Icon_gui_input(event):
	
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
	
		if event.pressed:
			dragging = true
			drag_offset = get_local_mouse_position() #event.position
			selected = true
		else:
			dragging = false
			drag_offset = null
			
		accept_event()
			
	elif drag_offset and event is InputEventMouseMotion:
		
		offset += get_local_mouse_position() - drag_offset
		
		offset = _snap(offset)

		get_parent().dirty = true
		accept_event()
