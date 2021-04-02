tool
extends GraphNode

#uses exported variables so that data can be saved
export var path:String

export(int) var resource_type
export(String) var icon_class
export(String) var script_path
export(String) var script_name

onready var main_resource = $VB/Resource
onready var script_resource = $VB/Script

func _ready():
	
	main_resource.connect("resource_activated", self, "_on_resource_activated")
	script_resource.connect("resource_activated", self, "_on_resource_activated")
	
	var nde_resource = main_resource
	
	#load data
	if icon_class:
		nde_resource.resource_type = resource_type
		nde_resource.icon_class = icon_class
		
		if script_path:
			nde_resource.script_path = script_path
		
	if path:
		init(path)
	
func set_selected(value):
	
	print("set selected")
	
func init(path):

	var nde_resource = main_resource
	
	nde_resource.init(path)
	
	#store data to be saved
	resource_type = nde_resource.resource_type
	icon_class = nde_resource.icon_class
	script_path = nde_resource.script_path
	
	#scene has a script
	if nde_resource.script_path:
		
		script_resource.resource_name = script_name
		
		script_resource.resource_type = script_resource.TYPE_SCRIPT
		script_resource.icon_class = "Script"
		
		script_resource.init(nde_resource.script_path)
		script_name = script_resource.resource_name
		
		script_resource.show()


func get_row_count():
	
	if script_resource.visible:
		return 2
	else:
		return 1


func _on_resource_activated(pm_resource):
	
	var interface = get_tree().get_meta("__editor_interface")

	if pm_resource.resource_type == pm_resource.TYPE_2D or pm_resource.resource_type == pm_resource.TYPE_3D:
		
		if pm_resource.resource_type == pm_resource.TYPE_2D:
			interface.set_main_screen_editor("2D")
		else:
			interface.set_main_screen_editor("3D")
			
		interface.open_scene_from_path(pm_resource.resource_path)
	
	else:
		
		var resource = ResourceLoader.load(pm_resource.resource_path)
				
		interface.edit_resource(resource)
				
		if resource is Script:
					
			interface.set_main_screen_editor("Script")

