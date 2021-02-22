tool
extends Node

onready var _parent_node = get_parent() 
var fsm: VFSM
var _current_state: VFSMState

func _ready():
	if Engine.editor_hint:
		set_process(false)
		set_physics_process(false)
		set_process_input(false)
		if not self.fsm:
			self.fsm = VFSM.new()
	else:
		_current_state = fsm.get_start_state()
		assert(_current_state, "VisualFSM: %s's finite state machine doesn't point to a starting state." % _parent_node.name)
		if _current_state:
			_current_state.enter()


func _unhandled_input(event: InputEvent) -> void:
	var next_state: VFSMState
	for trigger_id in _current_state.trigger_ids:
		var trigger := fsm.get_trigger(trigger_id)
		var go_to_next_trigger := false
		if trigger is VFSMTriggerAction:
			go_to_next_trigger = trigger.is_trigger_action(event)

		if go_to_next_trigger:
			next_state = fsm.get_next_state(_current_state, trigger)
			break

	if next_state:
		_current_state.exit()

		_current_state = next_state
		_current_state.enter()
		for trigger_id in _current_state.trigger_ids:
			fsm.get_trigger(trigger_id).enter()


func _process(delta) -> void:
	_current_state.update(_parent_node, delta)

	var next_state: VFSMState
	for trigger_id in _current_state.trigger_ids:
		var trigger := fsm.get_trigger(trigger_id)
		var go_to_next_trigger := false
		if trigger is VFSMTriggerTimer:
			go_to_next_trigger = trigger.is_over(delta)
		elif trigger is VFSMTriggerScript:
			go_to_next_trigger = trigger.is_triggered(_parent_node, delta)

		if go_to_next_trigger:
			next_state = fsm.get_next_state(_current_state, trigger)
			break

	if next_state:
		_current_state.exit()

		_current_state = next_state
		_current_state.enter()
		for trigger_id in _current_state.trigger_ids:
			fsm.get_trigger(trigger_id).enter()


func _set(property, value):
	match property:
		"finite_state_machine":
			fsm = value
	return false


func _get(property):
	match property:
		"finite_state_machine":
			return fsm
	return null


func _get_property_list() -> Array:
	return [
		{
			"name": "finite_state_machine",
			"type": TYPE_OBJECT,
			"hint": PROPERTY_HINT_RESOURCE_TYPE,
			"hint_string": "VFSM",
			"usage": PROPERTY_USAGE_NOEDITOR
		}
	]
