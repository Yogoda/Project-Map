tool
extends AcceptDialog

onready var actions := $Margins/Content/ActionContainer/Margins/Actions
onready var invalid_panel := $Margins/Content/ValidationPanel
onready var _filter_field := $Margins/Content/Header/FilterMargins/Filter
onready var _action_list := []

var _context: GDScriptFunctionState


func open(trigger_actions: Array, context: GDScriptFunctionState) -> void:
	if _context:
		_context.resume(false)
	_context = context

	show()
	_filter_field.clear()
	_filter_field.grab_focus()
	
	for action in actions.get_children():
		actions.remove_child(action)
	
	for input_action in InputMap.get_actions():
		var action := CheckBox.new()
		action.connect("toggled", self, "_on_Action_toggled")
		action.text = input_action
		action.pressed = input_action in trigger_actions
		actions.add_child(action)

	_validate()


func close() -> void:
	if _context:
		_context.resume(false)
	_context = null
	hide()


func get_selected_actions() -> Array:
	return self._action_list.duplicate()


func _unhandled_input(trigger) -> void:
	if not visible:
		return
	if trigger is InputEventKey and trigger.scancode == KEY_ENTER:
		if not get_ok().disabled:
			emit_signal("confirmed")
			hide()


func _validate() -> void:
	invalid_panel.visible = _action_list.empty()
	get_ok().disabled = _action_list.empty()


func _on_Action_toggled(_pressed) -> void:
	# no way to know which item, so rebuild list
	_action_list.clear()
	for action in actions.get_children():
		var checkbox := action as CheckBox
		if checkbox.pressed:
			_action_list.push_back(checkbox.text)
	_validate()


func _on_Filter_text_changed(new_text: String) -> void:
	for action in actions.get_children():
		var checkbox := action as CheckBox
		checkbox.visible = new_text.empty() or -1 < checkbox.text.find(new_text)


func _on_ClearButton_pressed():
	_action_list.clear()
	for action in actions.get_children():
		var checkbox := action as CheckBox
		checkbox.pressed = false


func _on_confirmed():
	_context.resume(true)
	_context = null
