tool
extends GraphEdit

var graph_node = load("res://addons/project_map/pm_file_node.tscn")

var dirty = false

func _ready():
	
	snap_distance = 32


func can_drop_data(position, data):
	return true


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

		ResourceSaver.save("res://addons/project_map/project_map.tscn", packed_scene)
		
		dirty = false


func _on_GraphEdit_delete_nodes_request():
	
	for child in get_children():
		if child is GraphNode:
			if child.selected:
				child.queue_free()


func _on_GraphEdit__end_node_move():
	
	dirty = true

