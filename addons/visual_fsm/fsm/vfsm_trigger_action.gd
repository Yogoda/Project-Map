tool
class_name VFSMTriggerAction
extends VFSMTrigger

export(Array) var action_list: Array


func is_trigger_action(input: InputEvent) -> bool:
	for action in action_list:
		if input.is_action_pressed(action):
			return true
	return false


# add down, released, duration held...
