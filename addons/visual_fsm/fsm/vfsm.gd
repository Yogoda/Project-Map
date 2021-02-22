tool
class_name VFSM
extends Resource

const STATE_TEMPLATE_PATH := "res://addons/visual_fsm/resources/state_template.txt"
const TRIGGER_TEMPLATE_PATH := "res://addons/visual_fsm/resources/trigger_template.txt"

export(int) var start_state_vfsm_id: int
export(Vector2) var start_position: Vector2

var _next_state_vfsm_id := 0
var _next_trigger_vfsm_id := 0
var _states := {} # vfsm_id to VFSMState
var _trigger_vfsm_id_map := {} # vfsm_id to VFSMTrigger
var _transitions := {
#   from_state_vfsm_id_1: {
#		trigger_vfsm_id_1: to_state_vfsm_id_1,
#		trigger_vfsm_id_2: to_state_vfsm_id_2
#		etc...
#	},
#	from_state_vfsm_id_1: {
#		etc...
#	},
#	etc...
}
var _state_custom_script_template: String
var _trigger_custom_script_template: String


func _read_from_file(path: String) -> String:
	var f = File.new()
	var err = f.open(path, File.READ)
	if err != OK:
		push_warning("Could not open file \"%s\", error code: %s" % [path, err])
		return ""
	var content = f.get_as_text()
	f.close()
	return content


func _init():
	if not start_position:
		start_position = Vector2(100, 100)
	_state_custom_script_template = _read_from_file(STATE_TEMPLATE_PATH)
	_trigger_custom_script_template = _read_from_file(TRIGGER_TEMPLATE_PATH)


func has_state(name: String) -> bool:
	for state in _states.values():
		if name == state.name:
			return true
	return false


func get_start_state() -> VFSMState:
	if 0 > self.start_state_vfsm_id:
		return null
	return _states.get(self.start_state_vfsm_id)


func set_start_state(state: VFSMState) -> void:
	if state:
		self.start_state_vfsm_id = state.vfsm_id
	else:
		self.start_state_vfsm_id = -1
	_changed()


func get_state(vfsm_id: int) -> VFSMState:
	return _states.get(vfsm_id)


func get_next_state(state: VFSMState, trigger: VFSMTrigger) -> VFSMState:
	var next_state_id = _transitions.get(state.vfsm_id).get(trigger.vfsm_id)
	return _states.get(next_state_id)


func get_triggers_in_state(state: VFSMState) -> Array:
	var triggers := []
	for trigger_vfsm_id in state.trigger_ids:
		triggers.push_back(_trigger_vfsm_id_map[trigger_vfsm_id])
	return triggers


func get_to_state(
	from_state: VFSMState,
	trigger: VFSMTrigger
) -> VFSMState:
	var triggers = _transitions.get(from_state.vfsm_id)
	if not triggers.has(trigger.vfsm_id):
		return null

	var to_state_vfsm_id: int = triggers.get(trigger.vfsm_id)
	return _states.get(to_state_vfsm_id)


func get_states() -> Array:
	return _states.values()


func get_trigger(vfsm_id: int) -> VFSMTrigger:
	return _trigger_vfsm_id_map.get(vfsm_id)


func has_script_trigger(name: String) -> bool:
	for trigger in _trigger_vfsm_id_map.values():
		if trigger is VFSMTriggerScript:
			return name == trigger.name
	return false


func get_script_triggers() -> Array:
	var script_triggers := []
	for trigger in _trigger_vfsm_id_map.values():
		if trigger is VFSMTriggerScript:
			script_triggers.push_back(trigger)
	return script_triggers


func create_state(name: String, position: Vector2,
	from_state: VFSMState = null, 
	from_trigger: VFSMTrigger = null) -> void:
	var state := VFSMState.new()
	state.connect("changed", self, "_changed")
	state.vfsm_id = _next_state_vfsm_id
	_next_state_vfsm_id += 1
	state.name = name
	state.position = position
	var custom_script := GDScript.new()
	custom_script.source_code = _state_custom_script_template % state.name
	state.custom_script = custom_script
	_states[state.vfsm_id] = state
	_transitions[state.vfsm_id] = {}
	if from_state and from_trigger:
		_transitions[from_state.vfsm_id][from_trigger.vfsm_id] = state.vfsm_id
		_changed()
	else:
		self.set_start_state(state)


func remove_state(state: VFSMState) -> void:
	_states.erase(state.vfsm_id)
	_transitions.erase(state.vfsm_id)
	for from_vfsm_id in _transitions:
		var triggers_to_erase := []
		for trigger_vfsm_id in _transitions.get(from_vfsm_id):
			if state.vfsm_id == _transitions.get(from_vfsm_id).get(trigger_vfsm_id):
				triggers_to_erase.push_back(trigger_vfsm_id)
		for trigger_vfsm_id in triggers_to_erase:
			_transitions[from_vfsm_id].erase(trigger_vfsm_id)
	_changed()


func create_timer_trigger(state: VFSMState) -> void:
	var timer_trigger := VFSMTriggerTimer.new()
	timer_trigger.vfsm_id = _get_next_transition_id()
	timer_trigger.duration = 1
	_trigger_vfsm_id_map[timer_trigger.vfsm_id] = timer_trigger
	state.add_trigger(timer_trigger)


func create_action_trigger(state: VFSMState) -> void:
	var action_trigger := VFSMTriggerAction.new()
	action_trigger.vfsm_id = _get_next_transition_id()
	_trigger_vfsm_id_map[action_trigger.vfsm_id] = action_trigger
	state.add_trigger(action_trigger)


func create_script_trigger(state: VFSMState, trigger_name: String) -> void:
	assert(not has_script_trigger(trigger_name))
	var script_trigger := VFSMTriggerScript.new()
	script_trigger.vfsm_id = _get_next_transition_id()
	script_trigger.name = trigger_name
	var custom_script := GDScript.new()
	custom_script.source_code = _trigger_custom_script_template % trigger_name
	script_trigger.custom_script = custom_script
	_trigger_vfsm_id_map[script_trigger.vfsm_id] = script_trigger
	state.add_trigger(script_trigger)


func remove_trigger_from_state(state: VFSMState, trigger: VFSMTrigger) -> void:
	_transitions[state.vfsm_id].erase(trigger.vfsm_id)
	state.remove_trigger(trigger)


func remove_trigger(trigger: VFSMTrigger) -> void:
	_trigger_vfsm_id_map.erase(trigger.vfsm_id)
	for state_vfsm_id in _states:
		_states.get(state_vfsm_id).remove_trigger(trigger)
	_changed()


func add_transition(
	from_state: VFSMState,
	from_trigger: VFSMTrigger,
	to_state: VFSMState
) -> void:
	_transitions[from_state.vfsm_id][from_trigger.vfsm_id] = to_state.vfsm_id
	_changed()


func remove_transition(
	from_state: VFSMState,
	from_trigger: VFSMTrigger
) -> void:
	_transitions[from_state.vfsm_id].erase(from_trigger.vfsm_id)
	_changed()


func _changed() -> void:
	call_deferred("emit_signal", "changed")


func _get_next_state_id() -> int:
	var id = _next_state_vfsm_id
	_next_state_vfsm_id += 1
	return id


func _get_next_transition_id() -> int:
	var id = _next_trigger_vfsm_id
	_next_trigger_vfsm_id += 1
	return id


func _get(property: String):
#	print_debug("FSM: Getting property: %s" % property)
	match property:
		"states":
			return _states.values()
		"triggers":
			return _trigger_vfsm_id_map.values()
		"transitions":
			var transitions := []
			for from_vfsm_id in _transitions:
				for trigger_vfsm_id in _transitions[from_vfsm_id]:
					var to_vfsm_id = _transitions[from_vfsm_id][trigger_vfsm_id]
					transitions += [
						from_vfsm_id,
						trigger_vfsm_id,
						to_vfsm_id
					]
			return transitions
	return null


func _set(property: String, value) -> bool:
	match property:
		"states":
			for state in value:
				state.connect("changed", self, "_changed")
				_states[state.vfsm_id] = state
				_transitions[state.vfsm_id] = {}
				if _next_state_vfsm_id <= state.vfsm_id:
					_next_state_vfsm_id = state.vfsm_id + 1
			return true
		"triggers":
			for trigger in value:
				_trigger_vfsm_id_map[trigger.vfsm_id] = trigger
				if _next_trigger_vfsm_id <= trigger.vfsm_id:
					_next_trigger_vfsm_id = trigger.vfsm_id + 1
			return true
		"transitions":
			var num_transitions = value.size() / 3
			for vfsm_idx in range(num_transitions):
				var from_vfsm_id = value[3 * vfsm_idx]
				var trigger_vfsm_id = value[3 * vfsm_idx + 1]
				var to_vfsm_id = value[3 * vfsm_idx + 2]
				if not _transitions.has(from_vfsm_id):
					_transitions[from_vfsm_id] = {}
				_transitions[from_vfsm_id][trigger_vfsm_id] = to_vfsm_id
			return true
	return false


func _get_property_list() -> Array:
	var property_list := []
	property_list += [
			{
				"name": "states",
				"type": TYPE_ARRAY,
				"hint": PROPERTY_HINT_NONE,
				"hint_string": "",
				"usage": PROPERTY_USAGE_NOEDITOR
			},
			{
				"name": "triggers",
				"type": TYPE_ARRAY,
				"hint": PROPERTY_HINT_NONE,
				"hint_string": "",
				"usage": PROPERTY_USAGE_NOEDITOR
			},
			{
				"name": "transitions",
				"type": TYPE_ARRAY,
				"hint": PROPERTY_HINT_NONE,
				"hint_string": "",
				"usage": PROPERTY_USAGE_NOEDITOR
			}
		]

	return property_list
