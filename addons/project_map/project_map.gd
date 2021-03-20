tool
extends GraphEdit

var graph_node = load("res://addons/project_map/pm_file_node.tscn")

var dirty = false

func _ready():
	
	snap_distance = 32

	var interface = get_tree().get_meta("__editor_interface")
	
	var file_system_dock = interface.get_file_system_dock()
	
	file_system_dock.connect("file_removed", self, "_on_file_removed")
	file_system_dock.connect("files_moved", self, "_on_file_moved")


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


func drop_data(pos, data):

	var last_node_row = 0
	
	#set exported variables before adding to tree
	#to be able to save script data
	for file_path in data.files:
	
		var node:GraphNode = graph_node.instance()
	
		var path:String = file_path
		node.path = path
		var offset = scroll_offset + pos

		offset = (offset / snap_distance).floor() * snap_distance
		
		offset.y += last_node_row * snap_distance
		
		node.offset = offset
		
		add_child(node)
		node.owner = self

		node.init(path)
		
		last_node_row += node.get_row_count()
	
	dirty = true


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

