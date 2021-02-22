tool
class_name VFSMTriggerScript
extends VFSMTrigger

export(GDScript) var custom_script: GDScript setget _set_custom_script

var custom_script_instance: VFSMTriggerBase

func enter() -> void:
	custom_script_instance.enter()


func is_triggered(object: Node, delta: float) -> bool:
	return custom_script_instance.is_triggered(object, delta)


func _set_custom_script(value: GDScript) -> void:
	custom_script = value
	custom_script.reload(true)
	custom_script_instance = custom_script.new() as VFSMTriggerBase
	assert(custom_script_instance, "VisualFSM: Script in event \"%s\" must extend VFSMTriggerBase" % self.name)
	custom_script_instance.name = self.name


func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		custom_script_instance.free()
