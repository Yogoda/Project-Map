tool
extends EditorPlugin

var dock = preload("res://addons/project_view/project_view.tscn").instance()

func _enter_tree():
	
	# When this plugin node enters tree, add the custom type
#	dock = 
#	add_control_to_dock( DOCK_SLOT_LEFT_UL, dock )
#	get_tree().set_meta("__editor_interface", get_editor_interface())
	get_editor_interface().get_editor_viewport().add_child(dock)
	dock.visible = false
	
func _exit_tree():
#	remove_control_from_docks(dock)
	get_editor_interface().get_editor_viewport().remove_child(dock)
	dock.free()


func has_main_screen():
	return true

func get_plugin_name():
	return "Project View"

func make_visible(visible):
	dock.visible = visible
