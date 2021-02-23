tool
extends GraphNode

var label:String setget set_label

func set_label(value):
	label = value
	$HBoxContainer/Label.text = value
