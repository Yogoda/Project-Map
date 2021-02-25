tool
extends GraphEdit

var graph_node = load("res://addons/project_view/graph_node.tscn")

func _ready():
	snap_distance = 32

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

func _on_BtnSave_pressed():
	
	var packed_scene:PackedScene = PackedScene.new()
	
	packed_scene.pack(self)
	
#	print("save scene")
#	print("owner ", owner)

	ResourceSaver.save("res://addons/project_view/project_view.tscn", packed_scene)


func _on_GraphEdit_delete_nodes_request():
	print("delete node request??")
