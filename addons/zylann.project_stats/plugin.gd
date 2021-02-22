tool
extends EditorPlugin

const SAVE_PATH = "res://addons/zylann.project_stats/data"

const Analyzer = preload("analyzer.gd")
var Window = load("res://addons/zylann.project_stats/window.tscn")

const MENU_SHOW = 0

var _analyzer = null
var _window = null
var _menu_button = null


func _enter_tree():
	_window = Window.instance()
	_window.set_data_dir(SAVE_PATH)
	get_editor_interface().get_base_control().add_child(_window)
	
	_analyzer = Analyzer.new()
	_window.call_deferred("set_analyzer", _analyzer)
	add_child(_analyzer)
	
	# TODO Need Godot version including this merge https://github.com/godotengine/godot/pull/17576
#	var menu = PopupMenu.new()
#	menu.add_item("Show", MENU_SHOW)
#	menu.connect("id_pressed", self, "_on_menu_id_pressed")
#	add_tool_submenu_item("Project statistics", menu)
	_menu_button = MenuButton.new()
	_menu_button.text = "Project statistics"
	_menu_button.get_popup().add_item("Show", MENU_SHOW)
	_menu_button.get_popup().connect("id_pressed", self, "_on_menu_id_pressed")
	add_control_to_container(CONTAINER_TOOLBAR, _menu_button)
	
	_analyzer.connect("scan_completed", self, "_on_analyzer_scan_completed")
	_analyzer.call_deferred("run")


func _exit_tree():
	_menu_button.queue_free()
	_menu_button = null
	
	_window.queue_free()
	_window = null


func _on_menu_id_pressed(id):
	if id == MENU_SHOW:
		_window.popup_centered_minsize()


func _on_analyzer_scan_completed():
	var save_path = get_current_save_path()
	var f = File.new()
	if not f.file_exists(save_path):
		var data = _analyzer.get_data()
		save_data(save_path, data)


func save_data(fpath, data):
	var json = JSON.print(data, "\t")
	var f = File.new()
	var err = f.open(fpath, File.WRITE)
	if err != OK:
		print("ERROR: cannot write file '", fpath, "'")
		return
	f.store_string(json)
	f.close()
	#print("Saved ", fpath)


func get_current_save_path():
	# Files are saved on per hour basis
	var datetime = OS.get_datetime()
	var s = "project_stats_" + str(datetime.year) \
		+ "_" + str(datetime.month) \
		+ "_" + str(datetime.day) \
		+ "_" + str(datetime.hour) + "_00.json"
	return SAVE_PATH.plus_file(s)

