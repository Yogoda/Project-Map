tool
extends GraphEdit

var graph_node = preload("res://addons/project_view/graph_node.tscn")

func can_drop_data(position, data):
	return true

func drop_data(pos, data):
	
	print("drop data ", data, " at ", pos)
	
	var node = graph_node.instance()
	
	add_child(node)
	
	var file_name:String = data.files[0]
	var s = file_name.split("/")
	file_name = s[s.size() - 1]
	
	node.offset = scroll_offset + pos
	node.set_label(file_name)
