tool
extends GraphEdit

var graph_node = load("res://addons/project_map/pm_file_node.tscn")
var panel_node = load("res://addons/project_map/pm_group_node.tscn")

var dirty = false

var add_panel: = false

func _enter_tree():
	
	var hbox = get_zoom_hbox()
	
	var button = Button.new()
	button.text = "Add Group"
	hbox.add_child(button)
	button.connect("pressed", self, "_on_add_panel")
	
	var interface = get_tree().get_meta("__editor_interface")
	
	var file_system_dock = interface.get_file_system_dock()
	
	file_system_dock.connect("file_removed", self, "_on_file_removed")
	file_system_dock.connect("files_moved", self, "_on_file_moved")
	
	
func _on_add_panel():
	
	add_panel = true

func _ready():
	
	snap_distance = 32

func _on_file_removed(file_path):
	
	for child in get_children():
		
		if child is GraphNode and child.get("path") and child.path == file_path:
			child.queue_free()
			dirty = true


func _on_file_moved(old_file_path, new_file_path):
	
	for child in get_children():
		
		if child is GraphNode and child.get("path") and child.path == old_file_path:

			child.path = new_file_path
			child.init(new_file_path)
			dirty = true
			

func can_drop_data(position, data):

	if data.type == "files":
		return true
	else:
		return false

#add node to the graph, snap to grid
func add_node(scn_node, pos):
	
	var node:GraphNode = scn_node.instance()

	var offset = scroll_offset + pos

	if use_snap:
		offset = (offset / snap_distance).floor() * snap_distance
	
	node.offset = offset
	
	add_child(node)
	node.owner = self
	
	dirty = true
	
	return node

func drop_data(pos, data):

	var last_node_row = 0
	
	#set exported variables before adding to tree
	#to be able to save script data
	for file_path in data.files:
	
		var node:GraphNode = add_node(graph_node, pos)

		#this sets the script variable for saving, do not remove
		var path:String = file_path
		node.path = path
		node.init(path)

		#adjust offset when dropping multiple files
		node.offset.y += last_node_row * snap_distance
		last_node_row += node.get_row_count()


func _on_BtnSave_pressed():
	
	save()


func save():
	
	if dirty:
	
		var packed_scene:PackedScene = PackedScene.new()
		
		packed_scene.pack(self)

		ResourceSaver.save("res://addons/project_map/project_map_save.tscn", packed_scene)
		
		dirty = false


func _on_GraphEdit_delete_nodes_request():
	
	for child in get_children():
		if child is GraphNode:
			if child.selected:
				child.queue_free()


func _on_GraphEdit__end_node_move():
	
	dirty = true


func _on_ProjectMap_gui_input(event):
	
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		
		if add_panel:
			add_panel = false
		
			var node = add_node(panel_node, event.position)


#func _on_ProjectMap_node_selected(node):
#	var interface = get_tree().get_meta("__editor_interface")
#
#	print("inspect object ", node)
##	interface.inspect_object(node)
