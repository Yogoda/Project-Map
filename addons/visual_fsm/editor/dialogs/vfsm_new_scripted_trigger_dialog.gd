tool
extends ConfirmationDialog

signal new_trigger_created(trigger)
signal trigger_name_request(name)

export(Texture) var script_icon

var trigger_name: String setget _set_trigger_name, _get_trigger_name

onready var _trigger_name := $Margins/Content/TriggerName
onready var _name_status := $Margins/Content/Prompt/Margin/VBox/Name

var _context: GDScriptFunctionState


func _ready() -> void:
	get_ok().text = "Create trigger"
	get_cancel().connect("pressed", self, "_on_canceled")
	_validate()


func open(context: GDScriptFunctionState) -> void:
	if _context:
		_context.resume(false)
	_context = context

	show()
	self.trigger_name = ""
	_trigger_name.grab_focus()


func close() -> void:
	_context = null
	hide()


func deny_name_request(name: String) -> void:
	_name_status.text = "An trigger with this name already exists."
	_name_status.add_color_override("font_color", Color.red)


func approve_name_request(name: String) -> void:
	self.state_name = name


func _unhandled_input(trigger: InputEvent) -> void:
	if not visible:
		return

	if trigger is InputEventKey and trigger.scancode == KEY_ENTER and not get_ok().disabled:
		emit_signal("confirmed")
		hide()


func _set_trigger_name(value: String) -> void:
	var caret_pos = _trigger_name.caret_position
	_trigger_name.text = value
	_trigger_name.caret_position = caret_pos
	_validate()


func _get_trigger_name() -> String:
	return _trigger_name.text


func _validate() -> void:
	var ok_button = get_ok()
	var invalid_trigger_name: bool = self.trigger_name.empty()
	if invalid_trigger_name:
		_name_status.text = "Trigger must have a name."
		_name_status.add_color_override("font_color", Color.red)
	else:
		_name_status.text = "Trigger name is available."
		_name_status.add_color_override("font_color", Color.green)

	ok_button.disabled = invalid_trigger_name


func _on_about_to_show() -> void:
	_trigger_name.grab_focus()


func _on_confirmed() -> void:
	_context.resume(true)
	close()


func _on_canceled() -> void:
	_context.resume(false)
	close()


func _on_TriggerName_text_changed(text: String) -> void:
	emit_signal("trigger_name_request", text)

