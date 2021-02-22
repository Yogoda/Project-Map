tool
class_name VFSMState
extends Resource

export(int) var vfsm_id: int
export(String) var name: String
export(Vector2) var position: Vector2
export(Array) var trigger_ids: Array
export(GDScript) var custom_script: GDScript setget _set_custom_script

var custom_script_instance: VFSMStateBase


func has_trigger(vfsm_id: int) -> bool:
	return trigger_ids.find(vfsm_id) > -1


func add_trigger(trigger: VFSMTrigger) -> void:
	trigger_ids.push_back(trigger.vfsm_id)
	_changed()


func remove_trigger(trigger: VFSMTrigger) -> void:
	trigger_ids.erase(trigger.vfsm_id)
	_changed()


func get_trigger_id_from_index(index: int) -> int:
	return trigger_ids[index]


func get_trigger_index(trigger: VFSMTrigger) -> int:
	for i in range(len(trigger_ids)):
		if trigger.vfsm_id == trigger_ids[i]:
			return i
	return -1


func enter() -> void:
	custom_script_instance.enter()


func update(object, delta: float) -> void:
	custom_script_instance.update(object, delta)


func exit() -> void:
	custom_script_instance.exit()


func _set_custom_script(value: GDScript) -> void:
	custom_script = value
	custom_script.reload(true)
	custom_script.connect("script_changed", self, "_init_script")
	_init_script()


func _init_script() -> void:
	custom_script_instance = self.custom_script.new() as VFSMStateBase
	assert(custom_script_instance, "VisualFSM: Script in state \"%s\" must extend VFSMStateBase" % self.name)
	custom_script_instance.name = self.name


func _changed() -> void:
	call_deferred("emit_signal", "changed")


func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		if custom_script_instance:
			custom_script_instance.free()
