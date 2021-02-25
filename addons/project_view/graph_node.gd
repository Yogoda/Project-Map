tool
extends GraphNode

#uses exported variables so that data can be saved
export var path:String
export var file_name:String

const icn_scene = preload("res://addons/project_view/icons/packed_scene.svg")
const icn_script = preload("res://addons/project_view/icons/script.svg")
const icn_node = preload("res://addons/project_view/icons/node.svg")
const icn_control = preload("res://addons/project_view/icons/control.svg")
const icn_node2D = preload("res://addons/project_view/icons/node_2d.svg")
const icn_node3D = preload("res://addons/project_view/icons/node_3d.svg")

enum {EDITOR_2D, EDITOR_3D, EDITOR_SCRIPT, EDITOR_OTHER}

var editor = EDITOR_2D

func _ready():
	
	init()
	
func init():
	
	var s = path.split("/")
	file_name = s[s.size() - 1]
	
	$HB/Label.text = file_name
	$HB/Button.text = file_name
	
	$HB/Script.texture = get_icon("Script", "EditorIcons")
	
	var interface = Plugin.get_editor_interface()

	var resource = ResourceLoader.load(path)
	
	if resource is PackedScene:
		
		var control:Control = Control.new()

		$HB/Icon.texture = get_icon("PackedScene", "EditorIcons")
		
		var instance = resource.instance()
		
		if instance is Spatial:
			editor = EDITOR_3D
		else:
			editor = EDITOR_2D
		
		$HB/Icon.texture = get_icon(instance.get_class(), "EditorIcons")
		
		if instance.get_script():
			$HB/Script.show()
		
	elif resource is Resource:
		
		if resource is Script:
			
			editor = EDITOR_SCRIPT
			$HB/Icon.texture = get_icon("Script", "EditorIcons")
		else:
			editor = EDITOR_OTHER
			$HB/Icon.texture = get_icon(resource.get_class(), "EditorIcons")

func _on_Button_pressed():
	
	var interface = Plugin.get_editor_interface()
	
#	interface.open_scene_from_path(path)
	
#	print(path)

	if editor == EDITOR_2D or editor == EDITOR_3D:
		
		if editor == EDITOR_2D:
			interface.set_main_screen_editor("2D")
		else:
			interface.set_main_screen_editor("3D")
			
		interface.open_scene_from_path(path)
	
	else:
		
		var resource = ResourceLoader.load(path)
				
		interface.edit_resource(resource)
				
		if resource is Script:
					
			interface.set_main_screen_editor("Script")
