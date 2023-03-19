@tool
class_name PMResource
extends HBoxContainer

signal resource_activated(pm_resource)

enum {TYPE_2D, TYPE_3D, TYPE_SCRIPT, TYPE_OTHER, TYPE_DIR}

var resource_path
var resource_type
var resource_name

var icon_class:String
var script_path:String

func _ready():
	
	pass


func set_icon(icon_class):

	$Icon.texture = get_theme_icon(icon_class, "EditorIcons")
	
	if icon_class == "Folder":
		$Icon.modulate = Color("83a3d2")


func set_name(resource_path):
	
	if not resource_name:
		
		resource_name = get_resource_name(resource_path)
		
		if resource_name.find("::") >= 0:
			resource_name = "built-in script"
			
	$Button.text = resource_name


func init(resource_path):
	
	self.resource_path = resource_path

	if icon_class.is_empty():
		get_resource_info(resource_path)
		
	set_name(resource_path)

	set_icon(icon_class)
	
	if not script_path.is_empty():
		pass


func get_resource_info(resource_path):
	
	var dir = DirAccess.open(resource_path)

	if dir:
		resource_type = TYPE_DIR
		icon_class = "Folder"

	else:
		
		var resource = ResourceLoader.load(resource_path)
	
		if resource is PackedScene:

			var instance = resource.instantiate()
			
			if instance is Node3D:
				resource_type = TYPE_3D
			else:
				resource_type = TYPE_2D
			
			icon_class = instance.get_class()
			
			var scn_script = instance.get_script()
			
			if scn_script:
				script_path = scn_script.resource_path
			
		elif resource is Resource:
			
			if resource is Script:
				
				resource_type = TYPE_SCRIPT
				icon_class = "Script"
			else:

				resource_type = TYPE_OTHER
				icon_class = resource.get_class()


func get_resource_name(resource_path):
	
	var split:Array = resource_path.split("/")

	var name = split.pop_back()
	
	if name.is_empty():
		name = split.pop_back()
		
	return name


func _on_Button_pressed():
	emit_signal("resource_activated", self)
