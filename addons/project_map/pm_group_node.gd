tool
extends GraphNode

var icon = NodePath("MarginContainer/HBoxContainer/TextureRect")
var header = NodePath("MarginContainer/HBoxContainer/Title")

func _enter_tree():
	
	connect("resize_request", self, "_on_GraphNode_resize_request")
#	get_node(icon).texture = get_icon("Groups", "EditorIcons")
	get_node(icon).texture = get_icon("WindowDialog", "EditorIcons")


func _on_GraphNode_resize_request(new_minsize:Vector2):

	var graph = get_parent()

	if graph.use_snap:
		
		var snap = graph.snap_distance
		
		new_minsize = new_minsize / snap
		new_minsize = new_minsize.floor() * snap
	
	rect_min_size = new_minsize
	rect_size = new_minsize
	
	get_parent().dirty = true


func _on_Title_text_entered(new_text):
	
	#lose focus
	hide()
	show()
	get_parent().dirty = true
	
#	var focus_next:NodePath = get_node(header).focus_next
#
#	print("grab focus ", focus_next)
#	get_node(focus_next).grab_focus()
#


func _on_Title_focus_entered():
	get_node(header).select_all()


func _on_Title_focus_exited():
	get_node(header).deselect()
	get_parent().dirty = true

func _on_Title_gui_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		get_node(header).select_all()
