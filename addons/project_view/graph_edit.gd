tool
extends GraphEdit

var graph_node = load("res://addons/project_view/graph_node.tscn")

var dirty = false

func _ready():
	snap_distance = 32
	$Dirty.hide()

func can_drop_data(position, data):
	return true

func drop_data(pos, data):
	
#	print("drop data ", data, " at ", pos)
	
	var node:GraphNode = graph_node.instance()
	
	#set exported variables before adding to tree
	var path:String = data.files[0]
	node.path = path
	var offset = scroll_offset + pos

	offset = (offset / snap_distance).floor() * snap_distance
	
	node.offset = offset
	
	add_child(node)
	node.owner = self

	node.init()
	
	dirty = true
	$Dirty.show()

func _on_BtnSave_pressed():
	
	save()
	
func save():
	
	if dirty:
	
		var packed_scene:PackedScene = PackedScene.new()
		
		packed_scene.pack(self)

		ResourceSaver.save("res://addons/project_view/project_view.tscn", packed_scene)
		
		print("project view saved")
		dirty = false
		$Dirty.hide()
	

func _on_GraphEdit_delete_nodes_request():
	print("delete node request??")

func _on_GraphEdit__end_node_move():
	
	dirty = true
	$Dirty.show()
	
