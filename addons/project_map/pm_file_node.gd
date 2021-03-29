tool
extends GraphNode

#uses exported variables so that data can be saved
export var path:String

func _ready():
	
	$VB/Resource.connect("resource_activated", self, "_on_resource_activated")
	$VB/Script.connect("resource_activated", self, "_on_resource_activated")
	
	if not path.empty():
		init(path)
	
func init(path):

	var nde_resource = $VB/Resource
	
	nde_resource.init(path)
	
	if nde_resource.script_path:
		
		$VB/Script.init(nde_resource.script_path)
		$VB/Script.show()
		
func get_row_count():
	
	if $VB/Script.visible:
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
