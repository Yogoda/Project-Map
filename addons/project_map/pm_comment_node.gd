tool
extends GraphNode

const file_node_script = preload("res://addons/project_map/pm_file_node.gd")

var icon = NodePath("MarginContainer/HBox/Icon")

var drag_offset = null

var last_offset #used for undo move

#onready var text_edit = get_node("TextEdit")

func _enter_tree():
	
	connect("resize_request", self, "_on_GraphNode_resize_request")
	get_node(icon).texture = get_icon("MultiLine", "EditorIcons")

func _ready():

	_set_text_height()
	pass

func init():

	pass


func _on_GraphNode_resize_request(new_minsize:Vector2):

#	new_minsize = get_parent().snap(new_minsize)
	
	rect_min_size = new_minsize
	rect_size = new_minsize
#
	$MarginContainer.rect_min_size = Vector2(new_minsize.x - 60, new_minsize.y - 40)
#	$Panel.rect_min_size = new_minsize
#	$Panel.rect_size = new_minsize


	get_parent().dirty = true

#drag the group node using the icon
func _on_Icon_gui_input(event):
	
	#click node
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
	
		#drag start
		if event.pressed:
			
			selected = true
			drag_offset = get_local_mouse_position() #event.position
			
		#reorder nodes so selected group is on top of other groups
			raise()
			
			for node in get_parent().get_children():
				if node is file_node_script:
					node.raise()

		else:
			drag_offset = null
			
		accept_event()
	
	#drag selected node
	elif drag_offset and event is InputEventMouseMotion:
		
		var offset_ori = offset
		offset += get_local_mouse_position() - drag_offset
#		offset = get_parent().snap(offset)

		get_parent().dirty = true
		accept_event()

func _set_text_height():
	
#	var line_count = text_edit.text.count('\n') + 1
	
#	text_edit.rect_min_size.y = line_count * 30 - (line_count-1) * 8

	pass

func _on_TextEdit_text_changed():
	_set_text_height()


func _on_CommentNode_mouse_entered():
	
	resizable = true


func _on_CommentNode_mouse_exited():
	
	resizable = false


func _on_TextBox_mouse_entered():
	_on_CommentNode_mouse_entered()


func _on_TextBox_mouse_exited():
	_on_CommentNode_mouse_exited()
