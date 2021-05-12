tool
extends GraphNode

const file_node_script = preload("res://addons/project_map/pm_file_node.gd")

var icon = NodePath("MarginContainer/HBox/Icon")

var drag_offset = null

var last_offset #used for undo move

export(String) var comment_text = "Comment \n\n Use the handle to resize"
export(Vector2) var comment_rect = Vector2(400, 200)

func _enter_tree():
	
	connect("resize_request", self, "_on_GraphNode_resize_request")
	get_node(icon).texture = get_icon("MultiLine", "EditorIcons")
	
	connect("mouse_entered", self, "_on_CommentNode_mouse_entered")
	connect("mouse_exited", self, "_on_CommentNode_mouse_exited")
	

func _ready():

	get_node("MarginContainer/HBox/TextBox").text = comment_text
	resize(comment_rect)
	pass

func init():

	pass

func resize(size):
	
	rect_min_size = size
	rect_size = size

	$MarginContainer.rect_min_size = Vector2(size.x - 60, size.y - 40)

func _on_GraphNode_resize_request(new_minsize:Vector2):

	resize(new_minsize)

	comment_rect = new_minsize
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


func _on_CommentNode_mouse_entered():
	
	resizable = true


func _on_CommentNode_mouse_exited():
	
	resizable = false


func _on_TextBox_mouse_entered():
	_on_CommentNode_mouse_entered()


func _on_TextBox_mouse_exited():
	_on_CommentNode_mouse_exited()


func _on_TextBox_text_changed():
	
	comment_text = get_node("MarginContainer/HBox/TextBox").text
	get_parent().dirty = true
