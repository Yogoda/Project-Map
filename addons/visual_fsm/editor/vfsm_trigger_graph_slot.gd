tool
class_name VFSMTriggerGraphSlot
extends PanelContainer

signal close_request(trigger_slot)

onready var _timer_duration_field := $Timer/DurationMargins/Duration
onready var _action_title_field := $Action/ActionMargins/ActionLabel
onready var _script_title_field := $Script/TitleMargins/Title

var timer_duration_dialog: AcceptDialog
var input_action_dialog: AcceptDialog

var trigger: VFSMTrigger setget _set_trigger


func _set_trigger(value: VFSMTrigger) -> void:
	trigger = value

	if trigger is VFSMTriggerAction:
		$Action.visible = true
		_update_action_label()
	elif trigger is VFSMTriggerTimer:
		$Timer.visible = true
		_timer_duration_field.text = str(trigger.duration)
	elif trigger is VFSMTriggerScript:
		$Script.visible = true;
		_script_title_field.text = trigger.name


func _on_CloseButton_pressed() -> void:
	emit_signal("close_request", self)


func _on_Script_pressed() -> void:
	assert(self.trigger is VFSMTriggerScript,
		"VisualFSM: Trigger \"%s\" should be of type VFSMTriggerScript" % self.trigger.name)
	$"/root/VFSMSingleton".emit_signal("edit_custom_script", self.trigger.custom_script)


func try_set_timer_duration() -> void:
	if yield():
		self.trigger.duration = timer_duration_dialog.duration
		_timer_duration_field.text = str(timer_duration_dialog.duration)


func _on_Timer_pressed() -> void:
	assert(self.trigger is VFSMTriggerTimer,
		"VisualFSM: Trigger \"%s\" should be of type VFSMTriggerTimer" % self.trigger.name)
	var mouse_pos = get_global_mouse_position()
	timer_duration_dialog.rect_position = mouse_pos - timer_duration_dialog.rect_size / 2
	timer_duration_dialog.open(trigger.duration, try_set_timer_duration())


func _update_action_label() -> void:
	var action_list = self.trigger.action_list
	if action_list.empty():
			_action_title_field.text = "No action"
	else:
		_action_title_field.text = action_list[0]
		if action_list.size() > 1:
			_action_title_field.text += " +%s" % str(action_list.size() - 1) 


func try_set_action_list() -> void:
	if yield():
		self.trigger.action_list = input_action_dialog.get_selected_actions()
	else:
		self.trigger.action_list = []
	_update_action_label()


func _on_Action_pressed():
	assert(self.trigger is VFSMTriggerAction,
		"VisualFSM: Trigger \"%s\" should be of type VFSMTriggerAction" % self.trigger.name)
	var mouse_pos = get_global_mouse_position()
	input_action_dialog.rect_position = mouse_pos - input_action_dialog.rect_size + Vector2(80, 50)
	input_action_dialog.open(trigger.action_list, try_set_action_list())
