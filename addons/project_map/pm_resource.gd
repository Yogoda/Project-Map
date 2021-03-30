tool
extends HBoxContainer

signal resource_activated(pm_resource)

enum {TYPE_2D, TYPE_3D, TYPE_SCRIPT, TYPE_OTHER}

var resource_type

var resource_path

var icon:Texture
var script_path:String

func init(resource_path):
	
	self.resource_path = resource_path

	var resource_name = get_resource_name(resource_path)
	
	if resource_name.find("::") >= 0:
		$Button.text = "built-in script"
	else:
		$Button.text = resource_name

	get_resource_info(resource_path)
	
	$Icon.texture = icon


func get_resource_info(resource_path):
	
	var resource = ResourceLoader.load(resource_path)
	
	if resource is PackedScene:

		var instance = resource.instance()
		
		if instance is Spatial:
			resource_type = TYPE_3D
		else:
			resource_type = TYPE_2D
		
		icon = get_icon(instance.get_class(), "EditorIcons")
		
		var scn_script = instance.get_script()
		
		if scn_script:
			script_path = scn_script.resource_path
		
	elif resource is Resource:
		
		if resource is Script:
			
			resource_type = TYPE_SCRIPT
			icon = get_icon("Script", "EditorIcons")
		else:

			resource_type = TYPE_OTHER
			icon = get_icon(resource.get_class(), "EditorIcons")


func get_resource_name(resource_path):
	
	var split = resource_path.split("/")
	return split[split.size() - 1]


func _on_Button_pressed():
	emit_signal("resource_activated", self)
