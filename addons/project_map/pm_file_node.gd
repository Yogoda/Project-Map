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

var drag_start #used for undo move

var undo_id

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
	
	pass


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

func collapse_selected(node, depth = 1):
	
	for child in node.get_children():
		
		if child is Tree:
			
			var item:TreeItem = child.get_selected()
			
			if item:
				item.collapsed = true
			
		collapse_selected(child, depth + 1)

func expand_selected(node, depth = 1):
	
	for child in node.get_children():
		
		if child is Tree:
			
			var item:TreeItem = child.get_selected()
			
			if item:
				
				if item.get_text(0) == main_resource.resource_name:
					item.collapsed = false
			
		expand_selected(child, depth + 1)


func _on_resource_activated(pm_resource):
	
	var interface = get_tree().get_meta("__editor_interface")

	if pm_resource.resource_type == pm_resource.TYPE_2D or pm_resource.resource_type == pm_resource.TYPE_3D:
		
		if pm_resource.resource_type == pm_resource.TYPE_2D:
			interface.set_main_screen_editor("2D")
		else:
			interface.set_main_screen_editor("3D")
			
		interface.open_scene_from_path(pm_resource.resource_path)
	
	elif pm_resource.resource_type == pm_resource.TYPE_DIR:
		
		var file_dock:FileSystemDock = interface.get_file_system_dock()
		
		collapse_selected(file_dock)
		file_dock.navigate_to_path(pm_resource.resource_path)
		expand_selected(file_dock)
		
	else:
		
		var resource = ResourceLoader.load(pm_resource.resource_path)
				
		interface.edit_resource(resource)
				
		if resource is Script:
					
			interface.set_main_screen_editor("Script")

