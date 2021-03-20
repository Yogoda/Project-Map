tool
extends EditorPlugin

var project_map
var project_map_path = "res://addons/project_map/project_map.tscn"
var project_map_save_path = "res://addons/project_map/project_map_save.tscn"

func _enter_tree():
	
	get_tree().set_meta("__editor_interface", get_editor_interface())
	
	var file_save = File.new()
	if file_save.file_exists(project_map_save_path):
		project_map = load(project_map_save_path).instance()
	else:
		project_map = load(project_map_path).instance()
	
	get_editor_interface().get_editor_viewport().add_child(project_map)
	project_map.visible = false


func _exit_tree():
	
	project_map.save()

	get_editor_interface().get_editor_viewport().remove_child(project_map)
	project_map.queue_free()


func _input(event):

	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_SPACE && event.control:
			get_editor_interface().set_main_screen_editor("Project")


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
