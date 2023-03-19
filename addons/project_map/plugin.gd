@tool
extends EditorPlugin

var project_map
var project_map_path = "res://addons/project_map/project_map.tscn"
var project_map_save_path = "res://addons/project_map/project_map_save.tscn"

func _enter_tree():
	
	get_tree().set_meta("__editor_interface", get_editor_interface())
	get_tree().set_meta("__undo_redo", get_undo_redo())
	
	if FileAccess.file_exists(project_map_save_path):
		project_map = load(project_map_save_path).instantiate()
	else:
		project_map = load(project_map_path).instantiate()
	
	get_editor_interface().get_editor_main_screen().add_child(project_map)
	project_map.visible = false


func _exit_tree():
	
	project_map.save()

	get_editor_interface().get_editor_main_screen().remove_child(project_map)
	project_map.queue_free()


func _input(event):

	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_SPACE && event.control:
			get_editor_interface().set_main_screen_editor("Project")


func _has_main_screen():
	return true


func _get_plugin_name():
	return "Project"
	

func _get_plugin_icon():
	return get_editor_interface().get_base_control().get_theme_icon("GuiVisibilityVisible", "EditorIcons")


func _make_visible(visible):
	project_map.visible = visible


func _apply_changes():

	project_map.save()


func _save_external_data():
	
	project_map.save()
