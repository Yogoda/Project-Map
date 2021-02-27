tool
extends EditorPlugin

var project_map = load("res://addons/project_map/project_map.tscn").instance()

func _enter_tree():
	
#	add_control_to_project_map( project_map_SLOT_LEFT_UL, project_map )
	get_tree().set_meta("__editor_interface", get_editor_interface())
	get_editor_interface().get_editor_viewport().add_child(project_map)
	project_map.visible = false

func _exit_tree():

	get_editor_interface().get_editor_viewport().remove_child(project_map)
	project_map.queue_free()


func has_main_screen():
	return true


func get_plugin_name():
	return "Project"
	

func get_plugin_icon():
	return get_editor_interface().get_base_control().get_icon("GuiVisibilityVisible", "EditorIcons")


func make_visible(visible):
	project_map.visible = visible

func apply_changes():

	project_map.save()

func save_external_data():
	
	project_map.save()
